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
      profilePic: json["profile_pic"] ?? "https://via.placeholder.com/150",
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
}