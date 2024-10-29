import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/add_listing.dart';
import 'package:fyp_project/pages/listing_details_owner.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../models/owner.dart';
import '../models/property_listing.dart';

class ManageListing extends StatefulWidget {

  final Property property;
  final Owner owner;
  final String userId;

  ManageListing({super.key, required this.property, required this.owner, required this.userId});

  @override
  State<ManageListing> createState() => _ManageListingState();
}

class _ManageListingState extends State<ManageListing> {
  List<PropertyListing> listingList = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    if (widget.userId != null) {
      try {
        developer.log("property id ${widget.property.property_id}");
        final listings = await PropertyListing.getPropertyListing(widget.property.property_id);

        setState(() {
          listingList = listings;
        });

        developer.log("listings: $listingList");
      } catch (e) {
        developer.log('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddListing(property: widget.property, isEditing: false, propertyListing: null, ),
          transition: Transition.circularReveal,
          duration: const Duration(seconds: 1));
        },
        child: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
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
                          listingList[index].image_url[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "https://via.placeholder.com/150",
                              fit: BoxFit.cover,
                            );
                          },
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
                              listingList[index].listing_title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 18,),
                            Text(
                              "RM ${listingList[index].price.toString()}",
                              style: const TextStyle(
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              "Published: ${listingList[index].isPublished}",
                              style: const TextStyle(
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                onTap: () async {
                  final result = await Get.to(() => ListingDetailsOwner(propertyListing: listingList[index], property: widget.property,),
                      transition: Transition.circularReveal,
                      duration: const Duration(seconds: 1));

                  if (result is bool && result == false) {
                      setState(() {
                        listingList.removeAt(index);
                      });
                    }
                  }
              );
            },
              childCount: listingList.length,
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
