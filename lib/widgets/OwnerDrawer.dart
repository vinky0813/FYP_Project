import 'package:flutter/material.dart';
import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/manage_property.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;


class Ownerdrawer extends StatelessWidget {

  Ownerdrawer({super.key});

  Future<Owner?> _fetchOwner() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;

    developer.log('User: $user');
    developer.log('User ID: $userId');

    if (userId != null) {
      try {
        return await Owner.getOwnerWithId(userId);
      } catch (e) {
        developer.log('Error fetching owner: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          FutureBuilder<Owner?>(
              future: _fetchOwner(),
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
                  final owner = snapshot.data!;
                  return SizedBox(
                    height: 150,
                    child: DrawerHeader(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(owner.profile_pic),
                          ),
                          SizedBox(width: 20),
                          Text(
                            owner.username,
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
