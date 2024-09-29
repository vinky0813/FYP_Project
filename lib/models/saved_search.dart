class SavedSearch {
  String id;
  String title;
  String search_criteria;
  String user_id;
  double? lat;
  double? long;

  SavedSearch({
    required this.id,
    required this.title,
    required this.search_criteria,
    required this.user_id,
    required this.lat,
    required this.long,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {

    double? latitude;
    double? longitude;

    if (json["location"] != null) {
      List<dynamic> coordinates = json["location"]["coordinates"];
      if (coordinates.isNotEmpty) {
        longitude = coordinates[0];
        latitude = coordinates[1];
      }
    }

    return SavedSearch(
      id: json["id"] as String,
      title: json["title"] as String,
      search_criteria: json["search_criteria"] as String,
      user_id: json["user_id"] as String,
      lat: latitude,
      long: longitude,
    );
  }

}