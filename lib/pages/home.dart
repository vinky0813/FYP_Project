import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/user.dart';
import 'package:fyp_project/pages/account_page.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/search_result.dart';
import 'package:fyp_project/pages/search_result_filter.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';

import '../models/owner.dart';
import '../models/property_listing.dart';
import '../models/review.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  User? user = null;

  List<PropertyListing> topRatedPropertyListing = [];
  List<PropertyListing> mostViewedPropertyListing = [];

  void _getTopRatedListing() {
    topRatedPropertyListing = PropertyListing.getTopRatedListing();
  }

  void _getMostViewedPropertyListing() {
    mostViewedPropertyListing = PropertyListing.getMostViewedListing();
  }

  void _getUser() {
    user = User.getUser();
  }
  PropertyListing _getCurrentProperty() {
    return User.getCurrentProperty();
  }

  final PropertyListing propertyListing = PropertyListing(
    listing_title: "property2",
    rating: 5.0,
    image_url: ["image_url"],
    price: 1000,
    deposit: 100,
    description: "placeholder description placeholder description placeholder description placeholder description ",
    sex_preference: "all",
    nationality_preference: "malaysian",
    amenities: ["placeholder","placeholder","placeholder"],
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
    tenant:
    User(
      username: "username",
      profilePic: "profilePic",
      contactDetails: "contactDetails",
      sex: "sex",
      nationality: "nationality",
      isAccommodating: false,
      id: "1",),
    property_id: "1",room_type: "single",
  );

  @override
  Widget build(BuildContext context) {
    _getUser();
    _getTopRatedListing();
    _getMostViewedPropertyListing();
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
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
                    return GestureDetector(child: Container(
                      width: 156,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          // take as much space as possible
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                "https://via.placeholder.com/150",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              mostViewedPropertyListing[index].listing_title,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.to(() => Listingdetails(propertyListing: mostViewedPropertyListing[index]),
                      transition: Transition.circularReveal,
                      duration: const Duration(seconds: 1));
                    },);
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
                    return GestureDetector(child: Container(
                      width: 156,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          // take as much space as possible
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                "https://via.placeholder.com/150",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              topRatedPropertyListing[index].listing_title,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                      onTap: () {
                        Get.to(() => Listingdetails(propertyListing: topRatedPropertyListing[index]),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                      },
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
                  child: GestureDetector(child: Container(
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
                  onTap: () {
                    Get.to(() => SavedSearches(),
                    transition: Transition.circularReveal,
                    duration: const Duration(seconds: 1));
                  },)
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(child: Container(
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
                    onTap: () {
                        Get.to(() => Shortlist(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                    })
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(child: Container(
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
                    onTap: () {
                      print("PUT NAVIGATE TO CHAT HERE");
                    }
                    ,)
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(child: Container(
                      alignment: Alignment.center,
                      width: 125,
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("My Room",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            )),
                      ),
                    ),
                    onTap: () {
                      if (user!.isAccommodating) {
                        Get.to(() => MyRoom(
                            propertyListing: _getCurrentProperty()),
                            transition: Transition.circularReveal,
                            duration: const Duration(seconds: 1));
                      } else {
                        Get.to(() => MyRoomInvitation(),
                            transition: Transition.circularReveal,
                            duration: const Duration(seconds: 1));
                      }
                    },)
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
        onPressed: () => {
          Get.to(() => AccountPage(),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 1))
        },
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
