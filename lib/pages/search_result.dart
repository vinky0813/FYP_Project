import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fyp_project/SearchController.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/widgets/SearchBarLocation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/boolean_variable.dart';
import '../models/property_listing.dart';

class SearchResult extends StatefulWidget {
  final SearchResultController searchResultController =
      Get.find<SearchResultController>();
  SearchResult({super.key});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  bool _isAscending = true;
  TextEditingController titleController = TextEditingController();
  String? userId;

  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    developer.log('User: $user');
    developer.log('User ID: $userId');
  }

  String? convertFilterDataToJson() {
    final Map<String, dynamic>? filterDataValue = widget.searchResultController.filterData.value;

    if (filterDataValue == null) {
      return null;
    }

    final Map<String, dynamic> processedData = Map.from(filterDataValue);

    if (processedData.containsKey("max_price") &&
        processedData["max_price"] is double &&
        !processedData["max_price"].isFinite) {
      processedData["max_price"] = null;
    }

    if (processedData.containsKey("amenities")) {
      processedData["amenities"] = (processedData["amenities"] as List)
          .map((item) => item is BooleanVariable ? item.toJson() : item)
          .toList();
    }
    developer.log("encoding json:  ${jsonEncode(processedData)}");
    return jsonEncode(processedData);
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
        "search result length: ${widget.searchResultController.searchResult.length}");
    return Scaffold(
      appBar: appBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SearchBarLocation(),
          ),
          SliverToBoxAdapter(
              child: Row(children: [
            SizedBox(
              width: 30,
            ),
            IconButton(
              icon: Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              ),
              onPressed: () {
                setState(() {
                  if (_isAscending) {
                    _isAscending = !_isAscending;
                    widget.searchResultController.searchResult
                        .sort((a, b) => a.price.compareTo(b.price));
                  } else {
                    _isAscending = !_isAscending;
                    widget.searchResultController.searchResult
                        .sort((a, b) => b.price.compareTo(a.price));
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.saved_search),
              onPressed: () => {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Saved Search"),
                        content:
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Title",
                            ),
                            maxLength: 50,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                          ),
                        actions: [
                          TextButton(
                              onPressed: () => {
                                    Navigator.of(context).pop(),
                                  },
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () async => {
                                Navigator.of(context).pop(),
                                await PropertyListing.addSavedSearch(
                                  userId!, convertFilterDataToJson(),
                                    titleController.text, widget.searchResultController.locationLat.value,
                                    widget.searchResultController.locationLong.value),
                                },
                              child: Text("Confirm"))
                        ],
                      );
                    })
              },
            ),
          ])),
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
                        margin:
                            EdgeInsets.only(left: 20, right: 20, bottom: 10),
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
                                    widget.searchResultController
                                        .searchResult[index].image_url[0],
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
                                  widget.searchResultController
                                      .searchResult[index].listing_title,
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
                          () => Listingdetails(
                              propertyListing: widget
                                  .searchResultController.searchResult[index]),
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
      title: const Text(
        "Search Result",
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
