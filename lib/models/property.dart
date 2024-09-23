import 'package:fyp_project/models/boolean_variable.dart';
import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/property_listing.dart';
import 'package:fyp_project/models/review.dart';
import 'package:fyp_project/models/user.dart' as my_user;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class Property {
  String property_id;
  String property_title;
  Owner owner;
  String address;
  String imageUrl;
  double lat;
  double long;

  Property({
    required this.property_id,
    required this.property_title,
    required this.owner,
    required this.address,
    required this.imageUrl,
    required this.lat,
    required this.long,
  });

  factory Property.fromJson(Map<String, dynamic> json, Owner owner) {
    return Property(
      property_id: json["property_id"],
      property_title: json["property_title"],
      owner: owner,
      address: json["address"],
      imageUrl: json["property_image"],
      lat: json["lat"],
      long: json["long"],
    );
  }

  static Future<List<Property>> getOwnerProperties(Owner owner) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/get-all-owner-properties")
        .replace(queryParameters: {"owner_id": owner.id});
    final response = await http.get(
        url, headers: {"Accept": "application/json"});

    developer.log(owner.profile_pic);

    developer.log("what happens here: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      developer.log("data: ${data}");
      final value = data.map((json) {
        return Property.fromJson(json, owner);
      }).toList();
      developer.log("value: ${value}");

      return value;
    } else {
      throw Exception("Failed to load properties");
    }
  }
}

