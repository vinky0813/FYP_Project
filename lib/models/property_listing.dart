import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/models/review.dart';
import 'package:fyp_project/models/user.dart';

class PropertyListing {
  String listing_title;
  double rating;
  List<String> image_url;
  double price;
  String room_type;
  double deposit;
  String description;
  String sex_preference;
  String nationality_preference;
  List<String> amenities;
  String property_id;
  List<Review> reviews;
  User? tenant;

  PropertyListing({
    required this.listing_title,
    required this.rating,
    required this.image_url,
    required this.price,
    required this.room_type,
    required this.deposit,
    required this.description,
    required this.sex_preference,
    required this.nationality_preference,
    required this.amenities,
    required this.property_id,
    required this.reviews,
    required this.tenant,
  });

  static Property getProperty() {
    return Property(
        property_id: "1",
        property_title: "property title",
        owner: Owner(name: "name", contact_no: "contact_no", profile_pic: "profile_pic", id: "1"),
        address: "ADDRESS ADDRESS ADDRESS ADDRESS ADDRESS",
        imageUrl: "https://via.placeholder.com/150");
  }

  static List<PropertyListing> getTopRatedListing() {
    List<PropertyListing> topRatedList = [];

    topRatedList.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1", room_type: "single",
        )
    );
    topRatedList.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    topRatedList.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    topRatedList.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    topRatedList.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    return topRatedList;
  }

  static List<PropertyListing> getMostViewedListing() {
    List<PropertyListing> mostViewedListing = [];

    mostViewedListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    mostViewedListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    mostViewedListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    mostViewedListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    mostViewedListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    return mostViewedListing;
  }

  static List<PropertyListing> getSearchResult() {
    List<PropertyListing> searchResultListing = [];

    searchResultListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    searchResultListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    searchResultListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    searchResultListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    searchResultListing.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    return searchResultListing;
  }

  static List<PropertyListing> getShortlist() {
    List<PropertyListing> shortlist = [];

    shortlist.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    shortlist.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    shortlist.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    shortlist.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    shortlist.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    return shortlist;
  }

  static List<PropertyListing> getInvitation() {
    List<PropertyListing> invitations = [];

    invitations.add(
        PropertyListing(
          listing_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          reviews: [
            Review(
              rating: 5,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 4,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
            Review(
              rating: 3,
              comment: "comment placeholder comment placeholder comment placeholder",
            ),
          ],
          tenant:
          User(
            username: "username",
            profilePic: "profilePic",
            contactDetails: "contactDetails",
            sex: "sex",
            nationality: "nationality",
            isAccommodating: false,
            id: "1",),
          property_id: "1",room_type: "single",
        )
    );
    return invitations;
  }
}