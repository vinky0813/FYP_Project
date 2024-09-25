import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/SearchController.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/widgets/SearchBarLocation.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;


import '../models/property_listing.dart';

class SearchResult extends StatefulWidget {

  final SearchResultController searchResultController = Get.find<SearchResultController>();
  SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  @override
  Widget build(BuildContext context) {
    developer.log("search result length: ${widget.searchResultController.searchResult.length}");
    return Scaffold(
      appBar: appBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SearchBarLocation(),
          ),
          SliverToBoxAdapter(
              child: Row(
                  children: [
                    SizedBox(width: 30,),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () => {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.saved_search),
                      onPressed: () => {},
                    ),]
              )),
          SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),
          Obx(() {
            // Check if search results are empty
            if (widget.searchResultController.searchResult.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    "No results found.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              );
            } else {
              // Return the SliverList if results are available
              return SliverList(
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
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green,
                                  ),
                                  child: Image.network(
                                    widget.searchResultController.searchResult[index].image_url[0],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  widget.searchResultController.searchResult[index].listing_title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Get.to(
                              () => Listingdetails(propertyListing: widget.searchResultController.searchResult[index]),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1),
                        );
                      },
                    );
                  },
                  childCount: widget.searchResultController.searchResult.length,
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text("Search Result",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }
 // end of appBar method
}
