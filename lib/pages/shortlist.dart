import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
      drawer: drawer(),
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
              return Container(
                height: 140,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffE5E4E2),
                ),
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            "Picture Here",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
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
                              shortlist[index].property_title,
                              style: TextStyle(
                                fontSize: 12,
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
              );
            },
              childCount: shortlist.length,
            ),
          ),
        ],
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(child:
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    // place profile pic here, use image: imagedecoration)
                  ),
                ),
                SizedBox(width: 20),
                const Text("Account Name here",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),),
              ],
            ),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                )
            ),
          ),
          ListTile(
            title: Text("Homepage"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
          ListTile(
            title: Text("Saved Searches"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
          ListTile(
            title: Text("Shortlist"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
          ListTile(
            title: Text("Chat"),
            // placeholder, code here to update the page
            onTap: () => {},
          ),
          ListTile(
            title: Text("My Room"),
            // placeholder, code here to update the page
            onTap: () => {},
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
