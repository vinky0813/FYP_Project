import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../models/property_listing.dart';

class SearchResultFilter extends StatefulWidget {
  @override
  _SearchResultFilterState createState() => _SearchResultFilterState();
}
  class _SearchResultFilterState extends State<SearchResultFilter> {
  List<PropertyListing> searchResult = [];

  void _getSearchResult() {
    searchResult = PropertyListing.getSearchResult();
  }

  // room type
  bool isMasterRoom = false;
  bool isSingleRoom = false;
  bool isSharedRoom = false;
  bool isSuite = false;

  // ammenities
  bool isWifiAccess = false;
  bool isAirCon = false;
  bool isNearMarket = false;
  bool isCarPark = false;
  bool isNearMRT = false;
  bool isNearLRT = false;
  bool isPrivateBathroom = false;
  bool isGymnasium = false;
  bool isCookingAllowed = false;
  bool isWashingMachine = false;
  bool isNearBusStop = false;

  @override
  Widget build(BuildContext context) {
    _getSearchResult();
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        children: [
          PriceFilter(),
          RoomTypeFilter(),
          PreferenceFilter(),
          AmenitiesFilter(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Reset all filters
            isMasterRoom = false;
            isSingleRoom = false;
            isSharedRoom = false;
            isSuite = false;
            isWifiAccess = false;
            isAirCon = false;
            isNearMarket = false;
            isCarPark = false;
            isNearMRT = false;
            isNearLRT = false;
            isPrivateBathroom = false;
            isGymnasium = false;
            isCookingAllowed = false;
            isWashingMachine = false;
            isNearBusStop = false;
          });
        },
        child: Icon(Icons.refresh,
        color: Colors.white,),
        backgroundColor: Colors.black,
      ),
    );
  }

  Column AmenitiesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text("Amenities",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),),
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Wifi Access"),
                value: isWifiAccess,
                onChanged: (bool? value) {
                  setState(() {
                    isWifiAccess = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Private Bathroom"),
                value: isPrivateBathroom,
                onChanged: (bool? value) {
                  setState(() {
                    isPrivateBathroom = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Gymnasium"),
                value: isGymnasium,
                onChanged: (bool? value) {
                  setState(() {
                    isGymnasium = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Air Con"),
                value: isAirCon,
                onChanged: (bool? value) {
                  setState(() {
                    isAirCon = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Near Market"),
                value: isNearMarket,
                onChanged: (bool? value) {
                  setState(() {
                    isNearMarket = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Cooking Allowed"),
                value: isCookingAllowed,
                onChanged: (bool? value) {
                  setState(() {
                    isCookingAllowed = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Near Train Station"),
                value: isNearMRT,
                onChanged: (bool? value) {
                  setState(() {
                    isNearMRT = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Near Bus Stop"),
                value: isNearBusStop,
                onChanged: (bool? value) {
                  setState(() {
                    isNearBusStop = value!;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text("Car Park"),
                value: isCarPark,
                onChanged: (bool? value) {
                  setState(() {
                    isCarPark = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text("Washing Machine"),
                value: isWashingMachine,
                onChanged: (bool? value) {
                  setState(() {
                    isWashingMachine = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column PreferenceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 5),
          child: Text("Preference",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),),
        ),
        SizedBox(height: 5,),
        Padding(
          padding: const EdgeInsets.only(left: 20, right:20, bottom: 20, top:5),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Gender",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: "male", child: Text("Male")),
                    DropdownMenuItem(value: "female", child: Text("Female")),
                  ],
                  onChanged: (gender) {
                    print(gender);
                  },
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Nationality",
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: "malaysian", child: Text("Malaysian")),
                    DropdownMenuItem(value: "non-malaysian", child: Text("Non Malaysian")),
                  ],
                  onChanged: (nationality) {
                    print(nationality);
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Column RoomTypeFilter() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text("Room Type",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),),
            ),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Master Room"),
                    value: isMasterRoom,
                    onChanged: (bool? value) {
                      isMasterRoom = value!;
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Single Room"),
                    value: isSingleRoom,
                    onChanged: (bool? value) {
                      isSingleRoom = value!;
                    },
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Shared Room"),
                    value: isSharedRoom,
                    onChanged: (bool? value) {
                      isSharedRoom = value!;
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Suite"),
                    value: isSuite,
                    onChanged: (bool? value) {
                      isSuite = value!;
                    },
                  ),
                )
              ],
            ),
          ],
        );
  }

  Column PriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 5),
          child: Text("Price",
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),),
        ),
        SizedBox(height: 5,),
        Padding(
          padding: const EdgeInsets.only(left: 20, right:20, bottom: 20, top:5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Min Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Max Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text("Filter",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,

      // action is right side of the app bar
      actions: [TextButton(onPressed: () => {
        Get.back()
      },
          child: Text("Confirm"),)
      ],
    );
  }// end of appBar method

}
