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

  Property({
    required this.property_id,
    required this.property_title,
    required this.owner,
    required this.address,
    required this.imageUrl,
  });

  factory Property.fromJson(Map<String, dynamic> json, Owner owner) {

    return Property(
      property_id: json["property_id"],
      property_title: json["property_title"],
      owner: owner,
      address: json["address"],
      imageUrl: json["property_image"],
    );
  }

  static Future<List<Property>> getOwnerProperties(Owner owner) async {

    final url = Uri.parse("http://10.0.2.2:2000/api/get-all-owner-properties")
        .replace(queryParameters: {"owner_id": owner.id});
    final response = await http.get(url, headers: {"Accept": "application/json"});
    
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
          my_user.User(
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
          my_user.User(
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
    return propertyListing;
  }

}

