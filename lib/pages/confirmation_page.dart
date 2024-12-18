import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fyp_project/models/property.dart';
import 'package:fyp_project/models/property_listing.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../AccessTokenController.dart';
import '../models/boolean_variable.dart';

class ConfirmationPage extends StatefulWidget {
  final String? listing_id;
  final bool isEditing;
  final String listingTitle;
  final double rating;
  final List<File> imageFiles;
  final List<String> existingImageUrls;
  final List<String> removedExistingImages;
  final double price;
  final double deposit;
  final String sex_preference;
  final String nationality_preference;
  final String description;
  final String roomType;
  final List<BooleanVariable> ammenities;
  final String userId;

  final Property property;

  ConfirmationPage(
      {super.key,
      required this.property,
      required this.listingTitle,
      required this.imageFiles,
      required this.price,
      required this.deposit,
      required this.sex_preference,
      required this.nationality_preference,
      required this.description,
      required this.ammenities,
      required this.roomType,
      required this.userId,
      required this.listing_id,
      required this.existingImageUrls,
      required this.isEditing,
      required this.rating,
      required this.removedExistingImages});

  @override
  ConfirmationPageState createState() => ConfirmationPageState();
}

class ConfirmationPageState extends State<ConfirmationPage> {
  int _currentIndex = 0;
  List<Widget> body = [];
  bool isMasterRoom = false;
  bool isSingleRoom = false;
  bool isSharedRoom = false;
  bool isSuite = false;
  final accesstokencontroller = Get.find<Accesstokencontroller>();
  String? accessToken;

  @override
  void initState() {
    super.initState();

    accessToken = accesstokencontroller.token;

    if (accessToken == null) {
      print("Token is null");
    }
  }

  Future<List<String>?> _uploadImages(List<File> images) async {
    try {
      List<String?> results = await Future.wait(images.map((image) => _uploadImage(image)));

      List<String> imageUrls = results.whereType<String>().toList();

      if (imageUrls.length != images.length) {
        developer.log("Some images failed to upload");
      }

      return imageUrls.isNotEmpty ? imageUrls : null;
    } catch (e) {
      developer.log("Image upload failed: $e");
      return null;
    }
  }


  Future<String?> _uploadImage(File image) async {
    final url = Uri.parse("https://fyp-project-liart.vercel.app/api/upload-property-image");

    var request = http.MultipartRequest("POST", url);

    if (accessToken != null && accessToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      developer.log("Access token is missing");
      return null;
    }

    developer.log(image.path);
    request.files.add(await http.MultipartFile.fromPath("image", image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var res = await http.Response.fromStream(response);
      var responseData = jsonDecode(res.body);

      return responseData["imageUrl"];
    } else {
      developer.log("${response.statusCode} : Image upload failed");
      return null;
    }
  }

  Future<void> _editListing() async {
    try {
      final urlEditListing = Uri.parse("https://fyp-project-liart.vercel.app/api/update-listing/${widget.listing_id}");

      final responseEditListing = await http.put(
        urlEditListing,
        headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $accessToken',},
        body: jsonEncode({
          "listing_title": widget.listingTitle,
          "price": widget.price,
          "deposit": widget.deposit,
          "rating": widget.rating,
          "description": widget.description,
          "sex_preference": widget.sex_preference,
          "nationality_preference": widget.nationality_preference,
        }),
      );

      developer.log("Listing Edit: ${responseEditListing.body}");

      if (responseEditListing.statusCode != 200) {
        Get.snackbar("Error", "Failed to update listing");
        return;
      }

      final urlDeleteImage = Uri.parse("https://fyp-project-liart.vercel.app/api/delete-listing-image");
      final deleteImageRequests = widget.removedExistingImages.map((imageUrl) {
        return http.delete(
          urlDeleteImage,
          headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $accessToken'},
          body: jsonEncode({
            "listing_id": widget.listing_id,
            "image_url": imageUrl,
          }),
        );
      }).toList();

      final deleteResponses = await Future.wait(deleteImageRequests);

      final List<String> urls_to_be_uploaded = [];

      final List<String> urlsToBeUploaded = [];
      final uploadImageFutures = widget.imageFiles.map((imageFile) async {
        final url = await _uploadImage(imageFile);
        if (url != null && url.isNotEmpty) {
          urlsToBeUploaded.add(url);
          developer.log("Image uploaded: $url");
        } else {
          Get.snackbar("Error", "Image upload failed for $imageFile");
        }
      }).toList();

      await Future.wait(uploadImageFutures);

      final urlAddListingImages = Uri.parse("https://fyp-project-liart.vercel.app/api/add-listing-images");
      final addImageRequests = urlsToBeUploaded.map((imageUrl) {
        return http.post(
          urlAddListingImages,
          headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $accessToken'},
          body: jsonEncode({
            "listing_id": widget.listing_id,
            "image_url": imageUrl,
          }),
        );
      }).toList();

      final addImageResponses = await Future.wait(addImageRequests);

      final urlUpdateAmenities = Uri.parse("https://fyp-project-liart.vercel.app/api/edit-listing-ammenities");
      final responseUpdateAmenities = await http.put(
        urlUpdateAmenities,
        headers: {"Content-Type": "application/json", 'Authorization': 'Bearer $accessToken',},
        body: jsonEncode({
          "listing_id": widget.listing_id,
          "isMasterRoom": widget.roomType == "master",
          "isSingleRoom": widget.roomType == "single",
          "isSharedRoom": widget.roomType == "shared",
          "isSuite": widget.roomType == "suite",
          "isWifiAccess": widget.ammenities[0].value,
          "isAirCon": widget.ammenities[1].value,
          "isNearMarket": widget.ammenities[2].value,
          "isCarPark": widget.ammenities[3].value,
          "isNearMRT": widget.ammenities[4].value,
          "isNearLRT": widget.ammenities[5].value,
          "isPrivateBathroom": widget.ammenities[6].value,
          "isGymnasium": widget.ammenities[7].value,
          "isCookingAllowed": widget.ammenities[8].value,
          "isWashingMachine": widget.ammenities[9].value,
          "isNearBusStop": widget.ammenities[10].value,
        }),
      );

      developer.log("Update amenities response: ${responseUpdateAmenities.body}");

      if (responseUpdateAmenities.statusCode == 200) {
        Get.offNamed("/manageProperty");
        developer.log("Success: Listing updated with images and amenities");
      } else {
        Get.snackbar("Error", "Failed to update amenities");
      }
    } catch (e) {
      developer.log("Error: $e");
      Get.snackbar("Error", "Failed to edit listing");
    }
  }


  Future<void> _addListing() async {

    developer
        .log("length of ammenities: ${widget.ammenities.length.toString()}");

    final imageUrls = await _uploadImages(widget.imageFiles);
    if (imageUrls == null || imageUrls.isEmpty) {
      Get.snackbar("Error", "Image upload failed");
      return;
    }

    if (imageUrls.isEmpty) {
      Get.snackbar("Error", "No images uploaded");
      return;
    }

    final url_add_listing = Uri.parse("https://fyp-project-liart.vercel.app/api/add-listing");
    final response = await http.post(
      url_add_listing,
      headers: {"Content-Type": "application/json",'Authorization': 'Bearer $accessToken',},
      body: jsonEncode({
        "listing_title": widget.listingTitle,
        "tenant": null,
        "price": widget.price,
        "deposit": widget.deposit,
        "property_id": widget.property.property_id,
        "description": widget.description,
        "isPublished": false,
        "isVerified": false,
        "rating": 0,
        "nationality_preference": widget.nationality_preference,
        "sex_preference": widget.sex_preference,
      }),
    );
    developer.log(response.body);
    developer.log(response.statusCode.toString());

    if (response.statusCode == 201 || response.statusCode == 200) {
      developer.log("${response.statusCode}: Success, Listing Added");
      final responseData = jsonDecode(response.body);
      final listingId = responseData["data"]["listing_id"];

      if (listingId == null) {
        Get.snackbar("Error", "Failed to retrieve listing ID from response");
        return;
      }

      final url_listing_images =
          Uri.parse("https://fyp-project-liart.vercel.app/api/add-listing-images");

      final urlListingImages = Uri.parse("https://fyp-project-liart.vercel.app/api/add-listing-images");
      final imageRequests = imageUrls.map((imageUrl) {
        return http.post(
          urlListingImages,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            "listing_id": listingId,
            "image_url": imageUrl,
          }),
        );
      }).toList();

      switch (widget.roomType) {
        case "master":
          isMasterRoom = true;
          break;
        case "single":
          isSingleRoom = true;
          break;
        case "shared":
          isSharedRoom = true;
          break;
        case "suite":
          isSuite = true;
          break;
      }

        final url_listing_ammenities =
            Uri.parse("https://fyp-project-liart.vercel.app/api/add-listing-ammenities");
  
        final response_listing_ammenities = await http.post(
          url_listing_ammenities,
          headers: {'Content-Type': 'application/json',"Authorization": "Bearer $accessToken"},
          body: jsonEncode({
            "listing_id": listingId,
            "isMasterRoom": isMasterRoom,
            "isSingleRoom": isSingleRoom,
            "isSharedRoom": isSharedRoom,
            "isSuite": isSuite,
            "isWifiAccess": widget.ammenities[0].value,
            "isAirCon": widget.ammenities[1].value,
            "isNearMarket": widget.ammenities[2].value,
            "isCarPark": widget.ammenities[3].value,
            "isNearMRT": widget.ammenities[4].value,
            "isNearLRT": widget.ammenities[5].value,
            "isPrivateBathroom": widget.ammenities[6].value,
            "isGymnasium": widget.ammenities[7].value,
            "isCookingAllowed": widget.ammenities[8].value,
            "isWashingMachine": widget.ammenities[9].value,
            "isNearBusStop": widget.ammenities[10].value,
          }),
        );
        if (response_listing_ammenities.statusCode == 200) {
          developer.log(
              "${response_listing_ammenities.statusCode}: Success, Ammenities Added");
        } else {
          developer.log(
              "${response_listing_ammenities.statusCode}: Failed to add Ammenities");
        }
  
        Get.offNamed("/manageProperty");
      } else {
        developer.log("${response.statusCode}: Failed, Please Try Again");
        Get.snackbar("Failed", "Please Try Again");
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
                heroTag: "cancelEditButton",
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                heroTag: "confirmEditButton",
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: widget.isEditing
                              ? const Text("Confirm Edit Listing")
                              : const Text("Confirm Add Listing"),
                          content:
                              const Text("Are you sure you want to submit this form"),
                          actions: [
                            TextButton(
                                onPressed: () => {
                                      Navigator.of(context).pop(),
                                    },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () async => {
                                      Navigator.of(context).pop(),
                                      if (widget.isEditing)
                                        {
                                          developer.log("Editing listing..."),
                                          await _editListing()
                                        }
                                      else
                                        {
                                          developer.log("Adding listing..."),
                                          await _addListing()
                                        }
                                    },
                                child: const Text("Confirm"))
                          ],
                        );
                      });
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }
  
    //https://youtu.be/VfUUOI6BUtE?si=yAhaupWJhH8CTQeU
    Widget _getBody() {
      List<BooleanVariable> trueAmenities =
          widget.ammenities.where((b) => b.value).toList();
      switch (_currentIndex) {
        case 0:
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ImageCarousel(),
              const SizedBox(height: 16),
              Text(
                widget.listingTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Row(
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
                    "5/5",
                    style: TextStyle(
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
                  Text("Price: RM${widget.price}"),
                  const SizedBox(
                    width: 16,
                  ),
                  Text("Deposit: RM${widget.deposit}"),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "Room Type: ${widget.roomType}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              Text('${widget.description}\n\n${widget.property.address}'),
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
                  Text("Sex: ${widget.sex_preference}"),
                  const SizedBox(
                    width: 16,
                  ),
                  Text("Nationality: ${widget.nationality_preference}"),
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
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        NetworkImage(widget.property.owner.profile_pic),
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
                child: const Align(
                  child: Text("Review",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: 0,
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
                            const Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                Text("")
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: const Text(
                                "",
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
      List<Widget> imageWidgets = [];
  
      if (widget.existingImageUrls != null) {
        imageWidgets.addAll(widget.existingImageUrls!.map((url) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }).toList());
      }
  
      imageWidgets.addAll(widget.imageFiles.map((imageFile) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList());
  
      return CarouselSlider(
        options: CarouselOptions(height: 200),
        items: imageWidgets,
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
            // same thing here
            onPressed: () => {},
          )
        ],
      );
    } // end of appBar method
  }
