import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_project/models/boolean_variable.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/chat_page.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import '../ChatService.dart';
import '../models/property_listing.dart';

class Listingdetails extends StatefulWidget {
  final PropertyListing propertyListing;
  Listingdetails({super.key, required this.propertyListing});

  @override
  ListingdetailsState createState() => ListingdetailsState();
}

class ListingdetailsState extends State<Listingdetails> {
  Property? property;
  bool isLoading = true;
  bool _isShortlisted = false;
  late List<BooleanVariable> trueAmenities;
  String? userId;

  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;
    PropertyListing.incrementView(widget.propertyListing.listing_id);
    developer.log("property id: ${widget.propertyListing.property_id}");
    property =
        await Property.getPropertyWithId(widget.propertyListing.property_id);

    developer.log("property: ${property.toString()}");

    trueAmenities =
        widget.propertyListing.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);

    developer.log("userid: $userId");

    List<PropertyListing> shortlists =
        await PropertyListing.getShortlist(userId!);

    for (PropertyListing shortlist in shortlists) {
      if (shortlist.listing_id == widget.propertyListing.listing_id) {
        _isShortlisted = true;
        break;
      }
    }
    setState(() {
      isLoading = false;
      _isShortlisted;
    });
  }

  void _deleteShortlist(String user_id, String listing_id) {
    PropertyListing.deleteShortlist(user_id, listing_id);

    Get.back(result: false);
  }

  void _addShortlist(String user_id, String listing_id) {
    PropertyListing.addShortlist(user_id, listing_id);

    Get.back();
  }

  int _currentIndex = 0;
  List<Widget> body = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(),
      body: _getBody(),
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 0,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: _showReportDialog,
              child: Icon(
                Icons.report,
                color: Colors.white,
              ),
              backgroundColor: Colors.black,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                String? groupId = await Chatservice.findOneOnOneGroupId(
                    userId!, property!.owner.id);

                if (groupId != null) {
                  Get.to(() => ChatPage(groupId: groupId));
                } else {
                  final newGroupId = await Chatservice.createGroup(
                      [userId!, property!.owner.id]);

                  if (newGroupId != null) {
                    Get.to(() => ChatPage(groupId: newGroupId));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create chat group")));
                  }
                }
              },
              child: Icon(
                Icons.chat,
                color: Colors.white,
              ),
              backgroundColor: Colors.black,
            ),
          )
        ],
      ),
    );
  }

  //https://youtu.be/VfUUOI6BUtE?si=yAhaupWJhH8CTQeU
  Widget _getBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    switch (_currentIndex) {
      case 0:
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            ImageCarousel(),
            SizedBox(height: 16),
            Text(
              widget.propertyListing.listing_title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 30,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "${widget.propertyListing.rating}/5",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text("Price: RM${widget.propertyListing.price}"),
                SizedBox(
                  width: 16,
                ),
                Text("Deposit: RM${widget.propertyListing.deposit}"),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Room Type: ${widget.propertyListing.room_type}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
                '${widget.propertyListing.description}\n\n${property!.address}'),
            SizedBox(height: 16),
            Text(
              "Preference",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text("Sex: ${widget.propertyListing.sex_preference}"),
                SizedBox(
                  width: 16,
                ),
                Text(
                    "Nationality: ${widget.propertyListing.nationality_preference}"),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Ammenities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 8,
            ),
            Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: trueAmenities.map((amenity) {
                  return Chip(
                    label: Text(amenity.name),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList()),
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      property!.owner.profile_pic), // Load the image
                ),
                SizedBox(width: 16),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Owner Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Owner Name: ${property!.owner.username}",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Contact Details: ${property!.owner.contact_no}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ))
              ],
            )
          ],
        );
      case 1:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                child: Text("Review",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.propertyListing.reviews.length,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.only(left: 20, right: 20),
                separatorBuilder: (context, index) {
                  return SizedBox(height: 30);
                },
                itemBuilder: (context, index) {
                  return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              Text(
                                  "${widget.propertyListing.reviews[index].rating}/5")
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "${widget.propertyListing.reviews[index].comment}/5",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ));
                },
              ),
            )
          ],
        );
      case 2:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Align(
                    child: Text("Map",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(property!.lat, property!.long),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(property!.lat, property!.long),
                        child: Container(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return ListView(
          children: [
            Center(
              child: Icon(Icons.account_tree_outlined),
            ),
            Center(
              child: Text("SOMETHING IS WRONG LOL"),
            )
          ],
        );
    }
  }

  CarouselSlider ImageCarousel() {
    return CarouselSlider(
      options: CarouselOptions(height: 200),
      items: widget.propertyListing.image_url.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Details",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: "Review",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: "Map",
        ),
      ],
      onTap: (int newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text(
        "Listing Details",
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
          // placeholder icon fix later
          icon: const Icon(Icons.view_list),
          onPressed: () => {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Shortlist"),
                  content: _isShortlisted
                      ? Text("Remove Shortlist")
                      : Text("Shortlist this listing"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        _isShortlisted
                            ? _deleteShortlist(
                                userId!, widget.propertyListing.listing_id)
                            : _addShortlist(
                                userId!, widget.propertyListing.listing_id);
                        _isShortlisted = _isShortlisted!;
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                );
              },
            )
          },
        )
      ],
    );
  } // end of appBar method

  void _showReportDialog() {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController detailsController = TextEditingController();
    bool isReasonFilled = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Report Listing"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reasonController,
                    maxLength: 50,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(58),
                    ],
                    decoration: InputDecoration(
                      labelText: "Reason",
                      hintText: "Enter reason for reporting",
                    ),
                    onChanged: (value) {
                      setState(() {
                        isReasonFilled = value.isNotEmpty;
                        developer.log("isreasonfilled $isReasonFilled");
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: detailsController,
                    maxLength: 200,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(200),
                    ],
                    decoration: InputDecoration(
                      labelText: "Details (Optional)",
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isReasonFilled) {
                      String reason = reasonController.text.trim();
                      String details = detailsController.text.trim();

                      developer.log(reason);
                      developer.log(details);
                      await _submitReport(reason, details);

                      Get.back();
                    }
                  },
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String reason, String details) async {

    final now = DateTime.now();
    final oneHourAgo = now.subtract(Duration(hours: 1));

    final reportRessponse = await Supabase.instance.client
        .from('Reports')
        .select('report_id')
        .eq('reported_by', userId!)
        .gte('created_at', oneHourAgo.toIso8601String());

    if ((reportRessponse as List).length >= 3) {
      developer.log("LIMIT REACHED");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You can only submit 3 reports per hour")));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:2000/api/report-listing"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "reported_by": userId,
          "listing_id": widget.propertyListing.listing_id,
          "reason": reason,
          "details": details,
        }),
      );

      if (response.statusCode == 200) {
        developer.log("Success Report submitted successfully");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Report submitted successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit report")));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred: $error")));
    }
  }
}
