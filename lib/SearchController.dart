import 'package:fyp_project/models/boolean_variable.dart';
import 'package:get/get.dart';
import 'models/property_listing.dart';
import 'dart:developer' as developer;

class SearchResultController extends GetxController {
  var searchResult = <PropertyListing>[].obs;
  var searchResultUnfiltered = <PropertyListing>[].obs;
  var filterData = Rxn<Map<String, dynamic>>();
  var location = ''.obs;
  var locationLat = Rxn<double>();
  var locationLong = Rxn<double>();

  void updateSearchResult(List<PropertyListing> newResults) {
    searchResult.value = newResults;
    update();
  }

  void updateUnfilteredSearchResult(List<PropertyListing> newResults) {
    searchResultUnfiltered.value = newResults;
    update();
  }

  void updateFilterData(Map<String, dynamic>? newFilterData) {
    filterData.value = newFilterData;
    applyFilters();
    update();
  }

  void updateLocation(String newLocation) {
    location.value = newLocation;
    update();
  }

  void updateLocationLat(double? lat) {
    locationLat.value = lat;
    update();
  }
  void updateLocationLong(double? long) {
    locationLong.value = long;
    update();
  }
  List<PropertyListing> getFilteredResults() {
    final filter = filterData.value;

    if (filter == null) return searchResultUnfiltered;

    return searchResultUnfiltered.where((listing) {
      if (filter != null) {
        double? minPrice = filter?["min_price"];
        double? maxPrice = filter?["max_price"];

        if ((minPrice != null && listing.price < minPrice) ||
            (maxPrice != null && listing.price > maxPrice)) {
          return false;
        }

        String? preferredNationality = filter?["nationality_preference"];
        if (preferredNationality != null && preferredNationality != "no preference" &&
            listing.nationality_preference != preferredNationality) {
          return false;
        }

        String? preferredSex = filter?["sex_preference"];
        if (preferredSex != null && preferredSex != "no preference" &&
            listing.sex_preference != preferredSex) {
          return false;
        }

        String? preferredRoomType = filter?["room_type"];
        if (preferredRoomType != null && preferredRoomType.isNotEmpty &&
            listing.room_type != preferredRoomType) {
          return false;
        }

        if (filter?["amenities"] != null) {
          List<BooleanVariable> requiredAmenities = List<BooleanVariable>.from(filter?["amenities"]);
          for (var amenity in requiredAmenities) {
            if (amenity.value &&
                !listing.amenities.any((a) => a.name == amenity.name && a.value)) {
              return false;
            }
          }
        }
      }
      return true;
    }).toList();
  }

  void applyFilters() {
    searchResult.value = getFilteredResults();
    update();
  }
}
