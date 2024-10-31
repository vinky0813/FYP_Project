import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_project/models/boolean_variable.dart';
import 'package:fyp_project/models/owner.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/models/user.dart' as project_user;
import 'package:fyp_project/pages/add_listing.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ChatService.dart';
import '../models/property_listing.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

import 'chat_page.dart';

class ListingDetailsOwner extends StatefulWidget {
  PropertyListing propertyListing;
  final Property property;
  ListingDetailsOwner({super.key, required this.propertyListing, required this.property});

  @override
  ListingDetailsOwnerState createState() => ListingDetailsOwnerState();
}

class ListingDetailsOwnerState extends State<ListingDetailsOwner> {
  int _currentIndex = 0;
  List<Widget> body = [];
  bool _invitationSent = false;
  project_user.User? invitedTenant = null;
  String? userId;
  Owner? owner;
  TextEditingController _tenantIdController = TextEditingController();

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
        final results = await Future.wait([
          Owner.getOwnerWithId(userId!),
          widget.propertyListing.tenant == null
              ? project_user.User.checkInvitation(widget.propertyListing.listing_id)
              : Future.value(null),
        ]);

        final fetchedOwner = results[0] as Owner;
        invitedTenant = results[1] as project_user.User;

        developer.log("Fetched owner: ${fetchedOwner.toString()}");

        setState(() {
          owner = fetchedOwner;
          _invitationSent = invitedTenant != null;
        });

        developer.log(owner!.username);
      } catch (e) {
        developer.log('Error: $e');
      }
    } else {

      invitedTenant = null;
      _invitationSent = false;
    }

    if (widget.propertyListing.tenant == null) {
      setState(() {
        _invitationSent = invitedTenant != null;
      });
    } else {
      _invitationSent = false;
      invitedTenant = null;
    }
  }

  Future<void> _removeTenant() async {
    developer.log('group_id ${widget.property.group_id}');
    developer.log('user_id ${widget.propertyListing.tenant!.id}');
    developer.log('property_id ${widget.propertyListing.property_id}');
    final response4 = await Supabase.instance.client
        .from('Group_Members')
        .delete()
        .eq('group_id', widget.property.group_id)
        .eq('user_id', widget.propertyListing.tenant!.id);

    developer.log('group_id ${widget.property.group_id}');
    developer.log('user_id ${widget.propertyListing.tenant!.id}');
    developer.log('property_id ${widget.propertyListing.property_id}');

    await PropertyListing.removeTenant(widget.propertyListing.listing_id, widget.propertyListing.tenant!.id, widget.propertyListing.property_id);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _tenantIdController.text = data.text!;
      });
    }
  }

  void _deleteListing(String listing_id) {
    PropertyListing.deleteListing(listing_id);
    Get.back(result: false);
  }

  void _sendInvitation(String listing_id, String owner_id, String renter_id) {
    project_user.User.sendInvitation(listing_id, owner_id, renter_id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: _getBody(),
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Remove Listing"),
                  content: const Text("Are you sure you want to remove this listing?"),
                  actions: [
                    TextButton(
                        onPressed: () => {
                          Navigator.of(context).pop(),
                        },
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () => {
                          Navigator.of(context).pop(),
                          _deleteListing(widget.propertyListing.listing_id),
                        },
                        child: const Text("Remove"))
                  ],
                );
              });
        },
        child: const Icon(Icons.delete, color: Colors.white,),
        backgroundColor: Colors.black,
      ),
    );
  }

  //https://youtu.be/VfUUOI6BUtE?si=yAhaupWJhH8CTQeU
  Widget _getBody() {
    List<BooleanVariable> trueAmenities = widget.propertyListing.amenities.where((b) => b.value).toList();
    trueAmenities.removeAt(0);
    switch (_currentIndex) {
      case 0:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ImageCarousel(),
            const SizedBox(height: 16),
            Text(
              widget.propertyListing.listing_title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 30,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  "${widget.propertyListing.rating}/5",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text("Price: RM${widget.propertyListing.price}"),
                const SizedBox(
                  width: 16,
                ),
                Text("Deposit: RM${widget.propertyListing.deposit}"),
              ],
            ),
            const SizedBox(height: 16,),
            Text(
              "Room Type: ${widget.propertyListing.room_type}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
                '${widget.propertyListing.description}\n\n${widget.property.address}'),
            const SizedBox(height: 16),
            const Text(
              "Preference",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text("Sex: ${widget.propertyListing.sex_preference}"),
                const SizedBox(
                  width: 16,
                ),
                Text(
                    "Nationality: ${widget.propertyListing.nationality_preference}"),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              "Ammenities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(
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
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      widget.property.owner.profile_pic), // Load the image
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Owner Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Owner Name: ${widget.property.owner.username}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Contact Details: ${widget.property.owner.contact_no}",
                      style: const TextStyle(fontSize: 14),
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
              padding: const EdgeInsets.only(left: 20),
              child: const Row(
                children: [
                  Align(
                    child: Text("Review",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.propertyListing.reviews.length,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(left: 20, right: 20),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 30);
                },
                itemBuilder: (context, index) {
                  return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffE5E4E2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              Text(
                                  "${widget.propertyListing.reviews[index].rating}/5")
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "${widget.propertyListing.reviews[index].comment}/5",
                              style: const TextStyle(
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
              padding: const EdgeInsets.only(left: 20),
              child: const Row(
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
            const SizedBox(height: 16),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(widget.property.lat, widget.property.long),
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.property.lat, widget.property.long),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
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
        if (widget.propertyListing.tenant != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(widget.propertyListing.tenant!.profilePic),
                  ),
                  const SizedBox(height: 16),
                  // Username
                  Text(
                    widget.propertyListing.tenant!.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Contact Details
                  Text(
                    "Contact: ${widget.propertyListing.tenant!.contactDetails}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Buttons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Remove Tenant"),
                                content: const Text("Remove Current tenant?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _removeTenant();

                                      setState(() {
                                        _invitationSent = false;
                                        invitedTenant = null;
                                        widget.propertyListing.tenant = null;
                                      });
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Remove Tenant",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () async {
                          String? groupId = await Chatservice.findOneOnOneGroupId(userId!, widget.propertyListing.tenant!.id);

                          if (groupId != null) {
                            Get.to(() => ChatPage(groupId: groupId, chatName: widget.propertyListing.tenant!.username, ));
                          } else {
                            final newGroupId = await Chatservice.createGroup([userId!, widget.propertyListing.tenant!.id]);

                            if (newGroupId != null) {
                              Get.to(() => ChatPage(groupId: newGroupId, chatName: widget.propertyListing.tenant!.username));
                            } else {
                              Get.snackbar("Error", "Failed to create chat group.");
                            }
                          }
                        },
                        child: const Text(
                          "Chat",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          if (_invitationSent == true) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(invitedTenant!.profilePic),
                    ),
                    const SizedBox(height: 16),
                    // Username
                    Text(
                      invitedTenant!.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Contact Details
                    Text(
                      "Contact: ${invitedTenant!.contactDetails}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Buttons Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Remove Invitation"),
                                  content: const Text("Remove Pending Invitation?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        project_user.User.removeInvitation(widget.propertyListing.listing_id);

                                        setState(() {
                                          _invitationSent = false;
                                          invitedTenant = null;
                                        });
                                      },
                                      child: const Text("Delete Invitation"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Remove Invitation",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onPressed: () async {
                              String? groupId = await Chatservice.findOneOnOneGroupId(userId!, invitedTenant!.id);

                              if (groupId != null) {
                                Get.to(() => ChatPage(groupId: groupId, chatName: invitedTenant!.username,));
                              } else {
                                final newGroupId = await Chatservice.createGroup([userId!,  invitedTenant!.id]);

                                if (newGroupId != null) {
                                  Get.to(() => ChatPage(groupId: newGroupId, chatName: invitedTenant!.username,));
                                } else {
                                  Get.snackbar("Error", "Failed to create chat group.");
                                }
                              }
                            },
                          child: const Text(
                            "Chat",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 50,),
                  const Center(
                    child: Text("No Tenants", style: TextStyle(color: Colors.grey, fontSize: 24),),
                  ),
                  const SizedBox(height: 50,),
                  if (widget.propertyListing.isVerified==true)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Add Tenant"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _tenantIdController,
                                  decoration: InputDecoration(
                                    labelText: "Enter Tenant's id",
                                    border: const OutlineInputBorder(),
                                    suffixIcon: Container(
                                      width: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 7),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              const VerticalDivider(
                                                color: Colors.grey,
                                                thickness: 0.5,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.paste),
                                                onPressed: () async {
                                                  await _pasteFromClipboard(); // Call the function to paste
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  bool proceed = false;
                                  proceed = await project_user.User.checkRenterId(_tenantIdController.text);
                                  developer.log("proceed: $proceed");
                                  if (proceed) {
                                    _sendInvitation(widget.propertyListing.listing_id, owner!.id, _tenantIdController.text);
                                    project_user.User newInvitedTenant = await project_user.User.getUserById(_tenantIdController.text);
                                    setState(() {
                                      _invitationSent = true;
                                      invitedTenant = newInvitedTenant;
                                    });
                                  } else {
                                    Get.snackbar("Error", "Check ID to make sure it is correct");
                                    developer.log("cant send invitation");
                                  }
                                },
                                child: const Text("Add Tenant"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text("Add Tenant", style: TextStyle(color: Colors.white),),
                    style: TextButton.styleFrom(backgroundColor: Colors.black),)
                ],
              ),
            );
          }
        }
      default:
        return ListView(
          children: const [
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
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
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
      items: const [
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
        "Listing Details",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            Get.to(() => AddListing(property: widget.property, isEditing: true, propertyListing: widget.propertyListing, ),
              transition: Transition.circularReveal,
              duration: const Duration(seconds: 1));
          },
        ),
      ],
    );
  } // end of appBar method
}
