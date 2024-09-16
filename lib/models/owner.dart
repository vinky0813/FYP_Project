import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class Owner {
  String id;
  String username;
  String contact_no;
  String profile_pic;

  Owner({
    required this.id,
    required this.username,
    required this.contact_no,
    required this.profile_pic,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json["user_id"],
      username: json["username"],
      contact_no: json["contact_no"],
      profile_pic: json["profile_pic"] ?? "https://via.placeholder.com/150",
    );
  }

  static Future<Owner> getOwnerWithId(String ownerId) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/get-owner-with-id/$ownerId");

    final response = await http.get(
      url, headers: {"Accept": "application/json"}
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Owner.fromJson(data);
    } else {
      throw Exception("Cannot find owner");
    }
  }
}

