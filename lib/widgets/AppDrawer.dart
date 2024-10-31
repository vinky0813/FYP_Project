import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_project/pages/chat_list.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/property_listing.dart';
import '../models/user.dart' as project_user;
import 'dart:developer' as developer;

class AppDrawer extends StatefulWidget {


  AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  project_user.User? renter = null;
  PropertyListing? currentListing = null;
  String? userId;

  Future<project_user.User?> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');

    developer.log("userdata: $userData");

    if (userData != null) {
      renter = project_user.User.fromJson(json.decode(userData));
    } else {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;

      developer.log('User: $user');
      developer.log('User ID: $userId');

      if (userId != null) {
        renter = await project_user.User.getUserById(userId);
        await prefs.setString('user_data', json.encode(renter!.toJson()));
      }
    }
  }

  Future<PropertyListing?> _getCurrentProperty() {
    return PropertyListing.getCurrentProperty(renter!.listing_id);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    developer.log('User: $user');
    developer.log('User ID: $userId');

    if (userId != null) {
      try {
        await _fetchUser();
        if (renter!.isAccommodating) {
          currentListing = await _getCurrentProperty();
          developer.log("currentlisting: ${currentListing!.listing_id}");
        }
      } catch (e) {
        developer.log('Error: $e');
      }

      setState(() {
        currentListing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              child: renter == null
                  ? Row(
                children: const [
                  Center(child: CircularProgressIndicator()),
                  SizedBox(width: 20),
                  Text(
                    "Loading User Data",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
                  : Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(renter!.profilePic),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    renter!.username,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text("Homepage"),
                  onTap: () {
                    Get.to(() => const HomePage(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: const Text("Saved Searches"),
                  onTap: () {
                    Get.to(() => SavedSearches(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: const Text("Shortlist"),
                  onTap: () {
                    Get.to(() => Shortlist(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: const Text("Chat"),
                  onTap: () {
                    Get.to(() => ChatListPage(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: const Text("My Room"),
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
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              title: const Text("Logout",),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_data');
                Supabase.instance.client.auth.signOut();
                Get.offAll(() => const Login());
              },
            ),
          ),
        ],
      ),
    );
  }
}
