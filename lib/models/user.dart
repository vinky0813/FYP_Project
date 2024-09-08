import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/property_listing.dart';
import 'package:fyp_project/models/review.dart';

class User {
  String username;
  String profilePic;
  String contactDetails;
  final String sex;
  final String nationality;
  bool isAccommodating;

  User({
    required this.username,
    required this.profilePic,
    required this.contactDetails,
    required this.sex,
    required this.nationality,
    required this.isAccommodating,
  });

  static User getUser() {
    var temp = User(
        username: "name",
        profilePic: "imageurl",
        contactDetails: "PLACEHOLDER",
        sex: "male",
        nationality: "malaysian",
        isAccommodating: false,);

    return temp;
  }
  static PropertyListing getCurrentProperty() {
    return PropertyListing(
      property_title: "property1",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description: "placeholder description placeholder description placeholder description placeholder description ",
      address: "placeholder address placeholder address placeholder address placeholder address ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: ["placeholder","placeholder","placeholder"],
      owner: Owner(
          name: "OWNER NAME",
          contact_no: "PHONE NUMBER",
          profile_pic: "https://via.placeholder.com/150"
      ),
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
      tenants: [
        User(
          username: "username",
          profilePic: "profilePic",
          contactDetails: "contactDetails",
          sex: "sex",
          nationality: "nationality",
          isAccommodating: false,),
        User(
          username: "username",
          profilePic: "profilePic",
          contactDetails: "contactDetails",
          sex: "sex",
          nationality: "nationality",
          isAccommodating: false,),
      ],
    );
  }

}