import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_project/models/boolean_variable.dart';
import 'package:fyp_project/pages/confirmation_page.dart';
import 'package:fyp_project/pages/listing_details.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';

class AddListing extends StatefulWidget {
  final Property property;
  const AddListing({super.key, required this.property});

  @override
  _AddListingState createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  PageController _pageController = PageController();
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _listingTitleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _depositController = TextEditingController();

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

  String sex_preference = "";
  String nationality_preference = "";

  List<File> _imageFiles = [];

  String roomtype = "";
  List<BooleanVariable> amenities = [
    BooleanVariable("isWifiAccess", false),
    BooleanVariable("isAirCon", false),
    BooleanVariable("isNearMarket", false),
    BooleanVariable("isCarPark", false),
    BooleanVariable("isNearMRT", false),
    BooleanVariable("isNearLRT", false),
    BooleanVariable("isPrivateBathroom", false),
    BooleanVariable("isGymnasium", false),
    BooleanVariable("isCookingAllowed", false),
    BooleanVariable("isWashingMachine", false),
    BooleanVariable("isNearBusStop", false),
  ];

  void _nextPage() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Listing"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Cancel Add Listing"),
                    content: Text("Are you sure you want to discard this form"),
                    actions: [
                      TextButton(onPressed: () => {}, child: Text("Cancel")),
                      TextButton(
                          onPressed: () => {Get.back()}, child: Text("Discard"))
                    ],
                  );
                });
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _getBody(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 5,
            right: 16,
            left: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                Flexible(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(120, 50)),
                      onPressed: _previousPage,
                      child: Text("Previous",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              if (_currentStep == 2)
                Flexible(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(120, 50)),
                      onPressed: () {
                        _buildConfirmation();
                      },
                      child: Text("Submit",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                )
              else
                Flexible(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(120, 50)),
                      onPressed: _nextPage,
                      child: Text("Save & Next",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();

      case 1:
        return _buildStep2();

      case 2:
        return _buildStep3();

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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Listing Title",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _listingTitleController,
          decoration: InputDecoration(hintText: "Listing Title"),
        ),
        SizedBox(height: 16),
        Text("Room Type",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Master Room"),
                    value: isMasterRoom,
                    onChanged: (bool? value) {
                      isMasterRoom = value!;
                      isSingleRoom = false;
                      isSharedRoom = false;
                      isSuite = false;
                      roomtype = "master";
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Single Room"),
                    value: isSingleRoom,
                    onChanged: (bool? value) {
                      isSingleRoom = value!;
                      isMasterRoom = false;
                      isSharedRoom = false;
                      isSuite = false;
                      roomtype = "single";
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
                      isMasterRoom = false;
                      isSingleRoom = false;
                      isSuite = false;
                      roomtype="shared";
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Suite"),
                    value: isSuite,
                    onChanged: (bool? value) {
                      isSuite = value!;
                      isSharedRoom = false;
                      isMasterRoom = false;
                      isSingleRoom = false;
                      roomtype = "suite";
                    },
                  ),
                )
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Text("Amenities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Wifi Access"),
                    value: isWifiAccess,
                    onChanged: (bool? value) {
                      setState(() {
                        isWifiAccess = value!;
                        amenities[0].value = value!;
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
                        amenities[1].value = value!;
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
                        amenities[2].value = value!;
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
                        amenities[3].value = value!;
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
                        amenities[4].value = value!;
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
                        amenities[5].value = value!;
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
                        amenities[6].value = value!;
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
                        amenities[7].value = value!;
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
                        amenities[8].value = value!;
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
                        amenities[9].value = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Preferences",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text("Sex",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
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
                  DropdownMenuItem(
                      value: "no preference", child: Text("No Preference")),
                ],
                onChanged: (sex_preference) {
                  print(sex_preference);
                },
              ),
            ),
            SizedBox(
              width: 20,
            ),
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
                  DropdownMenuItem(
                      value: "malaysian", child: Text("Malaysian")),
                  DropdownMenuItem(
                      value: "non-malaysian", child: Text("Non Malaysian")),
                  DropdownMenuItem(
                      value: "no preference", child: Text("No Preference")),
                ],
                onChanged: (nationality_preference) {
                  print(nationality_preference);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          "Address",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: "Description",
            border: OutlineInputBorder(),
            hintText: "Enter Description",
          ),
        ),
        SizedBox(height: 16),
        Text("Price",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: TextField(
                controller: _depositController,
                decoration: InputDecoration(
                  labelText: "Deposit",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                keyboardType: TextInputType.number,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pictures",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _imageFiles.isEmpty
            ? Center(
                child:
                    Text('No images added. Add images using the "+" button.'))
            : GridView.builder(
                shrinkWrap: true,
                itemCount: _imageFiles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(_imageFiles[index],
                          fit: BoxFit.cover, width: double.infinity),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            onPressed: _addImage,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _buildConfirmation() {
    List<BooleanVariable> trueAmenities = amenities.where((b) => b.value).toList();

    Get.to(() => ConfirmationPage(
      property: property,
      listingTitle: _listingTitleController.text,
      imageFiles: _imageFiles,
      price: _priceController.text,
      deposit: _depositController.text,
      sex_preference: sex_preference,
      nationality_preference: nationality_preference,
      description: _descriptionController.text,
      roomType: roomtype,
      ammenities: trueAmenities,),
        transition: Transition.circularReveal,
        duration: const Duration(seconds: 1));
  }
}
