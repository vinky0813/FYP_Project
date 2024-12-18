import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/property_listing.dart';

class Shortlist extends StatefulWidget {
  Shortlist({super.key});

  @override
  State<Shortlist> createState() => _ShortlistState();
}

class _ShortlistState extends State<Shortlist> {
  List<PropertyListing> shortlist = [];
  String? userId;
  bool isLoading = true;

  @override
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
        shortlist = await PropertyListing.getShortlist(userId!);

        setState(() {
          shortlist;
        });

        developer.log('shortlists: $shortlist');
      } catch (e) {
        developer.log('Error: $e');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _deleteShortlist(String user_id, String listing_id) {
    PropertyListing.deleteShortlist(user_id, listing_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : shortlist.isEmpty
          ? Center(child: Text("There are no shortlists."))
          :CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 16,)
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return GestureDetector(child: Container(
                height: 140,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffE5E4E2),
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
                          shortlist[index].image_url[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ), borderRadius: BorderRadius.circular(10),),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortlist[index].listing_title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Remove Item"),
                                            content: const Text("Are you sure you want to remove this shortlist?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => {
                                                    Navigator.of(context).pop(),
                                                  },
                                                  child: const Text("Cancel")),
                                              TextButton(
                                                  onPressed: () => {
                                                    Navigator.of(context).pop(),
                                                    _deleteShortlist(userId!, shortlist[index].listing_id),
                                                    setState(() {
                                                      shortlist.removeAt(index);
                                                    })
                                                  },
                                                  child: const Text("Remove"))
                                            ],
                                          );
                                        });
                                  },
                                  icon: const Icon(Icons.remove_circle_outline)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                final result = await Get.to(() => Listingdetails(propertyListing: shortlist[index]),
                transition: Transition.circularReveal,
                duration: const Duration(seconds: 1));

                developer.log(result.toString());
                if (result != null) {
                  if (result == false) {
                    setState(() {
                      shortlist.removeAt(index);
                    });
                  }
                }
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
    );
  } }
