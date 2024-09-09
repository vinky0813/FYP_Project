import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/property_listing.dart';
import 'package:fyp_project/models/review.dart';
import 'package:fyp_project/models/user.dart';

class Property {
  String property_id;
  String property_title;
  Owner owner;
  String address;
  String imageUrl;

  Property({
    required this.property_id,
    required this.property_title,
    required this.owner,
    required this.address,
    required this.imageUrl,
  });

  static List<Property> getPropertyList() {
    List<Property> propertyList = [];

    propertyList.add(Property(
        property_id: "1",
        property_title: "property_title",
        owner: Owner(id: "id", name: "name", contact_no: "contact_no", profile_pic: "profile_pic"),
        address: "address",
        imageUrl: "https://via.placeholder.com/150"));

    propertyList.add(Property(
        property_id: "1",
        property_title: "property_title",
        owner: Owner(id: "id", name: "name", contact_no: "contact_no", profile_pic: "profile_pic"),
        address: "address",
        imageUrl: "https://via.placeholder.com/150"));

    return propertyList;
  }
  static List<PropertyListing> getPropertyListing() {
    List<PropertyListing> propertyListing = [];

    propertyListing.add(
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
          property_id: "1",
        )
    );

    propertyListing.add(
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
          property_id: "1",
        )
    );
    return propertyListing;
  }

}

