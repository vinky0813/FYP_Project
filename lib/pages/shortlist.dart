import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';

import '../models/property_listing.dart';

class Shortlist extends StatelessWidget {
  Shortlist({super.key});

  List<PropertyListing> shortlist = [];

  void _getShortlist() {
    shortlist = PropertyListing.getShortlist();
  }

  @override
  Widget build(BuildContext context) {
    _getShortlist();
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Shortlist",
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
                              shortlist[index].property_title,
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
                Get.to(() => Listingdetails(propertyListing: shortlist[index]),
                transition: Transition.circularReveal,
                duration: const Duration(seconds: 1));
              },);
              
            },
              childCount: shortlist.length,
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
