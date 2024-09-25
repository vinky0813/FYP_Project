import 'package:get/get.dart';
import 'models/property_listing.dart';

class SearchResultController extends GetxController {
  var searchResult = <PropertyListing>[].obs;

  void updateSearchResult(List<PropertyListing> newResults) {
    searchResult.value = newResults;
  }
}
