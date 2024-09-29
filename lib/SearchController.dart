import 'package:get/get.dart';
import 'models/property_listing.dart';

class SearchResultController extends GetxController {
  var searchResult = <PropertyListing>[].obs;
  var filterData = Rxn<Map<String, dynamic>>();
  var location = ''.obs;

  void updateSearchResult(List<PropertyListing> newResults) {
    searchResult.value = newResults;
    update();
  }
  void updateFilterData(Map<String, dynamic>? newFilterData) {
    filterData.value = newFilterData;
    update();
  }

  void updateLocation(String newLocation) {
    location.value = newLocation;
    update();
  }
}
