import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/pages/chat_page.dart';
import 'package:fyp_project/pages/user_info_page.dart';
import 'package:fyp_project/widgets/AppDrawer.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ChatService.dart';
import '../models/boolean_variable.dart';
import '../models/property_listing.dart';
import '../models/review.dart';
import '../models/user.dart' as project_user;
import 'dart:developer' as developer;

class MyRoom extends StatefulWidget {

  final PropertyListing? propertyListing;
  MyRoom({super.key, required this.propertyListing});

  @override
  MyroomState createState() => MyroomState();
}

class MyroomState extends State<MyRoom> {
  int _currentIndex = 0;
  List<Widget> body = [];
  List<project_user.User> tenantList = [];
  late List<BooleanVariable> trueAmenities;
  Property? property;
  bool _isLoading = true;
  String? userId;
  project_user.User? renter = null;
  bool isReviewed = false;

  Future<void> _getTenants() async {
    tenantList = await project_user.User.getTenants(property!.property_id);
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

    developer.log("property id: ${widget.propertyListing!.property_id}");
    property = await Property.getPropertyWithId(widget.propertyListing!.property_id);

    trueAmenities = widget.propertyListing!.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);

    isReviewed = await Review.checkUserReview(widget.propertyListing!.listing_id, userId!);

    await _getTenants();

    List<project_user.User> tenantsToRemove = [];

    for (project_user.User t in tenantList) {
      if (t.id == userId) {
        tenantsToRemove.add(t);
      }
    }

    for (var t in tenantsToRemove) {
      tenantList.remove(t);
    }

    setState(() {
      tenantList;
      property;
      trueAmenities;
      _isLoading = false;
      isReviewed;
    });

    if (userId != null) {
      try {
        _getUser(userId!);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> _getUser(String user_id) async {
    try {
      renter = await project_user.User.getUserById(user_id);
    } catch (e) {
      developer.log("Error fetching user: $e");
      renter = null;
    }
  }

  void _submitReview(double rating, String comment) async {

    final newReview = Review(
        rating: rating,
        comment: comment,
        user_id: widget.propertyListing!.tenant!.id,
        listing_id: widget.propertyListing!.listing_id);

    await Review.uploadReview(newReview);

    setState(() {
      widget.propertyListing!.reviews.add(newReview);
      isReviewed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: appBar(),
      body: _getBody(),
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => ChatPage(
            groupId: property!.group_id,
          ),
              transition: Transition.circularReveal,
              duration: const Duration(seconds: 1));
        },
        child: Icon(Icons.chat,
          color: Colors.white,),
        backgroundColor: Colors.black,
      ),
    );
  }
  //https://youtu.be/VfUUOI6BUtE?si=yAhaupWJhH8CTQeU
  Widget _getBody() {
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
            SizedBox(height:16),
            Text(widget.propertyListing!.listing_title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height:16),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 30,
                ),
                SizedBox(width: 8,),
                Text(
                  "${widget.propertyListing!.rating}/5",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                ),
              ],
            ),
            SizedBox(height: 16,),
            Row(
              children: [Text("Price: RM${widget.propertyListing!.price}"),
                SizedBox(width: 16,),
                Text("Deposit: RM${widget.propertyListing!.deposit}"),],
            ),
            SizedBox(height: 16,),
            Text(
              "Room Type: ${widget.propertyListing!.room_type}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 16,),
            Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16),
            ),
            SizedBox(height: 8,),
            Text('${widget.propertyListing!.description}\n\n${property!.address}'),
            SizedBox(height: 16),
            Text(
              "Preference",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                Text("Sex: ${widget.propertyListing!.sex_preference}"),
                SizedBox(width: 16,),
                Text("Nationality: ${widget.propertyListing!.nationality_preference}"),
              ],
            ),
            SizedBox(height: 16,),
            Text(
              "Ammenities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8,),
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
                  backgroundImage: NetworkImage(property!.owner.profile_pic), // Load the image
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
        double rating = 0;
        TextEditingController _commentController = TextEditingController();

        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Align(
                    child: Text("Review", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)),
                    alignment: Alignment.centerLeft,
                  ),
                  Spacer(),
                  isReviewed ? SizedBox(width: 0,):
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Leave a Review"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PannableRatingBar(
                                  rate: rating,
                                  items: List.generate(5, (index) =>
                                  const RatingWidget(
                                    selectedColor: Colors.yellow,
                                    unSelectedColor: Colors.grey,
                                    child: Icon(
                                      Icons.star,
                                      size: 30,
                                    ),
                                  )),
                                  onChanged: (value) {
                                    developer.log("test");
                                    setState(() {
                                      rating = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: "Write your review here",
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _submitReview(rating, _commentController.text);
                                  Navigator.of(context).pop();
                                },
                                child: Text("Submit"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Leave a Review",
                      style: TextStyle(color: Colors.white),),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.black
                    ),),
                  SizedBox(width: 20,)
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.propertyListing!.reviews.length,
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
                              Icon(Icons.star, color: Colors.yellow,),
                              Text("${widget.propertyListing!.reviews[index].rating}/5")
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "${widget.propertyListing!.reviews[index].comment}",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      )
                  );
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
                child: Text("Tenants",
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
            ) : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(tenantList[index].profilePic), // Load the image
                        ),
                        onTap: () {
                          Get.to(() => UserInfoPage(user: tenantList[index]),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
                        },
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
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                    onPressed: () async {
                                      String? groupId = await Chatservice.findOneOnOneGroupId(userId!, property!.owner.id);
                                      if (groupId != null) {
                                        Get.to(() => ChatPage(groupId: groupId));
                                      } else {
                                        final newGroupId = await Chatservice.createGroup([userId!, property!.owner.id]);

                                        if (newGroupId != null) {
                                          Get.to(() => ChatPage(groupId: newGroupId));
                                        } else {
                                          Get.snackbar("Error", "Failed to create chat group.");
                                        }
                                      }
                                    },
                                    style: IconButton.styleFrom(backgroundColor: Colors.black),
                                    icon: Icon(Icons.chat, color: Colors.white,))
                              )
                            ],
                          ))
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
      items: widget.propertyListing!.image_url.map((imageUrl) {
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
      title: const Text("My Room",
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
