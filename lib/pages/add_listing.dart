import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_project/models/boolean_variable.dart';
import 'package:fyp_project/pages/confirmation_page.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/property.dart';
import '../models/property_listing.dart';

class AddListing extends StatefulWidget {
  final bool isEditing;
  final Property property;
  PropertyListing? propertyListing;

  AddListing(
      {super.key,
      required this.property,
      required this.isEditing,
      required this.propertyListing});

  @override
  _AddListingState createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  String? userId;
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

  List<String> _deletedExistingImageUrls = [];
  List<File> _addedNewImages = [];
  List<String> _existingImageUrls = [];

  String roomtype = "";
  List<BooleanVariable> amenities = [
    BooleanVariable(
      name: "isWifiAccess",
      value: false,
    ),
    BooleanVariable(name: "isAirCon", value: false),
    BooleanVariable(name: "isNearMarket", value: false),
    BooleanVariable(name: "isCarPark", value: false),
    BooleanVariable(name: "isNearMRT", value: false),
    BooleanVariable(name: "isNearLRT", value: false),
    BooleanVariable(name: "isPrivateBathroom", value: false),
    BooleanVariable(name: "isGymnasium", value: false),
    BooleanVariable(name: "isCookingAllowed", value: false),
    BooleanVariable(name: "isWashingMachine", value: false),
    BooleanVariable(name: "isNearBusStop", value: false),
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    if (widget.isEditing && widget.propertyListing != null) {
      developer.log("-------------------EDITING MODE---------------------");
      _listingTitleController.text = widget.propertyListing!.listing_title;
      _descriptionController.text = widget.propertyListing!.description;
      _priceController.text = widget.propertyListing!.price.toString();
      _depositController.text = widget.propertyListing!.deposit.toString();

      sex_preference = widget.propertyListing!.sex_preference;
      nationality_preference = widget.propertyListing!.nationality_preference;

      widget.propertyListing!.amenities.removeRange(0, 4);

      isWifiAccess = widget.propertyListing!.amenities[0].value;
      isAirCon = widget.propertyListing!.amenities[1].value;
      isNearMarket = widget.propertyListing!.amenities[2].value;
      isCarPark = widget.propertyListing!.amenities[3].value;
      isNearMRT = widget.propertyListing!.amenities[4].value;
      isNearLRT = widget.propertyListing!.amenities[5].value;
      isPrivateBathroom = widget.propertyListing!.amenities[6].value;
      isGymnasium = widget.propertyListing!.amenities[7].value;
      isCookingAllowed = widget.propertyListing!.amenities[8].value;
      isWashingMachine = widget.propertyListing!.amenities[9].value;
      isNearBusStop = widget.propertyListing!.amenities[10].value;

      amenities[0].value = widget.propertyListing!.amenities[0].value;
      amenities[1].value = widget.propertyListing!.amenities[1].value;
      amenities[2].value = widget.propertyListing!.amenities[2].value;
      amenities[3].value = widget.propertyListing!.amenities[3].value;
      amenities[4].value = widget.propertyListing!.amenities[4].value;
      amenities[5].value = widget.propertyListing!.amenities[5].value;
      amenities[6].value = widget.propertyListing!.amenities[6].value;
      amenities[7].value = widget.propertyListing!.amenities[7].value;
      amenities[8].value = widget.propertyListing!.amenities[8].value;
      amenities[9].value = widget.propertyListing!.amenities[9].value;
      amenities[10].value = widget.propertyListing!.amenities[10].value;

      if (widget.propertyListing!.room_type == "master") {
        isMasterRoom = true;
        roomtype = "master";
      } else if (widget.propertyListing!.room_type == "single") {
        isSingleRoom = true;
        roomtype = "single";
      } else if (widget.propertyListing!.room_type == "shared") {
        isSharedRoom = true;
        roomtype = "shared";
      } else if (widget.propertyListing!.room_type == "suite") {
        isSuite = true;
        roomtype = "suite";
      }
      _existingImageUrls = widget.propertyListing!.image_url;
    }
  }

  void _nextPage() {
    if (roomtype.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please choose a room type.')),
      );
    } else if (_currentStep < 3) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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
        _addedNewImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index, bool isExistingImage) {
    setState(() {
      if (isExistingImage) {
        _deletedExistingImageUrls.add(_existingImageUrls[index]);
        _existingImageUrls.removeAt(index);
      } else {
        _addedNewImages.removeAt(index - _existingImageUrls.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing ? Text("Edit Listing") : Text("Add Listing"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: widget.isEditing ? Text("Cancel Edit Listing") : Text("Cancel Add Listing"),
                    content: Text("Are you sure you want to discard this form"),
                    actions: [
                      TextButton(
                          onPressed: () => {
                                Navigator.of(context).pop(),
                              },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () =>
                              {Navigator.of(context).pop(), Get.back()},
                          child: Text("Discard"))
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
          child: Form(
            child: _getBody(),
            key: _formKey,
          ),
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
                        if (((_existingImageUrls.length - _deletedExistingImageUrls.length) + _addedNewImages.length)< 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Please add at least 4 images")),
                          );
                        } else {
                          if (widget.isEditing) {
                            _buildConfirmation(
                                true, widget.propertyListing?.listing_id);

                          } else {
                            _buildConfirmation(false, null);
                          }
                        }
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
        TextFormField(
          controller: _listingTitleController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a listing title";
            }
            return null;
          },
          decoration: InputDecoration(hintText: "Listing Title"),
          maxLength: 50,
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
        ),
        SizedBox(height: 16),
        Text("Room Type",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormField(
              validator: (value) {
                if (roomtype == null || roomtype.isEmpty) {
                  return "Please select a room type";
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text("Master Room"),
                            value: isMasterRoom,
                            onChanged: (bool? value) {
                              setState(() {
                                isMasterRoom = value!;
                                isSingleRoom = false;
                                isSharedRoom = false;
                                isSuite = false;
                                roomtype = "master";
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: Text("Single Room"),
                            value: isSingleRoom,
                            onChanged: (bool? value) {
                              setState(() {
                                isSingleRoom = value!;
                                isMasterRoom = false;
                                isSharedRoom = false;
                                isSuite = false;
                                roomtype = "single";
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
                            title: Text("Shared Room"),
                            value: isSharedRoom,
                            onChanged: (bool? value) {
                              setState(() {
                                isSharedRoom = value!;
                                isMasterRoom = false;
                                isSingleRoom = false;
                                isSuite = false;
                                roomtype = "shared";
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: Text("Suite"),
                            value: isSuite,
                            onChanged: (bool? value) {
                              setState(() {
                                isSuite = value!;
                                isSharedRoom = false;
                                isMasterRoom = false;
                                isSingleRoom = false;
                                roomtype = "suite";
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                );
              },
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
                    title: Text("Air Con"),
                    value: isAirCon,
                    onChanged: (bool? value) {
                      setState(() {
                        isAirCon = value!;
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
                    title: Text("Near Market"),
                    value: isNearMarket,
                    onChanged: (bool? value) {
                      setState(() {
                        isNearMarket = value!;
                        amenities[2].value = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Car Park"),
                    value: isCarPark,
                    onChanged: (bool? value) {
                      setState(() {
                        isCarPark = value!;
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
                    title: Text("Near MRT"),
                    value: isNearMRT,
                    onChanged: (bool? value) {
                      setState(() {
                        isNearMRT = value!;
                        amenities[4].value = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Near LRT"),
                    value: isNearLRT,
                    onChanged: (bool? value) {
                      setState(() {
                        isNearLRT = value!;
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
                    title: Text("Private Bathroom"),
                    value: isPrivateBathroom,
                    onChanged: (bool? value) {
                      setState(() {
                        isPrivateBathroom = value!;
                        amenities[6].value = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Gymnasium"),
                    value: isGymnasium,
                    onChanged: (bool? value) {
                      setState(() {
                        isGymnasium = value!;
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
                    title: Text("Cooking Allowed"),
                    value: isCookingAllowed,
                    onChanged: (bool? value) {
                      setState(() {
                        isCookingAllowed = value!;
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
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Bus Stop"),
                    value: isNearBusStop,
                    onChanged: (bool? value) {
                      setState(() {
                        isNearBusStop = value!;
                        amenities[10].value = value!;
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
                value: widget.isEditing
                    ? widget.propertyListing?.sex_preference ??
                    sex_preference
                    : sex_preference.isNotEmpty
                    ? sex_preference
                    : null,
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
                onChanged: (value) {
                  sex_preference = value!;
                  widget.propertyListing?.sex_preference = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a gender preference";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: widget.isEditing
                    ? widget.propertyListing?.nationality_preference ??
                        nationality_preference
                    : nationality_preference.isNotEmpty
                        ? nationality_preference
                        : null,
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
                onChanged: (value) {
                  nationality_preference = value!;
                  widget.propertyListing?.nationality_preference = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a nationality preference";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          "Description",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 200,
          inputFormatters: [
            LengthLimitingTextInputFormatter(200),
          ],
          decoration: InputDecoration(
            labelText: "Description",
            border: OutlineInputBorder(),
            hintText: "Enter Description",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a description";
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Text("Price",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                maxLength: 10,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a price";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: TextFormField(
                controller: _depositController,
                maxLength: 10,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: "Deposit",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a deposit";
                  }
                  return null;
                },
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStep3() {
    List<File> allImages = List<File>.from(_addedNewImages);
    List<String> allExistingImageUrls = List<String>.from(_existingImageUrls);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pictures",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        allImages.isEmpty && allExistingImageUrls.isEmpty
            ? Center(
            child: Text('No images added. Add images using the "+" button.'))
            : GridView.builder(
          shrinkWrap: true,
          itemCount: allImages.length + allExistingImageUrls.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            bool isExistingImage = index < allExistingImageUrls.length;
            return Stack(
              children: [
                isExistingImage
                    ? Image.network(
                  allExistingImageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : Image.file(
                  allImages[index - allExistingImageUrls.length],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeImage(index, isExistingImage),
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


  void _buildConfirmation(bool isEditing, String? listing_id) {

    developer.log("SEX PREFERENCE HERE: $sex_preference");

    Get.to(
        () => ConfirmationPage(
            property: widget.property,
            listing_id: isEditing ? listing_id : null,
            listingTitle: _listingTitleController.text,
            imageFiles: _addedNewImages,
            price: double.tryParse(_priceController.text) ?? 0.0,
            deposit: double.tryParse(_depositController.text) ?? 0.0,
            sex_preference: sex_preference,
            nationality_preference: nationality_preference,
            description: _descriptionController.text,
            roomType: roomtype,
            ammenities: amenities,
            userId: userId!,
            existingImageUrls: isEditing ? _existingImageUrls : [],
            isEditing: isEditing,
            rating: isEditing ? widget.propertyListing!.rating : 0,
            removedExistingImages: isEditing ? _deletedExistingImageUrls : [],),
        transition: Transition.circularReveal,
        duration: const Duration(seconds: 1));
  }
}
