import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ChatService.dart';
import '../models/owner.dart';
import '../models/property.dart';

class AddProperty extends StatefulWidget {
  final bool isEditing;
  Property? property;

  AddProperty({super.key, required this.isEditing, required this.property});

  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  String? userId;
  final _formKey = GlobalKey<FormState>();
  double lat = 0;
  double long = 0;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    if (widget.isEditing && widget.property != null) {

      setState(() {
        _propertyTitleController.text = widget.property!.property_title;
        _addressController.text = widget.property!.address;
        lat = widget.property!.lat;
        long = widget.property!.long;
      });

      developer.log("lat $lat");
      developer.log("long $long");
    }
  }

  int _currentStep = 1;
  final TextEditingController _propertyTitleController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _propertyImage;

  String default_pic = "https://via.placeholder.com/150";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing
            ? const Text("Edit Property")
            : const Text("Add Property"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: widget.isEditing
                        ? const Text("Cancel Edit Property")
                        : const Text("Cancel Add Property"),
                    content: const Text(
                        "Are you sure you want to discard this form"),
                    actions: [
                      TextButton(
                          onPressed: () => {Navigator.of(context).pop()},
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () =>
                              {Navigator.of(context).pop(), Get.back()},
                          child: const Text("Discard"))
                    ],
                  );
                });
          },
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Property"),
                      content: const Text(
                          "Are you sure you want to delete this property?"),
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
                            await _deleteProperty();
                          },
                          child: const Text("Confirm"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete),
            )
        ],
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
            key: _formKey,
          )),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _propertyImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final url = Uri.parse("http://10.0.2.2:2000/api/upload-property-image");

    var request = http.MultipartRequest("POST", url);
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

  Future<void> _addProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_propertyImage == null) {
        Get.snackbar("Error", "Please upload an image");
        return;
      }

      final imageUrl = await _uploadImage(_propertyImage!);
      developer.log(imageUrl!);
      if (imageUrl == null) {
        Get.snackbar("Error", "Image upload failed");
        return;
      }

      final group_id = await Chatservice.createGroup([userId!]);

      final url = Uri.parse("http://10.0.2.2:2000/api/add-property");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "property_title": _propertyTitleController.text,
          "owner_id": userId,
          "property_image": imageUrl,
          "address": _addressController.text,
          "lat": lat,
          "long": long,
          "group_id": group_id,
        }),
      );

      if (response.statusCode == 200) {
        developer.log("${response.statusCode}: Success, Property Added");

        final responseData = jsonDecode(response.body);
        final propertyId = responseData["data"]["property_id"];

        developer.log("response data: ${responseData}");

        if (propertyId == null) {
          Get.snackbar("Error", "Failed to retrieve property ID from response");
          return;
        }
        Owner owner = await Owner.getOwnerWithId(userId!);

        Property newProperty = Property(
          property_id: propertyId,
          property_title: _propertyTitleController.text,
          address: _addressController.text,
          imageUrl: imageUrl,
          owner: owner,
          lat: lat,
          long: long,
          group_id: group_id!,
        );
        Get.back(result: newProperty);
      } else {
        developer.log("${response.statusCode}: Failed, Please Try Again");
        Get.snackbar("Failed", "Please Try Again");
      }
    }
  }

  Future<void> _updateProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? imageUrl;

      if (_propertyImage != null) {
        imageUrl = await _uploadImage(_propertyImage!);
        if (imageUrl == null) {
          Get.snackbar("Error", "Image upload failed");
          return;
        }
      } else {
        imageUrl = widget.property?.imageUrl ?? default_pic;
      }

      final url = Uri.parse(
          "http://10.0.2.2:2000/api/update-property/${widget.property?.property_id}");
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "property_title": _propertyTitleController.text,
          "owner_id": userId,
          "property_image": imageUrl,
          "address": _addressController.text,
          "lat": lat,
          "long": long,
        }),
      );
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        developer.log("${response.statusCode}: Success, Property Updated");
        Get.snackbar("Success", "Property Updated");
        widget.property?.property_title = _propertyTitleController.text;
        widget.property?.address = _addressController.text;
        widget.property?.imageUrl = imageUrl;
        widget.property?.lat = lat;
        widget.property?.long = long;
        Get.back(result: widget.property);
      } else {
        developer.log("${response.statusCode}: Failed, Please Try Again");
        Get.snackbar("Failed", "Please Try Again");
      }
    }
  }

  Future<void> _deleteProperty() async {
    final url = Uri.parse(
        "http://10.0.2.2:2000/api/delete-property/${widget.property?.property_id}");
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      await Supabase.instance.client
          .from('Messages')
          .delete()
          .eq('group_id',  widget.property!.group_id);

      final deleteGroupMembersResponse = await Supabase.instance.client
          .from('Group_Members')
          .delete()
          .eq('group_id', widget.property!.group_id);

      if (deleteGroupMembersResponse.error != null) {
        throw Exception("Failed to delete group members: ${deleteGroupMembersResponse.error!.message}");
      }

      final deleteGroupResponse = await Supabase.instance.client
          .from('Groups')
          .delete()
          .eq('id', widget.property!.group_id);

      if (deleteGroupResponse.error != null) {
        throw Exception("Failed to delete group: ${deleteGroupResponse.error!.message}");
      }
      developer.log("Success: Property Deleted");

      Get.back(result: false);
    } else {
      developer.log("Failed: ${response.statusCode}");
      Get.snackbar("Failed", "Remove each listing in the property first");
    }
  }

  Widget _buildStep1() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Property Title",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _propertyTitleController,
                decoration: InputDecoration(
                  labelText: widget.isEditing
                      ? widget.property?.property_title
                      : "Property Title",
                  border: const OutlineInputBorder(),
                  hintText: widget.isEditing
                      ? widget.property?.property_title
                      : "Enter Property Title",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a Property Title";
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Thumbnail",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    width: 200,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: _propertyImage != null
                                ? FileImage(_propertyImage!)
                                : widget.isEditing && widget.property != null
                                    ? NetworkImage(widget.property!.imageUrl)
                                    : NetworkImage(default_pic),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _pickImage,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_propertyImage != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _propertyImage = null;
                            });
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                if (_propertyImage == null && widget.isEditing == false) {
                  Get.snackbar("Error", "Please upload an image");
                } else {
                  setState(() {
                    _currentStep++;
                  });
                }
              }
            },
            child: const Text(
              "Save & Next",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Address",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 440,
              child: FlutterLocationPicker(
                initZoom: 11,
                minZoomLevel: 5,
                maxZoomLevel: 16,
                initPosition: widget.isEditing? LatLong(lat, long) : LatLong(0, 0),
                onPicked: (pickedData) {
                  _addressController.text = pickedData.address;
                  lat = pickedData.latLong.latitude;
                  long = pickedData.latLong.longitude;
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _currentStep--; // Go back to step 1
              });
            },
            child: const Text(
              "Previous",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: widget.isEditing
                          ? const Text("Update Property")
                          : const Text("Add Property"),
                      content: widget.isEditing
                          ? const Text("Update this Property")
                          : const Text("Create this property?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (widget.isEditing) {
                              await _updateProperty();
                            } else {
                              await _addProperty();
                            }
                          },
                          child: const Text("Confirm"),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
