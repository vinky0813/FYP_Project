import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

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

  static Future<User?> checkInvitation(String listing_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/get-invitation-with-listing_id/$listing_id");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        developer.log("Successfully invitation found");

        final jsonResponse = jsonDecode(response.body)["data"];

        developer.log("check invitation : $jsonResponse");

        if (jsonResponse == null) {
          return null;
        }

        final user_id = jsonResponse["renter_id"];

        User user = await getUserById(user_id);
        return user;
      } else {
        developer.log("Failed, cannot decode user: ${response.body}");
        return null;
      }
    } catch (error) {
      developer.log("Error user not found: $error");
      return null;
    }
  }

  static Future<bool> removeInvitation(String listing_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/delete-invitations/$listing_id");

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        developer.log("Successfully invitation deleted");
        return true;
      } else {
        developer.log("Failed : ${response.body}");
        return false;
      }
    } catch (error) {
      developer.log("Error invitation not found: $error");
      return false;
    }
  }

  static Future<bool> sendInvitation(String listing_id, String owner_id, String renter_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/add-invitation");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "listing_id": listing_id,
          "owner_id": owner_id,
          "renter_id": renter_id,
        }),
      );

      if (response.statusCode == 200) {
        developer.log("Successfully invitation sent");
        return true;
      } else {
        developer.log("Failed to send invitation: ${response.body}");
        return false;
      }
    } catch (error) {
      developer.log("Error : $error");
      return false;
    }
  }

  static Future<bool> checkRenterId(String renter_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/check-renter/$renter_id");

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        developer.log("Successfully, renter is ok: ${response.body}");
        return true;
      } else {
        developer.log("Failed , renter is not ok: ${response.body}");
        return false;
      }
    } catch (error) {
      developer.log("Error renter not found: $error");
      return false;
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