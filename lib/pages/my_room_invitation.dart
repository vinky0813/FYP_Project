import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/user.dart' as project_user;
import 'package:fyp_project/pages/my_room.dart';
import 'package:fyp_project/pages/my_room_invitation_details.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/property.dart';
import '../models/property_listing.dart';

class MyRoomInvitation extends StatefulWidget {
  MyRoomInvitation({super.key});

  @override
  State<MyRoomInvitation> createState() => _MyRoomInvitationState();
}

class _MyRoomInvitationState extends State<MyRoomInvitation> {
  List<PropertyListing> invitations = [];
  String? userId;
  project_user.User? renter = null;
  List<Property> propertyList = [];

  Future<void> _getUser(String user_id) async {
    try {
      renter = await project_user.User.getUserById(user_id);
    } catch (e) {
      developer.log("Error fetching user: $e");
      renter = null;
    }
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

    await _getInvitation();

    developer.log("invitations length: ${invitations.length}");

    for (PropertyListing invitation in invitations) {
      Property property = await Property.getPropertyWithId(invitation.property_id);
      propertyList.add(property);
    }


    setState(() {
      invitations;
    });

    if (userId != null) {
      try {
        _getUser(userId!);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> _getInvitation() async {
    invitations = await PropertyListing.getInvitations(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("My Room - Invitations",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),),
            ),
          ),
          SliverToBoxAdapter(
              child: SizedBox(height: 16,)
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Container(
                height: 140,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffE5E4E2),
                ),
                child: GestureDetector(
                  onTap: () {
                    final result = Get.to(() => MyRoomInvitationDetails(propertyListing: invitations[index],),
                        transition: Transition.circularReveal,
                        duration: const Duration(seconds: 1));

                    if (result != null) {
                      if (result == false) {
                        setState(() {
                          invitations.removeAt(index);
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green,
                            ),
                            child: Image.network(
                              invitations[index].image_url[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitations[index].listing_title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "From: ${propertyList[index].owner.username}",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              );
            },
              childCount: invitations.length,
            ),
          ),
        ],
      ),
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
    );
  } }

