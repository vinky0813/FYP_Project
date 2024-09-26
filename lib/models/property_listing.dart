import 'dart:convert';

import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/models/review.dart';
import 'package:fyp_project/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_project;

import 'boolean_variable.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class PropertyListing {
  String listing_id;
  String listing_title;
  double rating;
  List<String> image_url;
  double price;
  String room_type;
  double deposit;
  String description;
  String sex_preference;
  String nationality_preference;
  List<BooleanVariable> amenities;
  String property_id;
  List<Review> reviews;
  User? tenant;
  bool isPublished;
  bool isVerified;
  int view_count;

  PropertyListing({
    required this.listing_id,
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
    required this.isPublished,
    required this.isVerified,
    required this.view_count,
  });

  static Future<List<PropertyListing>> getPropertyListing(String property_id) async {

    List<PropertyListing> propertyListings = [];

    developer.log("property id: ${property_id}");

    final url = Uri.parse("http://10.0.2.2:2000/api/get-all-listing/$property_id");
    try {
      final response = await http.get(url);
      developer.log(response.statusCode.toString());

      if (response.statusCode == 200) {
        final List<dynamic> listings = jsonDecode(response.body)["data"];
        developer.log("Listings Data: ${listings.runtimeType}");

        developer.log(listings.toString());
        developer.log(listings.toString());

        final List<Future<PropertyListing>> futures = listings
            .map((listingJson) => _processListing(listingJson, property_id))
            .toList();

        propertyListings = await Future.wait(futures);

        return propertyListings;

      } else {
        developer.log("Failed to load listings: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      developer.log("Error fetching listings: $e");
      return [];
    }
  }

  static Future<PropertyListing> _processListing(dynamic listingJson, String property_id) async {
    String listing_Id = listingJson["listing_id"];

    List<String> images = await _getListingImages(listing_Id);

    developer.log(images.toString());

    List<BooleanVariable> amenities = await _getAmenities(listing_Id);

    developer.log("amenities: ${amenities.toString()}");
    developer.log("amenities: ${amenities.length}");

    String room_type = _determineRoomType(amenities);

    developer.log("room type: $room_type");

    List<Review> reviews = await _getReviews(listing_Id);

    developer.log("reviews: ${reviews.toString()}");

    User? tenant;

    if (listingJson["tenant"] != null) {
      try {
        tenant = await User.getUserById(listingJson["tenant"]);
      } catch (e) {
        developer.log("Error fetching tenant: $e");
        tenant = null;
      }
    }

    developer.log("tenant: ${tenant.toString()}");

    PropertyListing propertyListingItem = PropertyListing(
      listing_id: listing_Id,
      listing_title: listingJson["listing_title"] ?? "WRONG TITLE",
      rating: listingJson["rating"].toDouble() ?? 0.0.toDouble(),
      price: listingJson["price"].toDouble() ?? 0.0.toDouble(),
      deposit: listingJson["deposit"].toDouble() ?? 0.0.toDouble(),
      description: listingJson["description"] ?? "WRONG DESCRIPTION",
      room_type: room_type,
      nationality_preference: listingJson["nationality_preference"] ?? "WRONG PREFERENCE",
      sex_preference: listingJson["sex_preference"] ?? "WRONG PREFERENCE",
      image_url: images,
      amenities: amenities,
      property_id: property_id,
      reviews: reviews,
      isPublished: listingJson["isPublished"],
      isVerified: listingJson["isVerified"],
      tenant: tenant, view_count: listingJson["view_count"],
    );

    return propertyListingItem;
  }

  static Future<List<Review>> _getReviews(String listing_Id) async {
    final reviewsResponse = await http
        .get(Uri.parse("http://10.0.2.2:2000/api/get-all-reviews/$listing_Id"));

    if (reviewsResponse.statusCode == 200) {
      final reviewsJsonResponse = jsonDecode(reviewsResponse.body);

      return List<Review>.from(
          reviewsJsonResponse["data"].map((item) => Review.fromJson(item)));
    } else if (reviewsResponse.statusCode == 404) {
      developer.log("no reviews for this listing");
      return [];
    } else {
      return [];
    }
  }

  static Future<List<String>> _getListingImages(String listing_Id) async {
    final imagesResponse = await http.get(
        Uri.parse("http://10.0.2.2:2000/api/get-listing-images/$listing_Id"));

    if (imagesResponse.statusCode == 200) {
      final imagesjsonResponse = jsonDecode(imagesResponse.body);

      developer.log("Images JSON Response: $imagesjsonResponse");

      return imagesjsonResponse.map<String>((item) => item["image_url"] as String).toList();
    } else {
      return [];
    }
  }

  static Future<List<BooleanVariable>> _getAmenities(String listing_Id) async {
    final url =
        Uri.parse("http://10.0.2.2:2000/api/get-all-amenities/$listing_Id");
    final response = await http.get(url);
    developer.log(response.body);
    if (response.statusCode == 200) {
      final amenitiesJson = jsonDecode(response.body);

      if (amenitiesJson["data"] is List) {
        final List<dynamic> amenitiesList = amenitiesJson["data"];

        final List<Map<String, dynamic>> cleanedAmenitiesList = amenitiesList.map((item) {
          if (item is Map) {
            final Map<String, dynamic> cleanedItem = Map<String, dynamic>.from(item);
            cleanedItem.remove("listing_id");
            return cleanedItem;
          }
          return <String, dynamic>{};
        }).toList();

        developer.log("CLEANED: ${cleanedAmenitiesList.toString()}");

        List<BooleanVariable> amenities = [];

        for (var item in cleanedAmenitiesList) {
          for (var pair in item.entries) {
            amenities.add(BooleanVariable(name: pair.key, value: pair.value));
          }
        }
        return amenities;
      }
    }
    return [];
  }

  static String _determineRoomType(List<BooleanVariable> amenities) {
    String room_type = "";
    if (amenities[0].value) {
      room_type = "master";
    } else if (amenities[1].value) {
      room_type = "single";
    } else if (amenities[2].value) {
      room_type = "shared";
    } else if (amenities[3].value) {
      room_type = "suite";
    }
    return room_type;
  }

  static Future<void> deleteImages(List<String> imageUrls) async {

    for (String imageUrl in imageUrls) {
      final response = await supabase_project.Supabase.instance.client.storage.from("property-images").remove([imageUrl]);

      if (response.isEmpty) {
        developer.log("Successfully deleted images: ${imageUrl}");
      } else {
        developer.log("Some images may not have been deleted: ${response.map((file) => file.name).join(', ')}");
      }
    }
  }

  static Future<void> deleteListing(String listing_id) async {

    final image_delete_url = Uri.parse("http://10.0.2.2:2000/api/delete-listing-images/$listing_id");

    try {
      final response = await http.delete(image_delete_url);

      developer.log(response.body);
      if (response.statusCode == 200) {

        final responseBody = jsonDecode(response.body);
        final imagesData = responseBody["data"] as List<dynamic>;
        final imagesToDeleteFromStorage = imagesData.map<String>((item) => item["image_url"] as String).toList();

        developer.log("Images to delete: ${imagesToDeleteFromStorage.toString()}");

        await deleteImages(imagesToDeleteFromStorage);

      } else {
        final responseBody = jsonDecode(response.body);
        developer.log("Error deleting images: ${responseBody}");
      }
    } catch (e) {
      developer.log('Unexpected error: $e');
    }

    final amenities_url = Uri.parse("http://10.0.2.2:2000/api/delete-listing-amenities/$listing_id");

    try {
      final response = await http.delete(amenities_url);

      if (response.statusCode == 200) {
        developer.log("amenities deleted successfully");
      } else {
        final responseBody = jsonDecode(response.body);
        developer.log('Error deleting listing: ${responseBody['message']}');
      }
    } catch (e) {
      developer.log('Unexpected error: $e');
    }

    final listing_url = Uri.parse("http://10.0.2.2:2000/api/delete-listing/$listing_id");

    try {
      final response = await http.delete(listing_url);

      if (response.statusCode == 200) {
        developer.log("Listing deleted successfully");
      } else {
        final responseBody = jsonDecode(response.body);
        developer.log("'Error deleting listing: ${responseBody}'");
      }
    } catch (e) {
      developer.log('Unexpected error: $e');
    }
  }

  static Future<PropertyListing?> getCurrentProperty(String? listing_id) async {

    final url = Uri.parse("http://10.0.2.2:2000/api/get-listing-with-id/$listing_id");
    try {
      final response = await http.get(url);
      developer.log(response.statusCode.toString());

      if (response.statusCode == 200) {
        final listings = jsonDecode(response.body)["data"];

        developer.log(listings.toString());

        PropertyListing propertyListing = await _processListing(listings, listings["property_id"]);

        return propertyListing;

      } else {
        developer.log("Failed to load current listing: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      developer.log("Error fetching current listing: $e");
      return null;
    }
  }

  static Future<List<PropertyListing>> getTopRatedListing() async {
    List<PropertyListing> topRatedList = [];

    final url = Uri.parse("http://10.0.2.2:2000/api/get-top-rated-listing");
    try {
      final response = await http.get(url);
      developer.log(response.statusCode.toString());

      developer.log(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> listings = jsonDecode(response.body)["data"];
        developer.log("Listings Data: ${listings.runtimeType}");

        developer.log(listings.toString());

        final List<Future<PropertyListing>> futures = listings
            .map((listingJson) => _processListing(listingJson, listingJson["property_id"]))
            .toList();

        topRatedList = await Future.wait(futures);

        developer.log("top rated list length: ${topRatedList.length}");

        return topRatedList;

      } else {
        developer.log("Failed to load top rated listings: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      developer.log("Error fetching top rated listings: $e");
      return [];
    }
  }

  static Future<List<PropertyListing>> getMostViewedListing() async {
    List<PropertyListing> mostViewedListing = [];

    final url = Uri.parse("http://10.0.2.2:2000/api/get-most-viewed-listing");
    try {
      final response = await http.get(url);
      developer.log(response.statusCode.toString());

      developer.log(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> listings = jsonDecode(response.body)["data"];
        developer.log("Listings Data: ${listings.runtimeType}");

        developer.log(listings.toString());

        final List<Future<PropertyListing>> futures = listings
            .map((listingJson) => _processListing(listingJson, listingJson["property_id"]))
            .toList();

        mostViewedListing = await Future.wait(futures);

        developer.log("most viewed list length: ${mostViewedListing.length}");

        return mostViewedListing;

      } else {
        developer.log("Failed to load most viewed listings: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      developer.log("Error fetching most viewed listings: $e");
      return [];
    }
  }

  static Future<List<PropertyListing>> getSearchResult(double lat, double long) async {
    List<PropertyListing> searchResultListing = [];

    final propertyList = await Property.getSearchedProperty(lat, long);

    for (Property property in propertyList) {
      List<PropertyListing> listings = await getPropertyListing(property.property_id);

      searchResultListing.addAll(listings);
    }
    List<PropertyListing> publishedListings = searchResultListing.where((listing) => listing.isPublished).toList();

    return publishedListings;
  }

  static Future<bool> incrementView(String listing_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/increment-view/$listing_id");
    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        developer.log("View count incremented successfully.");
        return true;
      } else {
        developer.log("Failed to increment view count. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      developer.log("Error incrementing view count: $e");
      return false;
    }
  }

  static Future<List<PropertyListing>> getShortlist(String user_id) async {
    List<PropertyListing> shortlist = [];

    final url = Uri.parse("http://10.0.2.2:2000/api/get-shortlists-with-userid/$user_id");

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body)["data"];

      developer.log("shortlist json: $jsonResponse");

      for (var item in jsonResponse) {
        String listingId = item["listing_id"];
        developer.log("Listing ID: $listingId");

        final url = Uri.parse("http://10.0.2.2:2000/api/get-listing-with-id/$listingId");

        try {
          final response = await http.get(url);
          developer.log(response.statusCode.toString());

          developer.log("response body: ${response.body}");

          if (response.statusCode == 200) {
            final listings = jsonDecode(response.body)["data"];
            developer.log("Listings Data: ${listings}");

            developer.log(listings.toString());

            PropertyListing propertyListing = await _processListing(listings, listings["property_id"]);

            shortlist.add(propertyListing);

          } else {
            developer.log("Failed to load listing: ${response.statusCode}");
            return [];
          }
        } catch (e) {
          developer.log("error, $e");
        }
      }
      return shortlist;
    } else {
      print("Failed to fetch shortlist: ${response.body}");
      return [];
    }
  }

  static Future<bool> deleteShortlist(String user_id, String listing_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/remove-shortlist");

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": user_id,
          "listing_id": listing_id,
        }),
      );

      if (response.statusCode == 200) {
        developer.log("Successfully removed listing from shortlist");
        return true;
      } else {
        developer.log("Failed to remove shortlist: ${response.body}");
        return false;
      }
    } catch (error) {
      developer.log("Error removing from shortlist: $error");
      return false;
    }
  }

  static Future<bool> addShortlist(String user_id, String listing_id) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/add-shortlist");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": user_id,
          "listing_id": listing_id,
        }),
      );

      if (response.statusCode == 200) {
        developer.log("Successfully added listing into shortlist");
        return true;
      } else {
        developer.log("Failed to add shortlist: ${response.body}");
        return false;
      }
    } catch (error) {
      developer.log("Error adding shortlist: $error");
      return false;
    }
  }

  static Future<List<PropertyListing>> getInvitations(String renter_id) async {

    List<PropertyListing> propertyListings = [];

    developer.log("renter id: ${renter_id}");

    final url = Uri.parse("http://10.0.2.2:2000/api/get-invitations-with-renter-id/$renter_id");
    try {
      final response = await http.get(url);
      developer.log(response.statusCode.toString());

      if (response.statusCode == 200) {
        final invitations = jsonDecode(response.body)["data"];

        for (var invitation in invitations) {
          String listing_id = invitation["listing_id"];
          developer.log("listing id: $listing_id");

          final url = Uri.parse("http://10.0.2.2:2000/api/get-listing-with-id/$listing_id");
          final response = await http.get(url);

          if (response.statusCode == 200) {
            final listings = jsonDecode(response.body)["data"];
            developer.log("Listings Data: ${listings}");

            developer.log(listings.toString());

            PropertyListing propertyListing = await _processListing(listings, listings["property_id"]);

            developer.log("get invitation returned length before adding: ${propertyListings.length}");
            propertyListings.add(propertyListing);

          } else {
            developer.log("Failed to load listing: ${response.statusCode}");
            return [];
          }
        }
        developer.log("get invitation returned length after adding : ${propertyListings.length}");
        return propertyListings;

      } else {
        developer.log("Failed to load listings: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      developer.log("Error fetching listings: $e");
      return [];
    }
  }

  static Future<void> acceptInvitation(String renter_id, String listing_id, String property_id) async {
    developer.log("renter id: $renter_id");
    developer.log("listing id: $listing_id");
    developer.log("property id: $property_id");
      try {
        final responsePart1 = await http.put(
          Uri.parse("http://10.0.2.2:2000/api/accept-invitation-part-1"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "listing_id": listing_id,
            "renter_id": renter_id,
          }),
        );
        if (responsePart1.statusCode != 200) {
          throw Exception("Failed at part 1: ${jsonDecode(responsePart1.body)}");
        }

        final responsePart2 = await http.delete(
          Uri.parse("http://10.0.2.2:2000/api/accept-invitation-part-2"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"renter_id": renter_id}),
        );
        if (responsePart2.statusCode != 200) {
          throw Exception("Failed at part 2: ${jsonDecode(responsePart2.body)}");
        }

        final responsePart3 = await http.put(
          Uri.parse("http://10.0.2.2:2000/api/accept-invitation-part-3"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "renter_id": renter_id,
            "property_id": property_id,
          }),
        );
        if (responsePart3.statusCode != 200) {
          throw Exception("Failed at part 3: ${jsonDecode(responsePart3.body)}");
        }

        final responsePart4 = await http.put(
          Uri.parse("http://10.0.2.2:2000/api/accept-invitation-part-4"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "renter_id": renter_id,
            "listing_id": listing_id,
          }),
        );
        if (responsePart4.statusCode != 200) {
          throw Exception("Failed at part 4: ${jsonDecode(responsePart4.body)}");
        }
        developer.log("Invitation accepted successfully!");

      } catch (e) {
        print('Error accepting invitation: $e');
      }
  }

  static Future<void> rejectInvitation(String listing_id, String renter_id) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:2000/api/delete-invitations/$listing_id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "renter_id": renter_id,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed: ${jsonDecode(response.body)["message"]}");
      }
      developer.log("Success, rejecting invite");
    } catch (e) {
      print('Error accepting invitation: $e');
    }
  }

  static Future<void> removeTenant(String listing_id, String renter_id, String property_id) async {
    try {
      final response1 = await http.put(
        Uri.parse("http://10.0.2.2:2000/api/remove-tenant-part-1"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "listing_id": listing_id,
          "renter_id": renter_id,
        }),
      );
      if (response1.statusCode != 200) {
        throw Exception("Failed: ${jsonDecode(response1.body)["message"]}");
      }

      final response2 = await http.put(
        Uri.parse("http://10.0.2.2:2000/api/remove-tenant-part-2"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "renter_id": renter_id
        }),
      );
      if (response1.statusCode != 200) {
        throw Exception("Failed: ${jsonDecode(response2.body)["message"]}");
      }

      final response3 = await http.delete(
        Uri.parse("http://10.0.2.2:2000/api/remove-tenant-part-3"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "property_id": property_id,
          "renter_id": renter_id,
        }),
      );
      if (response1.statusCode != 200) {
        throw Exception("Failed: ${jsonDecode(response3.body)["message"]}");
      }

      developer.log("Success, removed tenant");
    } catch (e) {
      print('Error accepting invitation: $e');
    }
  }
}
