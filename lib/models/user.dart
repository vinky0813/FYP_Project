import 'package:fyp_project/models/property_listing.dart';
import 'package:fyp_project/models/review.dart';

class User {
  String id;
  String username;
  String profilePic;
  String contactDetails;
  final String sex;
  final String nationality;
  bool isAccommodating;

  User({
    required this.id,
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
        isAccommodating: false,
        id: "1",);

    return temp;
  }

  static List<User> getTenants() {
    List<User> tenantList = [];

    tenantList.add(User(
      username: "name",
      profilePic: "imageurl",
      contactDetails: "PLACEHOLDER",
      sex: "male",
      nationality: "malaysian",
      isAccommodating: false,
      id: "1",));

    tenantList.add(User(
      username: "name",
      profilePic: "imageurl",
      contactDetails: "PLACEHOLDER",
      sex: "male",
      nationality: "malaysian",
      isAccommodating: false,
      id: "1",));

    tenantList.add(User(
      username: "name",
      profilePic: "imageurl",
      contactDetails: "PLACEHOLDER",
      sex: "male",
      nationality: "malaysian",
      isAccommodating: false,
      id: "1",));
    return tenantList;
  }
  static PropertyListing getCurrentProperty() {
    return PropertyListing(
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
    );
  }

}