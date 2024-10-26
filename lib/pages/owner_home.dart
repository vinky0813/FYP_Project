import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/account_page.dart';
import 'package:fyp_project/pages/chat_list.dart';
import 'package:fyp_project/pages/manage_property.dart';
import 'package:fyp_project/widgets/OwnerDrawer.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../AccessTokenController.dart';
import '../models/owner.dart';
import '../models/property_listing.dart';
import '../widgets/ListingCard.dart';

class DashboardOwner extends StatefulWidget {

  const DashboardOwner({super.key});

  @override
  State<DashboardOwner> createState() => _DashboardOwnerState();
}

class _DashboardOwnerState extends State<DashboardOwner> {

  String? userId;
  Owner? owner;
  int number_of_listing = 0;
  int number_of_published_listing = 0;
  int number_of_tenants = 0;
  int number_of_verified_listing = 0;
  List<PropertyListing> all_listing = [];

  void initState() {
    super.initState();
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
    Get.put(Accesstokencontroller());
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
        final fetchedOwner = await Owner.getOwnerWithId(userId!);

        developer.log("fetched owner ${fetchedOwner.toString()}");

        setState(() {
          owner = fetchedOwner;
        });

        developer.log(owner!.username);
      } catch (e) {
        print('Error: $e');
      }

      try {
        final propertyList = await Property.getOwnerProperties(owner!);

        for (var property in propertyList) {
          String propertyId = property.property_id;

          developer.log("property id: ${property.property_id}");

          List<dynamic> tempList = await PropertyListing.getPropertyListing(propertyId);

          for (var listing in tempList) {

            developer.log("listing id: ${listing.listing_id}");
            developer.log("listing isPublished: ${listing.isPublished}");
            developer.log("listing isVerified: ${listing.isVerified}");
            developer.log("listing tenant: ${listing.tenant != null}");

            all_listing.add(listing);

            number_of_listing++;

            developer.log("$number_of_listing");

            if (listing.isPublished == true) {
              number_of_published_listing++;
            }

            if (listing.tenant != null) {
              number_of_tenants++;
            }
            if (listing.isVerified == true) {
              number_of_verified_listing++;
            }
          }
        }
        all_listing.sort((a, b) => b.view_count.compareTo(a.view_count));

        setState(() {
          number_of_listing;
          number_of_published_listing;
          number_of_tenants;
          number_of_verified_listing;
          all_listing;
        });

      } catch (e) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("INTI Accommodation Finder"),
        centerTitle: true,
        actions: [IconButton(
          // placeholder icon fix later
          icon: const Icon(Icons.account_box),
          // same thing here
          onPressed: () => {
            Get.to(() => AccountPage(userType: "owner",),
            transition: Transition.circularReveal,
            duration: const Duration(seconds: 1))
          },
        )],
      ),
      drawer: Ownerdrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InformationCard(),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Most Viewed Listing",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 200, child: mostViewedListing(all_listing)), // Graph here
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Bottom buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Get.to(() =>ManageProperty(),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
                    },
                    child: Text("Manage Property", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Get.to(() =>ChatListPage(),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
                    },
                    child: Text("Chat", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container InformationCard() {
    return Container(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of Listings",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$number_of_listing",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                                  ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of Published Listing",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$number_of_published_listing",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of Tenants",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$number_of_tenants",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 200,
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Number of Verified Listings",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$number_of_verified_listing",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget mostViewedListing(List<PropertyListing> all_listing) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: all_listing.length,
        itemBuilder: (context, index) {
          return ListingCard(listing: all_listing[index]);
        },
      ),
    );
  }
}
