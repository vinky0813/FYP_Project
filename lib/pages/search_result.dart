import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:fyp_project/pages/search_result_filter.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';

import '../models/property_listing.dart';

class SearchResult extends StatelessWidget {
  SearchResult({super.key});

  List<PropertyListing> searchResult = [];

  void _getSearchResult() {
    searchResult = PropertyListing.getSearchResult();
  }

  @override
  Widget build(BuildContext context) {
    _getSearchResult();
    return Scaffold(
      appBar: appBar(),
      drawer: AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: searchBar(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10),
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
                      ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            searchResult[index].property_title,
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
                  Get.to(() => Listingdetails(propertyListing: searchResult[index]),
                  transition: Transition.circularReveal,
                  duration: const Duration(seconds: 1));
                },);
              },
              childCount: searchResult.length,
            ),
          ),
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

      // action is right side of the app bar
      actions: [IconButton(
        // placeholder icon fix later
        icon: const Icon(Icons.account_tree_outlined),
        // same thing here
        onPressed: () => {},
      )
      ],
    );
  } // end of appBar method

  Container searchBar() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(30, 30, 30, 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Color(0xff000000),
                      blurRadius: 2
                  )
                ]
            ),
            child: TextField(
              onSubmitted: (value) {
                print("update listview for search result");
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search Here",
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide.none
                ),
                prefixIcon: Icon(Icons.search),
                suffixIcon: Container(
                  width: 100,
                  child: Padding(
                    padding: EdgeInsets.only(right: 7),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const VerticalDivider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                          IconButton(
                            // placeholder icon fix later
                            icon: const Icon(Icons.filter_alt),
                            // same thing here
                            onPressed: () => {
                              Get.to(() => SearchResultFilter(),
                              transition: Transition.circularReveal,
                              duration: const Duration(seconds: 1))
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(width: 30,),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => {},
              ),
              IconButton(
                icon: const Icon(Icons.saved_search),
                onPressed: () => {},
              ),
            ],
          ),
        ],
      ),
    );
  }

}
