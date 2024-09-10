import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';

class AddProperty extends StatefulWidget {
  final bool isEditing;
  Property? property;

  AddProperty({super.key, required this.isEditing, required this.property});

  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  int _currentStep = 1;
  final TextEditingController _propertyTitleController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  String default_pic = "https://via.placeholder.com/150";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing ? Text("Edit Property") : Text("Add Property"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: widget.isEditing
                        ? Text("Cancel Edit Property")
                        : Text("Cancel Add Property"),
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
        actions: [
          if (widget.isEditing == false)
            IconButton(
                onPressed: () {
                  AlertDialog(
                    title: Text("Delete Property"),
                    content:
                        Text("Are you sure you want to delete this property?"),
                    actions: [
                      TextButton(onPressed: () => {}, child: Text("Cancel")),
                      TextButton(
                          onPressed: () => {Get.back()}, child: Text("COnfirm"))
                    ],
                  );
                },
                icon: Icon(Icons.delete))
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildStep1() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Property Title",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _propertyTitleController,
                decoration: InputDecoration(
                  labelText: widget.isEditing
                      ? widget.property?.property_title
                      : "Property Title",
                  border: OutlineInputBorder(),
                  hintText: widget.isEditing
                      ? widget.property?.property_title
                      : "Enter Property Title",
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Thumbnail",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
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
                            image: widget.isEditing
                                ? NetworkImage(widget.property!.imageUrl)
                                : _profileImage == null
                                ? NetworkImage(default_pic)
                                : FileImage(_profileImage!) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: _pickProfilePicture,
                      icon: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _currentStep++;
              });
            },
            child: Text(
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
            Text(
              "Address",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: widget.isEditing ? widget.property?.address : "Address",
                border: OutlineInputBorder(),
                hintText:
                widget.isEditing ? widget.property?.address : "Enter Address",
              ),
            ),
            SizedBox(height: 80),
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
            child: Text(
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Add Property"),
                    content: Text("Create this property?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle Confirm action
                          Navigator.of(context).pop();
                        },
                        child: Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
              print("Property Title: ${_propertyTitleController.text}");
              print("Property Address: ${_addressController.text}");
            },
            child: Text(
              "Confirm",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
