import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/pages/ListingDetails.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/search_result.dart';
import 'package:fyp_project/pages/search_result_filter.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:get/get.dart';

import '../models/owner.dart';
import '../models/property_listing.dart';
import '../models/review.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  List<PropertyListing> topRatedPropertyListing = [];
  List<PropertyListing> mostViewedPropertyListing = [];

  void _getTopRatedListing() {
    topRatedPropertyListing = PropertyListing.getTopRatedListing();
  }

  void _getMostViewedPropertyListing() {
    mostViewedPropertyListing = PropertyListing.getMostViewedListing();
  }

  final PropertyListing propertyListing = PropertyListing(
      property_title: "PALCEHOLDER",
      rating: 5,
      image_url: ["https://via.placeholder.com/150","https://via.placeholder.com/150","https://via.placeholder.com/150"],
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
    ],);

  @override
  Widget build(BuildContext context) {
    _getTopRatedListing();
    _getMostViewedPropertyListing();
    return Scaffold(
      appBar: appBar(),
      drawer: drawer(),
      body: ListView(
        children: [
          searchBar(),
          quickAccess(),
          topRatedListView(),
          mostViewedListView(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(child:
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    // place profile pic here, use image: imagedecoration)
                  ),
                ),
                SizedBox(width: 20),
                const Text("Account Name here",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),),
              ],
            ),
            decoration: const BoxDecoration(
              color: Colors.grey,
            )
            ),
          ),
          ListTile(
            title: Text("Homepage"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
          ListTile(
            title: Text("Saved Searches"),
            // placeholder, code here to update the page
            onTap: () => {
              Get.to(() => SavedSearches(),
              transition: Transition.circularReveal,
              duration: const Duration(seconds: 1))
            },
          ),
          ListTile(
            title: Text("Shortlist"),
            // placeholder, code here to update the page
            onTap: () => {
              Get.to(() => Shortlist(),
              transition: Transition.circularReveal,
              duration: const Duration(seconds: 1))
            },
          ),
          ListTile(
            title: Text("Chat"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
          ListTile(
            title: Text("My Room"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
        ],
      ),
    );
  }

  Column mostViewedListView() {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height:20,),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("Most Viewed",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
              SizedBox(height: 12,),
              Container(
                height: 200,
                child: ListView.separated(
                  itemCount: mostViewedPropertyListing.length,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  separatorBuilder: (context, index) {
                    return SizedBox(width: 30);
                  },
                  itemBuilder: (context, index) {
                    // https://stackoverflow.com/questions/62112115/how-to-hide-a-container-on-scroll-flutter
                    return Container(
                      width: 156,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE5E4E2),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => Listingdetails(propertyListing: propertyListing),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
                        },
                        child: Column(
                          children: [
                            // take as much space as possible
                            Expanded(
                              child: Stack(
                                alignment: FractionalOffset.bottomCenter,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: Container(
                                      color: Colors.green,
                                      child: Center(
                                        child: Text(
                                          "PICTURE HERE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                mostViewedPropertyListing[index].property_title,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      )
                    );
                  },
                ),
              )
            ]
        );
  }

  Column topRatedListView() {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height:10,),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text("Top Rated",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
              SizedBox(height: 12,),
              Container(
                height: 200,
                child: ListView.separated(
                  itemCount: topRatedPropertyListing.length,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  separatorBuilder: (context, index) {
                    return SizedBox(width: 30);
                  },
                  itemBuilder: (context, index) {
                    // https://stackoverflow.com/questions/62112115/how-to-hide-a-container-on-scroll-flutter
                    return Container(
                      width: 156,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          // take as much space as possible
                          Expanded(
                            child: Stack(
                              alignment: FractionalOffset.bottomCenter,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Container(
                                    color: Colors.green,
                                    child: Center(
                                      child: Text(
                                        "PICTURE HERE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              topRatedPropertyListing[index].property_title,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ]
        );
  }

  Column quickAccess() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Quick Access",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(height: 5,),
            Container(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    alignment: Alignment.center,
                    width: 125,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius:BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Saved Searches",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      )),
                    ),
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      alignment: Alignment.center,
                      width: 125,
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Shortlist",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      alignment: Alignment.center,
                      width: 125,
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Chat",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

      // action is right side of the app bar
      actions: [IconButton(
        // placeholder icon fix later
        icon: const Icon(Icons.account_tree_outlined),
        // same thing here
        onPressed: () => {},
      )],
    );
  } // end of appBar method

  Container searchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0xff000000),
                blurRadius: 2
            )
          ]
      ),
      child: TextField(
        onSubmitted: (value) {
          Get.to(() => SearchResult(),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 1));
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Search Here",
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: BorderSide.none
          ),
          prefixIcon: Icon(Icons.search),
          suffixIcon: Container(
            width: 100,
            child: Padding(
              padding: EdgeInsets.only(right: 7),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const VerticalDivider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    IconButton(
                      // placeholder icon fix later
                      icon: const Icon(Icons.filter_alt),
                      // same thing here
                      onPressed: () => {
                        Get.to(() => SearchResultFilter(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1))
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
