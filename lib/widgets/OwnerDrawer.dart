import 'package:flutter/material.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/manage_property.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:fyp_project/pages/saved_searches.dart';
import 'package:fyp_project/pages/shortlist.dart';
import 'package:get/get.dart';

import '../models/property_listing.dart';
import '../models/user.dart';

class Ownerdrawer extends StatelessWidget {

  User? user = null;

  Ownerdrawer({super.key});

  void _getUser() {
    user = User.getUser();
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
                  title: Text("Dashboard"),
                  onTap: () {
                    Get.to(() =>DashboardOwner(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: Text("Manage Property"),
                  onTap: () {
                    Get.to(() =>ManageProperty(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: Text("Add Room"),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text("Chat"),
                  onTap: () {},
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
