import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/saved_search.dart';
import 'package:fyp_project/pages/search_result.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import '../SearchController.dart';
import '../models/boolean_variable.dart';
import '../models/property_listing.dart';

class SavedSearches extends StatefulWidget {
  SavedSearches({super.key});

  @override
  State<SavedSearches> createState() => _SavedSearchesState();
}

class _SavedSearchesState extends State<SavedSearches> {
  List<SavedSearch> savedSearches = [];
  String? userId;
  List<Map<String, dynamic>> filterDataList = [];
  final SearchResultController searchResultController = Get.find<SearchResultController>();

  Future<void> _getSavedSearches() async {
    savedSearches = await PropertyListing.getSavedSearches(userId!);
  }

  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    developer.log('User: $user');
    developer.log('User ID: $userId');

    if (userId != null) {
        await _getSavedSearches();

        for (var temp in savedSearches) {

          if (temp.search_criteria == "") {
            developer.log('Saved Search ID: ${temp.id} has no criteria.');
            filterDataList.add({
              "min_price": null,
              "max_price": double.infinity,
              "sex_preference": "no preference",
              "nationality_preference": "no preference",
              "room_type": "all rooms",
              "amenities": []
            });
            continue;
          }

          final criteria = jsonDecode(temp.search_criteria);
          double? minPrice = criteria["min_price"]?.toDouble();
          double? maxPrice = criteria["max_price"]?.toDouble() ?? double.infinity;

          String sexPreference = criteria["sex_preference"] ?? "no preference";
          String nationalityPreference = criteria["nationality_preference"] ?? "no preference";
          String roomType = criteria["room_type"] ?? "all rooms";

          List<BooleanVariable> amenities = [];
          if (criteria["amenities"] != null) {
            for (var amenity in criteria["amenities"]) {
              amenities.add(BooleanVariable(
                name: amenity["name"],
                value: amenity["value"] ?? false,
              ));
            }
          }

          developer.log('Saved Search ID: ${temp.id}');
          developer.log('Title: ${temp.title}');
          developer.log('Min Price: $minPrice');
          developer.log('Max Price: $maxPrice');
          developer.log('Sex Preference: $sexPreference');
          developer.log('Nationality Preference: $nationalityPreference');
          developer.log('Room Type: $roomType');

          for (var amenity in amenities) {
            developer.log('Amenity: ${amenity.name}, Value: ${amenity.value}');
          }

          final filterData = {
            "min_price": minPrice,
            "max_price": maxPrice,
            "sex_preference": sexPreference,
            "nationality_preference": nationalityPreference,
            "room_type": roomType,
            "amenities": [
              BooleanVariable(name: "isWifiAccess", value: amenities[0].value),
              BooleanVariable(name: "isAirCon", value: amenities[1].value),
              BooleanVariable(name: "isNearMarket", value: amenities[2].value),
              BooleanVariable(name: "isCarPark", value: amenities[3].value),
              BooleanVariable(name: "isNearMRT", value: amenities[4].value),
              BooleanVariable(name: "isNearLRT", value: amenities[5].value),
              BooleanVariable(
                  name: "isPrivateBathroom", value: amenities[6].value),
              BooleanVariable(name: "isGymnasium", value: amenities[7].value),
              BooleanVariable(
                  name: "isCookingAllowed", value: amenities[8].value),
              BooleanVariable(
                  name: "isWashingMachine", value: amenities[9].value),
              BooleanVariable(name: "isNearBusStop", value: amenities[10].value),
            ]
          };

          filterDataList.add(filterData);
        }

        setState(() {
          savedSearches;
          filterDataList;
        });

    }
  }

  Future<void> _onSearchSubmitted(SavedSearch savedSearch, Map<String, dynamic> filterData) async {

    try {
      final response = await http.get(
        Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=${savedSearch.lat!}&lon=${savedSearch.long!}&format=json"),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        searchResultController.updateLocation(jsonResponse["display_name"]);
      } else {
        print('Failed to get address: ${response.body}');
      }
    } catch (e) {
      print('Error fetching address: $e');
    }

    List<PropertyListing> searchResult = await PropertyListing.getSearchResult(savedSearch.lat!, savedSearch.long!);
    searchResultController.updateLocationLat(savedSearch.lat!);
    searchResultController.updateLocationLong(savedSearch.long!);

    developer.log("search result length 2: ${searchResult.length}");

    List<PropertyListing> filteredResults = [];

    for (PropertyListing listing in searchResult) {
      developer.log("room type: ${listing.room_type}");
      if (filterData != null) {
        double? minPrice = filterData?["min_price"];
        double? maxPrice = filterData?["max_price"];

        if ((minPrice != null && listing.price < minPrice) ||
            (maxPrice != null && listing.price > maxPrice)) {
          developer.log("filtered by price");
          continue;
        }
      }

      if (filterData != null && filterData?["nationality_preference"] != null) {
        String preferredNationality = filterData?["nationality_preference"];
        developer.log(preferredNationality);

        if (preferredNationality != "no preference" && listing.nationality_preference != preferredNationality) {
          developer.log("filtered by nationality");
          continue;
        }
      }

      if (filterData != null && filterData?["sex_preference"] != null) {
        String preferredSex = filterData?["sex_preference"];
        developer.log(preferredSex);

        if (preferredSex != "no preference" && listing.sex_preference != preferredSex) {
          developer.log("filtered by sex");
          continue;
        }
      }

      if (filterData != null && filterData?["room_type"] != "") {
        String preferredRoomType = filterData?["room_type"];
        if (listing.room_type != preferredRoomType) {
          developer.log("filtered by room type");
          continue;
        }
      }

      if (filterData != null && filterData?["amenities"] != null) {
        List<BooleanVariable> requiredAmenities = List<BooleanVariable>.from(filterData?["amenities"]);

        for (var amenity in requiredAmenities) {
          String amenityName = amenity.name;
          bool amenityValue = amenity.value;

          var listingAmenity = listing.amenities.firstWhere(
                  (element) => element.name == amenityName, orElse: () => BooleanVariable(name: "", value: false));

          if (amenityValue && !listingAmenity.value) {
            developer.log("filtered by amenities");
            continue;
          }
        }
      }
      filteredResults.add(listing);
    }

    searchResultController.updateSearchResult(filteredResults);

    Get.to(() => SearchResult(),
    transition: Transition.circularReveal,
    duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  const Text("Saved Searches",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                  const SizedBox(width: 50,),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: SizedBox(height: 16,)
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return GestureDetector(
                onTap: () async {
                  await _onSearchSubmitted(savedSearches[index], filterDataList[index]);
                },
                child: Container(
                  height: 150,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xffE5E4E2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  savedSearches[index].title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  "Room Type: ${filterDataList[index]["room_type"]}",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "Price Range: ${filterDataList[index]["min_price"]} - ${filterDataList[index]["max_price"]}",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "Amenities: ${filterDataList[index]['amenities'] is List<BooleanVariable>
                                      ? (filterDataList[index]['amenities'] as List<BooleanVariable>)
                                      .where((BooleanVariable amenity) => amenity.value)
                                      .map((BooleanVariable amenity) => amenity.name)
                                      .join(', ')
                                      : 'None'}",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Remove Item"),
                                                content: Text("Are you sure you want to remove this saved search?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () => {
                                                        Navigator.pop(context),
                                                      },
                                                      child: Text("Cancel")),
                                                  TextButton(
                                                      onPressed: () => {
                                                        Navigator.pop(context),
                                                        PropertyListing.deleteSavedSearch(savedSearches[index].id),
                                                        setState(() {
                                                          savedSearches.removeAt(index);
                                                          filterDataList.removeAt(index);
                                                        })
                                                      },
                                                      child: Text("Remove"))
                                                ],
                                              );
                                            });
                                      },
                                      icon: Icon(Icons.remove_circle_outline)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
              childCount: savedSearches.length,
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text("INTI Accommodation Finder",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  } }
