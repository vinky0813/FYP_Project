import 'package:flutter/material.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property_listing.dart';
import '../models/user.dart' as project_user;
import 'dart:developer' as developer;

class AppDrawer extends StatefulWidget {


  AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  project_user.User? user = null;
  PropertyListing? currentListing = null;
  String? userId;

  Future<void> _getUser(String user_id) async {
    try {
      user = await project_user.User.getUserById(user_id);
    } catch (e) {
      developer.log("Error fetching user: $e");
      user = null;
    }
  }

  Future<project_user.User?> _fetchUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;

    developer.log('User: $user');
    developer.log('User ID: $userId');

    if (userId != null) {
      try {
        return await project_user.User.getUserById(userId);
      } catch (e) {
        developer.log('Error fetching owner: $e');
        return null;
      }
    }
    return null;
  }

  Future<PropertyListing?> _getCurrentProperty() {
    return PropertyListing.getCurrentProperty(user!.listing_id);
  }

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
        _getUser(userId!);
        currentListing = (await _getCurrentProperty())!;
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<project_user.User?>(
              future: _fetchUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 150,
                    child: DrawerHeader(
                      child: Row(
                        children: [
                          Center(child: CircularProgressIndicator()),
                          SizedBox(width: 20),
                          Text(
                            "Loading User Data",
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
                  );
                } else if (snapshot.data==null) {
                  return SizedBox(
                    height: 150,
                    child: DrawerHeader(
                      child: Row(
                        children: [
                          Center(child: CircularProgressIndicator()),
                          SizedBox(width: 20),
                          Text(
                            "Loading User Data",
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
                  );
                } else {
                  final renter = snapshot.data!;
                  return SizedBox(
                    height: 150,
                    child: DrawerHeader(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(renter.profilePic),
                          ),
                          SizedBox(width: 20),
                          Text(
                            renter.username,
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
                  );
                }
              }),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: Text("Homepage"),
                  onTap: () {
                    Get.to(() => HomePage(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: Text("Saved Searches"),
                  onTap: () {
                    Get.to(() => SavedSearches(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: Text("Shortlist"),
                  onTap: () {
                    Get.to(() => Shortlist(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: Text("Chat"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("My Room"),
                  onTap: () {
                    if (user!.isAccommodating) {
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
              title: Text("Logout",),
              onTap: () {
                Supabase.instance.client.auth.signOut();
                Get.offAll(() => Login());
              },
            ),
          ),
        ],
      ),
    );
  }
}
