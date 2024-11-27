import {createClient} from 'npm:@supabase/supabase-js@2'
import { config } from "https://deno.land/x/dotenv/mod.ts"
import {JWT} from 'npm:google-auth-library@9'

config();

interface WebhookPayload {
    type: "UPDATE";
    table: "Listing";
    schema: string;
    record: ListingRecord;
    old_record: ListingRecord;
}

interface ListingRecord {
    price: number;
    rating: number;
    tenant: string | null;
    deposit: number;
    created_at: string;
    isVerified: boolean;
    listing_id: string;
    view_count: number;
    description: string;
    isPublished: boolean;
    property_id: string;
    listing_title: string;
    sex_preference: string;
    nationality_preference: string;
    location: string;
}

interface Amenity {
    name: string;
    value: boolean;
}

interface SearchCriteria {
    title: string;
    min_price: number;
    max_price: number | null;
    sex_preference: string;
    nationality_preference: string;
    room_type: string;
    amenities: Amenity[];
    location: {
            latitude: number;
            longitude: number;
            max_distance: number;
        };
}


const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);


const {default: serviceAccount} = await import("../service-account.json", {
    with: {type: "json"},
})

const getAccessToken = ({
    clientEmail,
    privateKey
}: {
    clientEmail: string
    privateKey: string
}
): Promise<string> => {
    return new Promise((resolve, reject) => {
        const jwtClient = new JWT({
            email: clientEmail,
            key: privateKey,
            scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
        })

        jwtClient.authorize((err, tokens) => {
            if (err) {
              reject(err)
              return
            }
            resolve(tokens!.access_token!)
          })
    })
}

const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  })

Deno.serve(async (req) => {

  const payload: WebhookPayload = await req.json();

  console.log(JSON.stringify(payload, null, 2));

  if (payload.table === "Listing" && payload.type === "UPDATE") {
          const { record, old_record } = payload;

          if (!old_record.isPublished && record.isPublished) {
            await sendNotification(record);
          }
      }

  return new Response("ok");
})


async function sendNotification(record: ListingRecord) {
    const { data: savedSearches, error: searchError } = await supabase
        .from("Saved_Searches")
        .select("user_id, search_criteria, location, title");
    
    console.log(savedSearches);

    if (searchError) {
        console.error("Error fetching saved searches:", searchError);
        return;
    }

    const { data: propertyData, error: propertyError } = await supabase
        .from("Property")
        .select("location")
        .eq("property_id", record.property_id)
        .single();

    if (propertyError) {
        console.error("Error fetching property location:", propertyError);
        return;
    }

    const { data: listingAmenities, error: amenitiesError } = await supabase
        .from("Amenities")
        .select("*")
        .eq("listing_id", record.listing_id)
        .single();

    if (amenitiesError) {
        console.error("Error fetching listing amenities:", amenitiesError);
        return;
    }

    for (const search of savedSearches) {
        const { user_id, search_criteria, location, title } = search;

        let matches = true;

        if (search_criteria != null) {
            try {
                const criteria: SearchCriteria = JSON.parse(search_criteria);
                matches = meetsSearchCriteria(record, criteria, listingAmenities);
            } catch (error) {
                console.error(`Failed to parse search criteria for user ${user_id}:`, error);
                continue;
            }
        }

        console.log("matches:", matches);

        console.log("location", location);


        // Check for location match
        const locationMatch = await isWithinDistance(propertyData.location, location);

        console.log("location match:", locationMatch);

        if (matches && locationMatch) {
            const { data: user, error: userError } = await supabase
                .from("profiles")
                .select("fcm_token")
                .eq("id", user_id)
                .single();

            if (userError) {
                console.error("Error fetching user FCM token:", userError);
                continue;
            }

            const fcmToken = user.fcm_token as string;
            if (fcmToken) {
                await sendFCMNotification(fcmToken, record);
            }
        }
    }
}


function meetsSearchCriteria(record: ListingRecord, criteria: SearchCriteria, listingAmenities: any): boolean {
    if ((criteria.min_price != null && record.price < criteria.min_price) ||
        (criteria.max_price != null && record.price > criteria.max_price)) {
        console.log("Filtered by price");
        return false;
    }

    const preferredNationality = criteria.nationality_preference;
    if (preferredNationality != null && preferredNationality !== "no preference" &&
        record.nationality_preference !== preferredNationality) {
        console.log("Filtered by nationality");
        return false;
    }

    const preferredSex = criteria.sex_preference;
    if (preferredSex != null && preferredSex !== "no preference" &&
        record.sex_preference !== preferredSex) {
        console.log("Filtered by sex");
        return false;
    }

    // Check room type using the amenities object
    const preferredRoomType = criteria.room_type;

    if (preferredRoomType != null && preferredRoomType.length > 0) {
        const roomTypeMatches =
            (preferredRoomType === "master" && listingAmenities.isMasterRoom) ||
            (preferredRoomType === "single" && listingAmenities.isSingleRoom) ||
            (preferredRoomType === "shared" && listingAmenities.isSharedRoom) ||
            (preferredRoomType === "suite" && listingAmenities.isSuite);

        if (!roomTypeMatches) {
            console.log("Filtered by room type");
            return false;
        }
    }

    // Check for amenities matches
    if (criteria.amenities && criteria.amenities.length > 0) {
        for (const requiredAmenity of criteria.amenities) {
            const amenityKey = requiredAmenity.name; 
            const requiredAmenityValue = requiredAmenity.value;
            const listingAmenityValue = listingAmenities[amenityKey];

            // Log the full structure to check for issues
            console.log(`Checking amenity key: ${amenityKey}, required value: ${requiredAmenityValue}, listing value: ${listingAmenityValue}`);

            if (requiredAmenityValue) {
                if (listingAmenityValue !== true) {
                    console.log(`Filtered out by missing amenity: ${amenityKey}`);
                    return false;
                }
            }
        }
    }

    return true; // Only criteria from JSON checked here
}


// The location check can remain as is
async function isWithinDistance(listingLocation: { type: string; coordinates: number[] }, userLocation: { type: string; coordinates: number[] }): Promise<boolean> {
    
    const listingCoords = {
        latitude: listingLocation.coordinates[1],
        longitude: listingLocation.coordinates[0],
    };

    const userCoords = {
        latitude: userLocation.coordinates[1],
        longitude: userLocation.coordinates[0],
    };

    console.log("listingCoords", listingCoords);
    console.log("userCoords", userCoords);

    
    const { data, error } = await supabase
        .rpc('is_within_distance', {
            listing_location: `SRID=4326;POINT(${listingCoords.longitude} ${listingCoords.latitude})`,
            user_latitude: userCoords.latitude,
            user_longitude: userCoords.longitude,
            max_distance: 100000,
        });

    if (error) {
        console.error("Error checking location distance:", error);
        return false;
    }
    return data;
}


async function sendFCMNotification(fcmToken: string, record: ListingRecord) {

    console.log("SENDING NOTIFICATION");

    try {
        const response = await fetch(`https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${accessToken}`,
            },
            body: JSON.stringify({
                message: {
                    token: fcmToken,
                    notification: {
                        title: `New Listing: ${record.listing_title}`,
                        body: `A new listing matching your criteria is available: ${record.description}`,
                    },
                }
            }),
        });

        if (!response.ok) {
            const errorMessage = await response.text();
            console.error("Failed to send notification:", errorMessage);
        } else {
            console.log("Notification sent successfully!");
        }
    } catch (error) {
        console.error("Error sending notification:", error);
    }
}
