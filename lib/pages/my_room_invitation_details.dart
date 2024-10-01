import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/my_room.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/boolean_variable.dart';
import '../models/property_listing.dart';
import 'dart:developer' as developer;
import '../models/user.dart' as project_user;

class MyRoomInvitationDetails extends StatefulWidget {
  final PropertyListing propertyListing;
  MyRoomInvitationDetails({super.key, required this.propertyListing});

  @override
  MyroomState createState() => MyroomState();
}

class MyroomState extends State<MyRoomInvitationDetails> {
  int _currentIndex = 0;
  List<Widget> body = [];
  List<project_user.User> tenantList = [];
  Property? property;
  bool _isLoading = true;
  String? userId;
  project_user.User? renter = null;

  Future<void> _getTenants() async {

    final tempList = await project_user.User.getTenants(property!.property_id);
    setState(() {
      tenantList = tempList;
    });
  }

  void _rejectInvitation() {
    PropertyListing.rejectInvitation(
        widget.propertyListing.listing_id, userId!);
  }

  Future<void> _acceptInvitation() async {
    await PropertyListing.acceptInvitation(userId!, widget.propertyListing.listing_id,
        widget.propertyListing.property_id);
    await Supabase.instance.client
        .from('Group_Members')
        .insert({
      'group_id': property!.group_id,
      'user_id': userId,
    });
  }

  Future<void> _getUser(String user_id) async {
    try {
      renter = await project_user.User.getUserById(user_id);
    } catch (e) {
      developer.log("Error fetching user: $e");
      renter = null;
    }
  }

  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    developer.log('User: $user');
    developer.log('User ID: $userId');

    developer.log("property id: ${widget.propertyListing.property_id}");
    property =
        await Property.getPropertyWithId(widget.propertyListing.property_id);

    await _getTenants();

    setState(() {
      tenantList;
      property;
      _isLoading = false;
    });

    if (userId != null) {
      try {
        _getUser(userId!);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: _getBody(),
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: Stack(
        children: [
          Positioned(
              bottom: 80,
              right: 0,
              child: FloatingActionButton(
                heroTag: "rejectButton",
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Reject Invitation"),
                          content: Text(
                              "Are you sure you want to reject this invitation?"),
                          actions: [
                            TextButton(
                                onPressed: () => {
                                      Navigator.of(context).pop(),
                                    },
                                child: Text("Cancel")),
                            TextButton(
                                onPressed: () => {
                                      Navigator.of(context).pop(),
                                      _rejectInvitation(),
                                      Get.back(result: false)
                                    },
                                child: Text("Reject"))
                          ],
                        );
                      });
                },
                child: Text(
                  "Reject",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              )),
          Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                heroTag: "acceptButton",
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Accept Invitation"),
                          content: Text(
                              "Are you sure you want to acceot this invitation?"),
                          actions: [
                            TextButton(
                                onPressed: () => {
                                      Navigator.of(context).pop(),
                                    },
                                child: Text("Cancel")),
                            TextButton(
                                onPressed: () => {
                                      Navigator.of(context).pop(),
                                      _acceptInvitation(),
                                  developer.log("passing to my room: ${widget.propertyListing.listing_id}"),
                                      Get.off(
                                          () => MyRoom(
                                                propertyListing:
                                                    widget.propertyListing,
                                              ),
                                          transition: Transition.circularReveal,
                                          duration: const Duration(seconds: 1))
                                    },
                                child: Text("Accept"))
                          ],
                        );
                      });
                },
                child: Text(
                  "Accept",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ))
        ],
      ),
    );
  }

  //https://youtu.be/VfUUOI6BUtE?si=yAhaupWJhH8CTQeU
  Widget _getBody() {
    List<BooleanVariable> trueAmenities =
        widget.propertyListing.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);
    if (_isLoading) {
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
                  "${widget.propertyListing.rating}/5 (${widget.propertyListing.reviews.length})",
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
              child: Row(
                children: [
                  Align(
                    child: Text("Review",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerLeft,
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
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
      case 3:
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Tenants",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
              height: 16,
            )),
            tenantList.isEmpty
                ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No Tenants",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Container(
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                              tenantList[index].profilePic),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${tenantList[index].username}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                childCount: tenantList.length,
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
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Tenants",
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
        "My Room",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  } // end of appBar method
}
