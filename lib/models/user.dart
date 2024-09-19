import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:fyp_project/models/boolean_variable.dart';
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
  String? listing_id;

  User({
    required this.id,
    required this.username,
    required this.profilePic,
    required this.contactDetails,
    required this.sex,
    required this.nationality,
    required this.isAccommodating,
    this.listing_id
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["user_id"],
      username: json["username"],
      profilePic: json["profile_pic"],
      contactDetails: json["contact_no"],
      sex: json["sex"],
      nationality: json["nationality"],
      isAccommodating: json["isAccommodating"],
      listing_id: json["listing_id"],
    );
  }

  static Future<User> getUserById(String user_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/get-renter-with-id/$user_id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse["data"].isNotEmpty) {
        return User.fromJson(jsonResponse["data"]);
      } else {
        throw Exception("No user found");
      }
    } else {
      throw Exception('Failed to load user');
    }
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
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description: "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [BooleanVariable(name: "isWifiAccess", value: false,),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),],
      reviews: [
        Review(
          rating: 5,
          comment: "comment placeholder comment placeholder comment placeholder", review_id: '', user_id: '', listing_id: '',
        ),
        Review(
          rating: 4,
          comment: "comment placeholder comment placeholder comment placeholder", review_id: '', user_id: '', listing_id: '',
        ),
        Review(
          rating: 3,
          comment: "comment placeholder comment placeholder comment placeholder", review_id: '', user_id: '', listing_id: '',
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
      room_type: "single", isPublished: true, isVerified: false,
    );
  }

}