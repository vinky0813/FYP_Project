import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/SearchController.dart';
import 'package:fyp_project/models/user.dart' as project_user;
import 'package:fyp_project/pages/account_page.dart';
import 'package:fyp_project/pages/chat_list.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../AccessTokenController.dart';
import '../models/property_listing.dart';
import 'package:fyp_project/widgets/SearchBarLocation.dart';

final GlobalKey<SearchBarLocationState> searchBarKey = GlobalKey<SearchBarLocationState>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  project_user.User? renter = null;
  List<PropertyListing> topRatedPropertyListing = [];
  List<PropertyListing> mostViewedPropertyListing = [];
  String? userId;
  PropertyListing? currentListing = null;

  final searchResultController = Get.put<SearchResultController>(SearchResultController());

  Future<void> _getTopRatedListing() async {
    topRatedPropertyListing = await PropertyListing.getTopRatedListing();

    setState(() {
      topRatedPropertyListing;
    });
  }

  Future<void> _getMostViewedPropertyListing() async {
    mostViewedPropertyListing = await PropertyListing.getMostViewedListing();

    setState(() {
      mostViewedPropertyListing;
    });
  }

  Future<void> _getUser(String user_id) async {
    try {
      renter = await project_user.User.getUserById(user_id);
    } catch (e) {
      developer.log("Error fetching user: $e");
      renter = null;
    }

    developer.log("renter id in get user ${renter!.id}");
  }

  Future<PropertyListing?> _getCurrentProperty() async {

    developer.log("listing id: ${renter!.listing_id}");
    if (renter!.listing_id!=null) {
      developer.log("listing id: ${renter!.listing_id}");
      return await PropertyListing.getCurrentProperty(renter!.listing_id);
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(Accesstokencontroller());

    _initialize();
  }

  Future<void> _setFcmToken(String fcmToken) async {
    await Supabase.instance.client
        .from('profiles')
        .upsert({
      "id": userId,
      "fcm_token": fcmToken,
    });
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user!.id;

    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      if (event.event ==AuthChangeEvent.signedIn) {
        await FirebaseMessaging.instance.requestPermission();

        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          _setFcmToken(fcmToken);
        }
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await _setFcmToken(fcmToken);
    });

    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification != null) {
        Get.snackbar("${notification.title}", "${notification.body}");
      }
    });


    developer.log('User: $user');
    developer.log('User ID: $userId');

    if (userId != null) {
      try {
        developer.log("IF SOMETHING GOES WRONG HERE. THAT MEANS START YOUR NODE SERVER");
        await _getUser(userId!);
        await _getTopRatedListing();
        await _getMostViewedPropertyListing();

        developer.log("is renter accommodating: ${renter!.isAccommodating}");

        if(renter!.isAccommodating == true) {
          currentListing = await _getCurrentProperty();
        }

        developer.log("current listing: ${currentListing!.listing_id}");
        developer.log("current listing: ${currentListing!.property_id}");

        developer.log("top rated listing length in initalizer: ${topRatedPropertyListing.length}");
        developer.log("top rated listing: ${topRatedPropertyListing}");

      } catch (e) {
        developer.log('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          SearchBarLocation(),
          quickAccess(),
          topRatedListView(),
          mostViewedListView(),
          const SizedBox(height: 40),
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
              const SizedBox(height: 12,),
              Container(
                height: 200,
                child: ListView.separated(
                  itemCount: mostViewedPropertyListing.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 30);
                  },
                  itemBuilder: (context, index) {
                    // https://stackoverflow.com/questions/62112115/how-to-hide-a-container-on-scroll-flutter
                    return GestureDetector(child: Container(
                      width: 156,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          // take as much space as possible
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                mostViewedPropertyListing[index].image_url[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              mostViewedPropertyListing[index].listing_title,
                              style: const TextStyle(
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
              const SizedBox(height: 12,),
              Container(
                height: 200,
                child: ListView.separated(
                  itemCount: topRatedPropertyListing.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 30);
                  },
                  itemBuilder: (context, index) {
                    // https://stackoverflow.com/questions/62112115/how-to-hide-a-container-on-scroll-flutter
                    return GestureDetector(child: Container(
                      width: 156,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          // take as much space as possible
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                topRatedPropertyListing[index].image_url[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              topRatedPropertyListing[index].listing_title,
                              style: const TextStyle(
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
            const SizedBox(height: 5,),
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
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
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
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
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
                    child: GestureDetector(
                      child: Container(
                      alignment: Alignment.center,
                      width: 125,
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:BorderRadius.circular(10)
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Chat",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            )),
                      ),
                    ),
                    onTap: () {
                      Get.to(() => ChatListPage(),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
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
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("My Room",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            )),
                      ),
                    ),
                    onTap: () {
                      if (renter!.isAccommodating) {
                        Get.to(() => MyRoom(
                            propertyListing: currentListing),
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
        icon: const Icon(Icons.account_box),
        // same thing here
        onPressed: () => {
          Get.to(() => const AccountPage(userType: "renter",),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 1))
        },
      )],
    );
  }
 // end of appBar method
}
