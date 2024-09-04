class SavedSearch {
  final String title;
  final double priceMin;
  final double priceMax;
  final String roomType;
  final List<String> amenities;

  SavedSearch({
    required this.title,
    required this.priceMin,
    required this.priceMax,
    required this.roomType,
    required this.amenities,
  });

  static List<SavedSearch> getSavedSearches() {
    List<SavedSearch> savedSearchesList = [];

    savedSearchesList.add(
        SavedSearch(
            title: "placeholder 1",
            priceMin: 1000,
            priceMax: 2000,
            roomType: "single",
            amenities: ["PLACEHOLDER","PLACEHOLDER"]
        )
    );

    savedSearchesList.add(
        SavedSearch(
            title: "placeholder 2",
            priceMin: 1000,
            priceMax: 2000,
            roomType: "single",
            amenities: ["PLACEHOLDER","PLACEHOLDER"]
        )
    );

    savedSearchesList.add(
        SavedSearch(
            title: "placeholder 3",
            priceMin: 1000,
            priceMax: 2000,
            roomType: "single",
            amenities: ["PLACEHOLDER","PLACEHOLDER"]
        )
    );

    savedSearchesList.add(
        SavedSearch(
            title: "placeholder 4",
            priceMin: 1000,
            priceMax: 2000,
            roomType: "single",
            amenities: ["PLACEHOLDER","PLACEHOLDER"]
        )
    );

    return savedSearchesList;
  }
}
