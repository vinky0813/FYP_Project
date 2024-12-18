import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../SearchController.dart';
import '../models/boolean_variable.dart';
import '../models/property_listing.dart';
import '../pages/search_result.dart';
import '../pages/search_result_filter.dart';
import 'dart:developer' as developer;


class SearchBarLocation extends StatefulWidget {

  @override
  SearchBarLocationState createState() => SearchBarLocationState();
}

class SearchBarLocationState extends State<SearchBarLocation> {
  final TextEditingController _searchBarController = TextEditingController();
  List<dynamic> suggestions = [];
  double? lat = 0;
  double? long = 0;
  final SearchResultController searchResultController = Get.find<SearchResultController>();
  Map<String, dynamic>? filterData;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ever(searchResultController.location, (value) {
      developer.log("update location in controller, $value");
      _searchBarController.text = value;
    });

    ever(searchResultController.filterData, (value) {
      developer.log("filter data in controller, $value");
      filterData = value;
    });
  }

  void _onSearchChanged(String value) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.isNotEmpty) {
        final response = await http.get(Uri.parse(
            "https://nominatim.openstreetmap.org/search?q=$value&format=json&addressdetails=1"));
        if (response.statusCode == 200) {
          setState(() {
            suggestions = json.decode(response.body);
          });
        } else {
          setState(() {
            suggestions = [];
          });
        }
      } else {
        setState(() {
          suggestions = [];
        });
      }
    });
  }

  void _onSearchSubmitted() async {
    String value = _searchBarController.text.trim();
    if (value.isNotEmpty) {
      final response = await http.get(Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$value&format=json&addressdetails=1"));
      if (response.statusCode == 200) {
        var results = json.decode(response.body);
        if (results.isNotEmpty) {
          setState(() {
            _isLoading = true;
          });
          lat = double.tryParse(results[0]["lat"]);
          long = double.tryParse(results[0]["lon"]);
          List<PropertyListing> searchResult = await PropertyListing.getSearchResult(lat!, long!);
          searchResultController.updateLocationLat(lat!);
          searchResultController.updateLocationLong(long!);

          searchResultController.updateUnfilteredSearchResult(searchResult);

          developer.log("search result length 2: ${searchResult.length}");

          List<PropertyListing> filteredResults = [];

          for (PropertyListing listing in searchResult) {
            bool shouldAddListing = true;

            if (filterData != null) {
              double? minPrice = filterData?["min_price"];
              double? maxPrice = filterData?["max_price"];

              if ((minPrice != null && listing.price < minPrice) ||
                  (maxPrice != null && listing.price > maxPrice)) {
                developer.log("Filtered by price");
                shouldAddListing = false;
              }

              String preferredNationality = filterData?["nationality_preference"];
              if (preferredNationality != null && preferredNationality != "no preference" &&
                  listing.nationality_preference != preferredNationality) {
                developer.log("Filtered by nationality");
                shouldAddListing = false;
              }

              String preferredSex = filterData?["sex_preference"];
              if (preferredSex != null && preferredSex != "no preference" &&
                  listing.sex_preference != preferredSex) {
                developer.log("Filtered by sex");
                shouldAddListing = false;
              }

              String preferredRoomType = filterData?["room_type"];
              if (preferredRoomType != null && preferredRoomType.isNotEmpty &&
                  listing.room_type != preferredRoomType) {
                developer.log("Filtered by room type");
                shouldAddListing = false;
              }

              if (filterData?["amenities"] != null) {
                List<BooleanVariable> requiredAmenities = List<BooleanVariable>.from(filterData?["amenities"]);
                for (var amenity in requiredAmenities) {
                  String amenityName = amenity.name;
                  if (amenity.value) {
                    var listingAmenity = listing.amenities.firstWhere(
                          (element) => element.name == amenityName,
                      orElse: () => BooleanVariable(name: amenityName, value: false),
                    );
                    if (!listingAmenity.value) {
                      developer.log("Filtered out by missing amenity: $amenityName");
                      shouldAddListing = false;
                      break;
                    }
                  }
                }
              }
            }
            if (shouldAddListing) {
              filteredResults.add(listing);
            }
          }

          searchResultController.updateSearchResult(filteredResults);
          searchResultController.updateLocation(value);

          setState(() {});

          Get.to(() => SearchResult(),
              transition: Transition.circularReveal,
              duration: const Duration(seconds: 1));
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 30, 30, 30),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchBarController,
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              _onSearchSubmitted();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter Location",
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Container(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const VerticalDivider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: () async {
                            final data = await Get.to(() =>
                                SearchResultFilter(filterData: searchResultController.filterData.value),
                                transition: Transition.circularReveal,
                                duration: const Duration(seconds: 1));
                            setState(() {
                              filterData = data;
                              searchResultController.updateFilterData(filterData);
                            });
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          // Display Autocomplete Suggestions
          if (!_isLoading && _searchBarController.text.isNotEmpty && suggestions.isNotEmpty)
            Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]["display_name"]),
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      _searchBarController.text = suggestions[index]["display_name"];
                      lat = double.tryParse(suggestions[index]["lat"]);
                      long = double.tryParse(suggestions[index]["lon"]);
                      setState(() {
                        suggestions = [];
                      });
                      List<PropertyListing> searchResult = await PropertyListing.getSearchResult(lat!, long!);
                      searchResultController.updateLocationLat(lat!);
                      searchResultController.updateLocationLong(long!);

                      searchResultController.updateUnfilteredSearchResult(searchResult);

                      developer.log("search result length: ${searchResult.length}");
                      List<PropertyListing> filteredResults = [];

                      for (PropertyListing listing in searchResult) {
                        bool shouldAddListing = true;

                        if (filterData != null) {
                          double? minPrice = filterData?["min_price"];
                          double? maxPrice = filterData?["max_price"];

                          if ((minPrice != null && listing.price < minPrice) ||
                              (maxPrice != null && listing.price > maxPrice)) {
                            developer.log("Filtered by price");
                            shouldAddListing = false;
                          }

                          String preferredNationality = filterData?["nationality_preference"];
                          if (preferredNationality != null && preferredNationality != "no preference" &&
                              listing.nationality_preference != preferredNationality) {
                            developer.log("Filtered by nationality");
                            shouldAddListing = false;
                          }

                          String preferredSex = filterData?["sex_preference"];
                          if (preferredSex != null && preferredSex != "no preference" &&
                              listing.sex_preference != preferredSex) {
                            developer.log("Filtered by sex");
                            shouldAddListing = false;
                          }

                          String preferredRoomType = filterData?["room_type"];
                          if (preferredRoomType != null && preferredRoomType.isNotEmpty &&
                              listing.room_type != preferredRoomType) {
                            developer.log("Filtered by room type");
                            shouldAddListing = false;
                          }

                          if (filterData?["amenities"] != null) {
                            List<BooleanVariable> requiredAmenities = List<BooleanVariable>.from(filterData?["amenities"]);
                            for (var amenity in requiredAmenities) {
                              String amenityName = amenity.name;
                              if (amenity.value) {
                                var listingAmenity = listing.amenities.firstWhere(
                                      (element) => element.name == amenityName,
                                  orElse: () => BooleanVariable(name: amenityName, value: false),
                                );
                                if (!listingAmenity.value) {
                                  developer.log("Filtered out by missing amenity: $amenityName");
                                  shouldAddListing = false;
                                  break;
                                }
                              }
                            }
                          }
                        }
                        if (shouldAddListing) {
                          filteredResults.add(listing);
                        }
                      }

                      developer.log("search filteredResults length: ${filteredResults.length}");
                      searchResultController.updateSearchResult(filteredResults);
                      searchResultController.updateLocation(_searchBarController.text);

                      setState(() {
                        _isLoading = false;
                      });

                      Get.to(() => SearchResult(),
                      transition: Transition.circularReveal,
                      duration: const Duration(seconds: 1));
                    },

                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
