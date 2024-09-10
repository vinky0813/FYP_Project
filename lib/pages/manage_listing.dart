import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/add_listing.dart';
import 'package:fyp_project/pages/listing_details_owner.dart';
import 'package:fyp_project/widgets/OwnerDrawer.dart';
import 'package:get/get.dart';

import '../models/property_listing.dart';

class ManageListing extends StatelessWidget {

  final Property property;

  ManageListing({super.key, required this.property});

  List<PropertyListing> propertyList = [];

  void _getPropertyListing() {
    propertyList = Property.getPropertyListing();
  }

  @override
  Widget build(BuildContext context) {
    _getPropertyListing();
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddListing(property: property,),
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
              child: Text("Manage Listing",
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
              return GestureDetector(child: Container(
                height: 140,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffE5E4E2),
                ),
                child: Row(
                  children: [
                    ClipRRect(child: AspectRatio(
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
                    ), borderRadius: BorderRadius.circular(10),),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyList[index].listing_title,
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
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Remove Item"),
                                            content: Text("Are you sure you want to remove this shortlist?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => {},
                                                  child: Text("Cancel")),
                                              TextButton(
                                                  onPressed: () => {},
                                                  child: Text("Remove"))
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.remove_circle_outline)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                onTap: () {
                  Get.to(() => ListingDetailsOwner(propertyListing: propertyList[index]),
                      transition: Transition.circularReveal,
                      duration: const Duration(seconds: 1));
                },);
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
      title: const Text("INTI Accommodation Finder",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,

      // action is right side of the app bar
      actions: [IconButton(
        // placeholder icon fix later
        icon: const Icon(Icons.account_tree_outlined),
        // same thing here
        onPressed: () => {},
      )],
    );
  } // end of appBar method
}
