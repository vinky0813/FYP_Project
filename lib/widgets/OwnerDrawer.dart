import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/manage_property.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../pages/chat_list.dart';


class Ownerdrawer extends StatefulWidget {

  Ownerdrawer({super.key});

  @override
  State<Ownerdrawer> createState() => _OwnerdrawerState();
}

class _OwnerdrawerState extends State<Ownerdrawer> {
  Owner? owner;

  Future<Owner?> _fetchOwner() async {
    final prefs = await SharedPreferences.getInstance();
    String? ownerData = prefs.getString('user_data');

    developer.log("Owner data: $ownerData");

    if (ownerData != null) {
      owner = Owner.fromJson(json.decode(ownerData));
    } else {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;

      developer.log('User: $user');
      developer.log('User ID: $userId');

      if (userId != null) {
        try {
          owner = await Owner.getOwnerWithId(userId);
          await prefs.setString('user_data', json.encode(owner!.toJson()));
        } catch (e) {
          developer.log('Error fetching owner: $e');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchOwner();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              child: owner == null
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
                    backgroundImage: NetworkImage(owner!.profile_pic),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    owner!.username,
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
                  title: const Text("Dashboard"),
                  onTap: () {
                    Get.to(() =>const DashboardOwner(),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));
                  },
                ),
                ListTile(
                  title: const Text("Manage Property"),
                  onTap: () {
                    Get.to(() =>ManageProperty(),
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
