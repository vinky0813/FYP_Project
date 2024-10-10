const { createClient } = require('@supabase/supabase-js');

const express = require("express");
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const mime = require('mime-types'); 

require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const supabase = createClient(process.env.SUPABASE_URL, process.env.API_KEY);

const storage = multer.memoryStorage();
const upload = multer({ storage });

app.get('/api/data', async (req, res) => {
  try {
    const { data, error } = await supabase.from("profiles").select("*");
    if (error) return res.status(500).json({ error: error.message });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post("/api/add-property", async (req, res) => {
  const { property_title, address, owner_id, property_image, lat, long, group_id } = req.body;

  try {
    const location = `POINT(${long} ${lat})`;

    const { data, error } = await supabase
      .from('Property') 
      .insert([{ property_title, address, owner_id, property_image, location, group_id }])
      .select("property_id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Property Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});


app.post("/api/upload-property-image", upload.single("image"), async (req, res) => {
  const { originalname, buffer } = req.file;
  const mimeType = mime.lookup(originalname);

  if (!mimeType) {
    return res.status(400).json({ error: "Unsupported file type" });
  }

  const { data, error } = await supabase.storage
    .from("property-images")
    .upload(`images/${Date.now()}_${originalname}`, buffer, {
      contentType: mimeType
    }); 

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  console.log(data.path);

  const { data: publicData, error: publicUrlError } = supabase.storage
    .from('property-images')
    .getPublicUrl(data.path);

  if (publicUrlError) {
    return res.status(500).json({ error: publicUrlError.message });
  }
  const publicURL = publicData.publicUrl;
  console.log(publicURL);

  res.status(200).json({ message: 'Image uploaded successfully', imageUrl: publicURL });
});

app.get("/api/get-all-owner-properties", async (req, res) => {
  try {

    const { owner_id } = req.query;

    const { data, error } = await supabase
      .from("Property")
      .select("*")
      .eq("owner_id", owner_id);

    if (error) return res.status(500).json({ error: error.message });

    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/get-owner-with-id/:user_id", async (req, res) => {
  try {

    const { user_id } = req.params;

    const { data, error } = await supabase
      .from("Owners")
      .select("*")
      .eq("user_id", user_id)
      .single();

    if (error) return res.status(500).json({ error: error.message });
    
    res.json(data);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put("/api/update-property/:property_id", async (req, res) => {
  try{
    const { property_id } = req.params;
    const { property_title, address, property_image, owner_id, lat, long } = req.body;

    const location = `POINT(${long} ${lat})`;

    const { data, error } = await supabase
      .from("Property")
      .update({
        property_title: property_title,
        address: address,
        property_image: property_image,
        owner_id: owner_id,
        location: location,
      })
      .eq("property_id", property_id);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.status(200).json({ message: "Property updated successfully", data: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/api/delete-property/:property_id", async (req, res) => {
  const { property_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Property")
      .delete()
      .eq("property_id", property_id);

    if (error) {
      console.error('Error deleting property:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'Property deleted successfully' });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.post("/api/add-listing-images", async (req, res) => {
  const { listing_id, image_url } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing_images") 
      .insert([{ listing_id, image_url }])
      .select("id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Image Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.delete("/api/delete-listing-image", async (req, res) => {
  const { listing_id, image_url } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing_images") 
      .delete()
      .match({ listing_id, image_url }) 
      .select("id");

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Image Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.post("/api/add-listing-ammenities", async (req, res) => {
  const { listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
    isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop
   } = req.body;

  try {
    const { data, error } = await supabase
      .from("Amenities") 
      .insert([{ listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
        isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop }])
      .select("listing_id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Amenities Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.post("/api/add-listing", async (req, res) => {
  const { listing_title, tenant, price, deposit, property_id, description, isPublished, isVerified, rating, nationality_preference, sex_preference } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing") 
      .insert([{ listing_title, tenant, price, deposit, property_id, rating, isPublished, isVerified, description, nationality_preference, sex_preference }])
      .select("listing_id") 
      .single();

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-listing-images/:listing_id", async (req, res) => {
  try {
    const { listing_id } = req.params;

    const { data, error } = await supabase
      .from("Listing_images")
      .select("image_url")
      .eq("listing_id", listing_id);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({ error: "No images found for the listing" });
    }

    return res.status(200).json(data);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});


app.get("/api/get-all-listing/:property_id", async (req, res) => {
  const { property_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Listing")
      .select("*")
      .eq("property_id", property_id);

    if (error) {
      console.error("Error fetching listings:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No listings found for this property." });
    }

    res.status(200).json({ message: "Listings fetched successfully", data }); 
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-all-reviews/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Reviews")
      .select("*")
      .eq("listing_id", listing_id);

    if (error) {
      console.error("Error fetching reviews:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No reviews found for this listing." });
    }

    res.status(200).json({ message: "Reviews fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-all-amenities/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Amenities")
      .select("*")
      .eq("listing_id", listing_id);

    if (error) {
      console.error("Error fetching amenities:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No amenities found for this listing." });
    }

    res.status(200).json({ message: "amenities fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-renter-with-id/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Renters")
      .select("*")
      .eq("user_id", user_id)
      .single();

    if (error) {
      console.error("Error fetching renter information:", error.message);
      return res.status(500).json({ error: error.message });
    }

    if (data.length === 0) {
      return res.status(404).json({ message: "No renter found" });
    }

    res.status(200).json({ message: "renter information fetched successfully", data });
  } catch (e) {
    console.error("Catch Error:", e.message);
    res.status(500).json({ message: e.message });
  }
});

app.delete("/api/delete-listing-images/:listing_id", async (req, res) => {
  const { listing_id } = req.params;
  try {
    const { data, error } = await supabase
      .from("Listing_images")
      .delete()
      .eq("listing_id", listing_id)
      .select("image_url");

    if (error) {
      console.error('Error deleting listing images:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ 
      message: 'Listing images deleted successfully',
      data: data
    });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.delete("/api/delete-listing-amenities/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Amenities")
      .delete()
      .eq("listing_id", listing_id);

    if (error) {
      console.error('Error deleting listing amenities:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'listing amenities deleted successfully' });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.delete("/api/delete-listing/:listing_id", async (req, res) => {
  const { listing_id } = req.params;
  try {
    const { data, error } = await supabase
      .from("Listing")
      .delete()
      .eq("listing_id", listing_id);

    if (error) {
      console.error('Error deleting listing:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'listing deleted successfully' });
  } catch (error) {
    console.error('Unexpected error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

app.put("/api/update-listing/:listing_id", async (req, res) => {
  try{
    const { listing_id } = req.params;
    const { listing_title, price, deposit, rating, description, sex_preference, nationality_preference } = req.body;

    const { data, error } = await supabase
      .from("Listing")
      .upsert({
        listing_id: listing_id,
        listing_title: listing_title,
        price: price,
        deposit: deposit,
        rating: rating,
        description: description, 
        sex_preference: sex_preference, 
        nationality_preference: nationality_preference,
      });

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.status(200).json({ message: "Listing updated successfully", data: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete("/api/delete-image", async (req, res) => {
  const { listing_id, image_url } = req.body;

  try {
    const { data, error } = await supabase
      .from("Listing_images") 
      .delete()
      .eq("listing_id", listing_id)
      .eq("image_url", image_url);

    if (error) {
      console.error('Insert Error:', error.message);
      return res.status(500).json({ error: error.message });
    }

    res.status(200).json({ message: "Listing Image Added Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.put("/api/edit-listing-ammenities", async (req, res) => {
  const { listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
    isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop
   } = req.body;

  try {
    const { data, error } = await supabase
      .from("Amenities") 
      .upsert([{ listing_id, isMasterRoom, isSingleRoom, isSharedRoom, isSuite, isWifiAccess, isAirCon, isNearMarket,
        isCarPark, isNearMRT, isNearLRT, isPrivateBathroom, isGymnasium, isCookingAllowed, isWashingMachine, isNearBusStop }])
      .select("listing_id") 
      .single();

    if (error) {
      console.error('update Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Listing Amenities Updated Successfully", data });
  } catch (e) {
    console.error('Catch Error:', e.message);
    res.status(500).json({ message: e.message });
  }
});

app.get("/api/get-most-viewed-listing", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("Listing")
      .select("")
      .eq("isPublished", true)
      .order("view_count", { ascending: false })
      .limit(5);

    if (error) {
      throw error;
    }
    res.status(200).json({
      message: "Successfully fetched most-viewed listing",
      data,
    });
  } catch (error) {
    console.error("Error fetching most-viewed listing:", error.message);
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/get-top-rated-listing", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("Listing")
      .select("")
      .eq("isPublished", true)
      .order("rating", { ascending: false })
      .limit(5);

    if (error) {
      throw error;
    }
    res.status(200).json({
      message: "Successfully fetched top-rated listing",
      data,
    });
  } catch (error) {
    console.error("Error fetching top-rated listing:", error.message);
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/get-listing-with-id/:listing_id", async (req, res) => {

  const { listing_id } = req.params;
  try {
    const { data, error } = await supabase
      .from("Listing")
      .select("*")
      .eq("listing_id", listing_id)
      .single();

    if (error) {
      throw error;
    }
    res.status(200).json({
      message: "Successfully fetched listing with id",
      data,
    });
  } catch (error) {
    console.error("Error fetching listing with id:", error.message);
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/search-properties-by-location", async (req, res) => {
  const { lat, long, radius } = req.query;

  try {

    const { data, error } = await supabase
      .rpc("get_properties_within_radius", {
        longitude: parseFloat(long),
        latitude: parseFloat(lat),
        radius: parseFloat(radius)
      });

    if (error) {
      throw error;
    }

    res.status(200).json({ message: "Properties fetched successfully", data });
  } catch (error) {
    console.error("Error fetching properties:", error.message);
    res.status(500).json({ message: error.message });
  }
});

app.get("/api/get-property-with-id/:property_id", async (req, res) => {
  const { property_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Property")
      .select("*")
      .eq("property_id", property_id)
      .single();

    if (error) {
      return res.status(500).json({ message: error.message });
    }

    if (!data) {
      return res.status(404).json({ message: "Property not found" });
    }

    res.status(200).json({ message: "Property fetched successfully", property: data });
  } catch (error) {
    console.error("Error fetching property:", error.message);
    res.status(500).json({ message: "Server error" });
  }
});

app.put("/api/increment-view/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  try {

    const { data: listing, error: fetchError } = await supabase
      .from("Listing")
      .select("view_count")
      .eq("listing_id", listing_id)
      .single();
    
    currentViews = listing.view_count;
      
    const { data, error } = await supabase
      .from("Listing")
      .update({ view_count: currentViews + 1 })
      .eq("listing_id", listing_id);

    res.status(200).json({ message: 'View count incremented successfully', data });

  } catch (error) {
    console.error('Error incrementing view count:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

app.post("/api/add-shortlist", async (req, res) => {
  const { user_id, listing_id } = req.body;
  
  if (!user_id || !listing_id) {
    return res.status(400).json({ error: 'Missing user_id or property_id' });
  }

  try {
    const { data, error } = await supabase
      .from("Shortlists")
      .insert({
        "user_id": user_id,
        "listing_id": listing_id,
      });

    res.status(200).json({ message: 'Property added to shortlist', data });
  } catch (error) {
    console.error('Error adding to shortlist:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

app.delete("/api/remove-shortlist", async (req, res) => {
  const { user_id, listing_id } = req.body;
  
  if (!user_id || !listing_id) {
    return res.status(400).json({ error: 'Missing user_id or property_id' });
  }

  try {
    const { data, error } = await supabase
      .from("Shortlists")
      .delete()
      .eq("user_id", user_id)
      .eq("listing_id", listing_id);

    res.status(200).json({ message: 'Property removed shortlist', data });
  } catch (error) {
    console.error('Error removing shortlist:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

app.get("/api/get-shortlists-with-userid/:user_id", async (req, res) => {
  const { user_id } = req.params;
  
  if (!user_id) {
    return res.status(400).json({ error: 'Missing user_id' });
  }

  try {
    const { data, error } = await supabase
      .from("Shortlists")
      .select("*")
      .eq("user_id", user_id);

    res.status(200).json({ message: "Success, get all shorlists", data });
  } catch (error) {
    console.error('Error getting shortlist:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

app.get("/api/check-renter/:renter_id", async (req, res) => {
  const { renter_id } = req.params;

  const { data, error } = await supabase
        .from("Renters")
        .select("*")
        .eq("user_id", renter_id)
        .eq("isAccommodating", false)
        .single()
  
  if (error) {
        return res.status(404).json({ exists: false });
    }
    return res.status(200).json({ exists: true });
});

app.post("/api/add-invitation", async (req, res) => {
  const { listing_id, owner_id, renter_id } = req.body;

  const { data, error } = await supabase
      .from("Invitations")
      .insert([
          { listing_id, owner_id, renter_id },
      ]);

  if (error) {
      return res.status(400).json({ message: "Failed, add invitation", error });
  }

  return res.status(200).json({ message: "Success, add invitation", data });
});

app.get("/api/get-invitations-with-renter-id/:renter_id", async (req, res) => {
  const { renter_id } = req.params;

  const { data, error } = await supabase
      .from("Invitations")
      .select("*")
      .eq("renter_id", renter_id);

  if (error) {
      return res.status(400).json({ error: error.message });
  }

  return res.status(200).json({ message: "Success, get all invitations", data });
});

app.delete("/api/delete-invitations/:listing_id", async (req, res) => {
  const { listing_id } = req.params;
  const { renter_id } = req.body;

  const { data, error } = await supabase
      .from("Invitations")
      .delete()
      .eq("listing_id", listing_id)
      .eq("renter_id", renter_id);

  if (error) {
      return res.status(404).json({ message: 'Invitation not found' });
  }

  return res.status(200).json({ message: "Success, invitations deleted", data });
});

app.get("/api/get-invitation-with-listing_id/:listing_id", async (req, res) => {
  const { listing_id } = req.params;

  const { data, error } = await supabase  
      .from("Invitations")
      .select("*")
      .eq("listing_id", listing_id)
      .single();

  if (error) {
      return res.status(404).json({ message: 'Invitation not found' });
  }

  return res.status(200).json({ message: "Success, invitation found", data });
});

app.put("/api/accept-invitation-part-1", async (req, res) => {
  const { listing_id, renter_id } = req.body;

  const { data, error } = await supabase
      .from("Listing")
      .upsert({
        listing_id: listing_id,
        tenant: renter_id,
        isPublished: false,
      });

  if (error) {
      return res.status(400).json({ message: "Failed, update listing tenant", error });
  }

  return res.status(200).json({ message: "Success, update listing tenant", data });
});

app.delete("/api/accept-invitation-part-2", async (req, res) => {
  const { renter_id } = req.body;

  const { data, error } = await supabase
      .from("Invitations")
      .delete()
      .eq("renter_id", renter_id);

  if (error) {
      return res.status(400).json({ message: "Failed, delete invitation", error });
  }

  return res.status(200).json({ message: "Success, delete invitation", data });
});

app.put("/api/accept-invitation-part-3", async (req, res) => {
  const { renter_id , property_id } = req.body;

  const { data, error } = await supabase
      .from("Property_Renter_JoinTable")
      .upsert({
        renter_id: renter_id, 
        property_id: property_id,
      });

  if (error) {
      return res.status(400).json({ message: "Failed, inserted joint table", error });
  }
  return res.status(200).json({ message: "Success, inserted joint table", data });
});

app.put("/api/accept-invitation-part-4", async (req, res) => {
  const { renter_id , listing_id } = req.body;

  const { data, error } = await supabase
      .from("Renters")
      .upsert({
        user_id: renter_id,
        listing_id: listing_id,
        isAccommodating: true,
      });

  if (error) {
      return res.status(400).json({ message: "Failed, inserted joint table", error });
  }
  return res.status(200).json({ message: "Success, inserted joint table", data });
});

app.get("/api/get-tenants/:property_id", async (req, res) => {
  const { property_id } = req.params;

  const { data, error } = await supabase
      .from("Property_Renter_JoinTable")
      .select("renter_id")
      .eq("property_id", property_id);

  if (error) {
      return res.status(400).json({ message: "Failed, get tenants", error });
  }
  return res.status(200).json({ message: "Success, get tenants", data });
});

app.put("/api/remove-tenant-part-1", async (req, res) => {
  const { listing_id } = req.body;

  try {
    const { data, error } = await supabase
    .from("Listing")
    .update({
      isPublished: true,
      tenant: null,
    })
    .eq("listing_id", listing_id);

    res.status(200).json({ message: 'Tenant removed and listing published.' });
  } catch (error) {
    console.error('Error removing tenant:', error);
    res.status(500).json({ message: 'Error removing tenant', error });
  }
});

app.put("/api/remove-tenant-part-2", async (req, res) => {
  const { renter_id } = req.body;

  try {
    const { data, error } = await supabase
    .from("Renters")
    .update({
      isAccommodating: false,
      listing_id: null,
    })
    .eq("user_id", renter_id);

    res.status(200).json({ message: 'renter row updated.' });
  } catch (error) {
    console.error('Error removing tenant:', error);
    res.status(500).json({ message: 'Error removing tenant', error });
  }
});

app.delete("/api/remove-tenant-part-3", async (req, res) => {
  const { property_id, renter_id } = req.body;

  try {
    const { data, error } = await supabase
    .from("Property_Renter_JoinTable")
    .delete()
    .eq("property_id", property_id)
    .eq("renter_id", renter_id);

    res.status(200).json({ message: 'Tenant in Property_Renter_JoinTable.' });
  } catch (error) {
    console.error('Error removing tenant:', error);
    res.status(500).json({ message: 'Error removing tenant', error });
  }
});

app.post("/api/upload-review", async (req, res) => {
  const { rating, comment, listing_id, user_id } = req.body;

  try {
    const { data, error } = await supabase
      .from("Reviews")
      .insert([
        {
          rating: rating,
          comment: comment,
          listing_id: listing_id,
          user_id: user_id,
        },
      ]);

    if (error) {
      throw error;
    }

     const { data: reviewsData, error: reviewsError } = await supabase
          .from("Reviews")
          .select("rating")
          .eq("listing_id", listing_id);

        if (reviewsError) {
          throw reviewsError;
        }

    const totalRatings = reviewsData.length;
    const sumRatings = reviewsData.reduce((sum, review) => sum + review.rating, 0);
    const averageRating = sumRatings / totalRatings;

    const { data: updateData, error: updateError } = await supabase
      .from("Listing")
      .upsert({
        listing_id: listing_id,
        rating: averageRating,
      });

    if (updateError) {
      throw updateError;
    }

    res.status(200).json({ message: "Review uploaded successfully", data });
  } catch (error) {
    console.error("Error uploading review:", error);
    res.status(500).json({ message: "Error uploading review", error });
  }
});

app.get("/api/check-user-review/:listing_id/:user_id", async (req, res) => {
  const { listing_id, user_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Reviews")
      .select("*")
      .eq("listing_id", listing_id)
      .eq("user_id", user_id)

    if (error) {
      throw error;
    }

    if (data.length > 0) {
      res.status(200).json({ message: "User has already reviewed this listing", data });
    } else {
      res.status(404).json({ message: "User has not reviewed this listing" });
    }
  } catch (error) {
    console.error("Error checking review:", error);
    res.status(500).json({ message: "Error checking review", error });
  }
});

app.put("/api/update-renter-information/:user_id", async (req, res) => {

  const { user_id } = req.params;
  const { username, contact_no, profile_pic } = req.body;

  console.log('Request Body:', req.body);

  try {
    const { data, error } = await supabase
    .from("Renters")
    .upsert({
      user_id: user_id,
      username: username,
      contact_no: contact_no,
      profile_pic: profile_pic,
    });

    if (error) {
      console.error('update Error:', error.message);
      return res.status(500).json({ error: error.message });
    }
    res.status(200).json({ message: "Renter Updated Successfully", data });
  } catch (error) {
    console.error('Error updating row:', error);
    res.status(500).json({ message: 'Error updating row:', error });
  }
});

app.put("/api/update-owner-information/:user_id", async (req, res) => {

  const { user_id } = req.params;
  const { username, contact_no, profile_pic } = req.body;

  try {
    const { data, error } = await supabase
    .from("Owners")
    .update({
      username: username,
      contact_no: contact_no,
      profile_pic: profile_pic,
    })
    .eq("user_id", user_id);

    res.status(200).json({ message: 'owner row updated.' });
  } catch (error) {
    console.error('Error updating row:', error);
    res.status(500).json({ message: 'Error updating row:', error });
  }
});

app.get("/api/get-saved-searches-with-userid/:user_id", async (req, res) => {
  const { user_id } = req.params;

  try {
    const { data, error } = await supabase
      .from("Saved_Searches")
      .select("*")
      .eq("user_id", user_id)

    if (error) {
      throw error;
    }

    if (data.length > 0) {
      res.status(200).json({ message: "Fetched User saved searches", data });
    } else {
      res.status(404).json({ message: "User has no saved searches" });
    }
  } catch (error) {
    console.error("Error fetching saved searches:", error);
    res.status(500).json({ message: "Error fetching saved searches: ", error });
  }
}); 

app.post("/api/add-saved-search", async (req, res) => {
  const { user_id, search_criteria, title, lat, long } = req.body;

  const location = `POINT(${long} ${lat})`;

  try {
    const { data, error } = await supabase
      .from("Saved_Searches")
      .insert([{ 
        search_criteria: search_criteria,
        user_id: user_id,
        title: title,
        location: location,
      }]);

    if (error) {
      throw error;
    }

  } catch (error) {
    console.error("Error adding saved search:", error);
    res.status(500).json({ message: "Error adding saved search: ", error });
  }
});

app.delete("/api/delete-saved-search", async (req, res) => {
  const { id } = req.body;

  try {
    const { data, error } = await supabase
      .from("Saved_Searches")
      .delete()
      .eq("id", id);

    if (error) {
      console.error('Error deleting saved search:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.status(200).json({ message: 'Saved Search deleted successfully' });

  } catch (error) {
    console.error("Error deleting saved search:", error);
    res.status(500).json({ message: "Error deleting saved search: ", error });
  }
});


app.post("/api/report-listing", async (req, res) => {
  const { reported_by, listing_id, reason, details } = req.body;

  try {
    const { data, error } = await supabase
      .from("Reports")
      .insert([
        {
          reported_by: reported_by,
          listing_id: listing_id,
          reason: reason,
          details: details,
          status: "pending"
        }
      ]);

    if (error) {
      throw error;
    }

    res.status(200).json({ message: "Report submitted successfully", data });
  } catch (error) {
    console.error("Error submitting report:", error);
    res.status(500).json({ message: "Error submitting report", error });
  }
});

app.get("/api/get-all-unpublished-listings", async (req, res) => {
    try {
      const { data, error } = await supabase
        .from('Listing')
        .select('*')
        .eq('isPublished', false);

      if (error) return res.status(500).json({ error: error });

      res.status(200).json(data);
    } catch (err) {
      res.status(500).json({ error: err });
    }
  });

app.listen(2000, () => {
  console.log("connected at server port 2000");
});
