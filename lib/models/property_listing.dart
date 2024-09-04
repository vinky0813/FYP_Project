import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/review.dart';

class PropertyListing {
  String property_title;
  double rating;
  List<String> image_url;
  double price;
  double deposit;
  String description;
  String address;
  String sex_preference;
  String nationality_preference;
  List<String> amenities;
  Owner owner;
  List<Review> reviews;

  PropertyListing({
    required this.property_title,
    required this.rating,
    required this.image_url,
    required this.price,
    required this.deposit,
    required this.description,
    required this.address,
    required this.sex_preference,
    required this.nationality_preference,
    required this.amenities,
    required this.owner,
    required this.reviews,
  });

  static List<PropertyListing> getTopRatedListing() {
    List<PropertyListing> topRatedList = [];

    topRatedList.add(
      PropertyListing(
        property_title: "property1",
        rating: 5.0,
        image_url: ["image_url"],
        price: 1000,
        deposit: 100,
        description: "placeholder description placeholder description placeholder description placeholder description ",
        address: "placeholder address placeholder address placeholder address placeholder address ",
        sex_preference: "all",
        nationality_preference: "malaysian",
        amenities: ["placeholder","placeholder","placeholder"],
        owner: Owner(
            name: "OWNER NAME",
            contact_no: "PHONE NUMBER"
        ),
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
      )
    );
    topRatedList.add(
        PropertyListing(
          property_title: "property2",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    topRatedList.add(
        PropertyListing(
          property_title: "property3",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    topRatedList.add(
        PropertyListing(
          property_title: "property4",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    topRatedList.add(
        PropertyListing(
          property_title: "property5",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    return topRatedList;
  }

  static List<PropertyListing> getMostViewedListing() {
    List<PropertyListing> mostViewedListing = [];

    mostViewedListing.add(
        PropertyListing(
          property_title: "property6",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    mostViewedListing.add(
        PropertyListing(
          property_title: "property7",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    mostViewedListing.add(
        PropertyListing(
          property_title: "property8",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    mostViewedListing.add(
        PropertyListing(
          property_title: "property9",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    mostViewedListing.add(
        PropertyListing(
          property_title: "property10",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    return mostViewedListing;
  }

  static List<PropertyListing> getSearchResult() {
    List<PropertyListing> searchResultListing = [];

    searchResultListing.add(
        PropertyListing(
          property_title: "property6",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    searchResultListing.add(
        PropertyListing(
          property_title: "property7",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    searchResultListing.add(
        PropertyListing(
          property_title: "property8",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    searchResultListing.add(
        PropertyListing(
          property_title: "property9",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    searchResultListing.add(
        PropertyListing(
          property_title: "property10",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    return searchResultListing;
  }

  static List<PropertyListing> getShortlist() {
    List<PropertyListing> shortlist = [];

    shortlist.add(
        PropertyListing(
          property_title: "property6",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    shortlist.add(
        PropertyListing(
          property_title: "property7",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    shortlist.add(
        PropertyListing(
          property_title: "property8",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    shortlist.add(
        PropertyListing(
          property_title: "property9",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    shortlist.add(
        PropertyListing(
          property_title: "property10",
          rating: 5.0,
          image_url: ["image_url"],
          price: 1000,
          deposit: 100,
          description: "placeholder description placeholder description placeholder description placeholder description ",
          address: "placeholder address placeholder address placeholder address placeholder address ",
          sex_preference: "all",
          nationality_preference: "malaysian",
          amenities: ["placeholder","placeholder","placeholder"],
          owner: Owner(
              name: "OWNER NAME",
              contact_no: "PHONE NUMBER"
          ),
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
        )
    );
    return shortlist;
  }
}