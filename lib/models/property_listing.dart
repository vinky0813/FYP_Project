import 'dart:convert';
import 'dart:ffi';

import 'package:fyp_project/models/owner.dart';
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

  static Property getProperty() {
    return Property(
        property_id: "1",
        property_title: "property title",
        owner: Owner(
            username: "name",
            contact_no: "contact_no",
            profile_pic: "profile_pic",
            id: "1"),
        address: "ADDRESS ADDRESS ADDRESS ADDRESS ADDRESS",
        imageUrl: "https://via.placeholder.com/150");
  }

  static List<PropertyListing> getTopRatedListing() {
    List<PropertyListing> topRatedList = [];

    topRatedList.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    topRatedList.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    topRatedList.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    topRatedList.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    topRatedList.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    return topRatedList;
  }

  static List<PropertyListing> getMostViewedListing() {
    List<PropertyListing> mostViewedListing = [];

    mostViewedListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    mostViewedListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    mostViewedListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    mostViewedListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    mostViewedListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    return mostViewedListing;
  }

  static List<PropertyListing> getSearchResult() {
    List<PropertyListing> searchResultListing = [];

    searchResultListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    searchResultListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    searchResultListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    searchResultListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    searchResultListing.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    return searchResultListing;
  }

  static List<PropertyListing> getShortlist() {
    List<PropertyListing> shortlist = [];

    shortlist.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    shortlist.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    shortlist.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    shortlist.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    shortlist.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    return shortlist;
  }

  static List<PropertyListing> getInvitation() {
    List<PropertyListing> invitations = [];

    invitations.add(PropertyListing(
      listing_id: "randomid",
      listing_title: "property2",
      rating: 5.0,
      image_url: ["image_url"],
      price: 1000,
      deposit: 100,
      description:
          "placeholder description placeholder description placeholder description placeholder description ",
      sex_preference: "all",
      nationality_preference: "malaysian",
      amenities: [
        BooleanVariable(
          name: "isWifiAccess",
          value: false,
        ),
        BooleanVariable(name: "isAirCon", value: false),
        BooleanVariable(name: "isNearMarket", value: false),
        BooleanVariable(name: "isCarPark", value: false),
        BooleanVariable(name: "isNearMRT", value: false),
        BooleanVariable(name: "isNearLRT", value: false),
        BooleanVariable(name: "isPrivateBathroom", value: false),
        BooleanVariable(name: "isGymnasium", value: false),
        BooleanVariable(name: "isCookingAllowed", value: false),
        BooleanVariable(name: "isWashingMachine", value: false),
        BooleanVariable(name: "isNearBusStop", value: false),
      ],
      reviews: [
        Review(
          rating: 5,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 4,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
        Review(
          rating: 3,
          comment:
              "comment placeholder comment placeholder comment placeholder",
          review_id: '',
          user_id: '',
          listing_id: '',
        ),
      ],
      tenant: User(
        username: "username",
        profilePic: "profilePic",
        contactDetails: "contactDetails",
        sex: "sex",
        nationality: "nationality",
        isAccommodating: false,
        id: "1",
      ),
      property_id: "1",
      room_type: "single",
      isPublished: true,
      isVerified: false, view_count: 0,
    ));
    return invitations;
  }
}
