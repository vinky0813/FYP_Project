import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/add_property.dart';
import 'package:fyp_project/pages/manage_listing.dart';
import 'package:fyp_project/widgets/OwnerDrawer.dart';
import 'package:get/get.dart';

class ManageProperty extends StatefulWidget {
  ManageProperty({super.key});

  @override
  _ManagePropertyState createState() => _ManagePropertyState();
}

class _ManagePropertyState extends State<ManageProperty> {

  List<Property> propertyList = [];
  bool isEditing = false;

  void _getPropertyList() {
    propertyList = Property.getPropertyList();
  }

  @override
  Widget build(BuildContext context) {
    _getPropertyList();
    return Scaffold(
      appBar: appBar(),
      drawer: Ownerdrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddProperty(isEditing: false, property: null,),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 1));
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
                return IgnorePointer(
                  ignoring: isEditing,
                  child: GestureDetector(
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
                                  "https://via.placeholder.com/150",
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
                                      onPressed: () {
                                        if (isEditing==false) {
                                          // go to chat
                                        } else {
                                          Get.to(() => AddProperty(isEditing: true, property: propertyList[index],),
                                            transition: Transition.circularReveal,
                                            duration: const Duration(seconds: 1),);
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
                      Get.to(() => ManageListing(property: propertyList[index],),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
                    },
                  ),
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
