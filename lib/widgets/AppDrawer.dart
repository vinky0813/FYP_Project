import 'package:flutter/material.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:get/get.dart';

import '../models/property_listing.dart';
import '../models/user.dart';

class AppDrawer extends StatelessWidget {

  User? user = null;

  void _getUser() {
    user = User.getUser();
  }
  PropertyListing _getCurrentProperty() {
    return User.getCurrentProperty();
  }

  @override
  Widget build(BuildContext context) {
    _getUser();
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(width: 20),
                  Text(
                    user!.username,
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
                          propertyListing: _getCurrentProperty()),
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
                Get.offAll(() => Login());
              },
            ),
          ),
        ],
      ),
    );
  }
}
