import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/add_property.dart';
import 'package:fyp_project/pages/chat_page.dart';
import 'package:fyp_project/pages/manage_listing.dart';
import 'package:fyp_project/widgets/OwnerDrawer.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/owner.dart';

class ManageProperty extends StatefulWidget {
  ManageProperty({super.key});

  @override
  _ManagePropertyState createState() => _ManagePropertyState();
}

class _ManagePropertyState extends State<ManageProperty> {

  List<Property> propertyList = [];
  bool isEditing = false;
  String? userId;
  Owner? owner;

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
        owner = await Owner.getOwnerWithId(userId!);
        final properties = await Property.getOwnerProperties(owner!);

        setState(() {
          propertyList = properties;
        });

        developer.log('Properties: $propertyList');
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: Ownerdrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Property newProperty = await Get.to(() => AddProperty(isEditing: false, property: null,),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 1));

          if (newProperty != null) {
            setState(() {
              propertyList.add(newProperty);
            });
          }
        },
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Manage Property",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: SizedBox(
            height: 16,
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return GestureDetector(
                  child: Container(
                    height: 140,
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffE5E4E2),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green,
                              ),
                              child: Image.network(
                                propertyList[index].imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  propertyList[index].property_title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (isEditing==false) {
                                        Get.to(() => ChatPage(groupId: propertyList[index].group_id,
                                        ),
                                            transition: Transition.circularReveal,
                                            duration: const Duration(seconds: 1));
                                      } else {
                                        final result = await Get.to(() => AddProperty(
                                          isEditing: true,
                                          property: propertyList[index],
                                        ),
                                            transition: Transition.circularReveal,
                                            duration: const Duration(seconds: 1));

                                        developer.log("datatype is ${result.runtimeType}");
                                        developer.log("result is ${result}");

                                        if (result != null) {
                                          if (result is Property){
                                            setState(() {
                                              propertyList[index] = result;
                                            });
                                          } else if (result is bool && result == false) {
                                            setState(() {
                                              developer.log("im here ${propertyList.length}");
                                              propertyList.removeAt(index);
                                              developer.log("im here ${propertyList.length}");
                                            });
                                          }
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      isEditing
                                          ? Icons.edit
                                          : Icons.chat,
                                      color: Colors.white,
                                    ),
                                    style: IconButton.styleFrom(
                                        backgroundColor: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    if (!isEditing) {
                      Get.to(() => ManageListing(property: propertyList[index], userId: userId!, owner: owner!,),
                      transition: Transition.circularReveal,
                      duration: const Duration(seconds: 1));
                    }
                  },
                );
              },
              childCount: propertyList.length,
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text(
        "INTI Accommodation Finder",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,

      // action is right side of the app bar
      actions: [
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
        ),
      ],
    );
  }
}
