import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddProperty extends StatefulWidget {
  const AddProperty({super.key});

  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  int _currentStep = 1;
  final TextEditingController _propertyTitleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  String default_pic = "https://via.placeholder.com/150";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Property"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Cancel Add Property"),
                    content: Text(
                        "Are you sure you want to discard this form"),
                    actions: [
                      TextButton(
                          onPressed: () => {},
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () => {
                            Get.back()
                          },
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
    return Column(
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
            labelText: "Property Title",
            border: OutlineInputBorder(),
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
                      image: _profileImage == null
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
            )
          ],
        ),
        Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _currentStep++; // Move to the next step
              });
            },
            child: Text("Save & Next", style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Property Title",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _addressController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: "Address",
            border: OutlineInputBorder(),
          ),
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                setState(() {
                  _currentStep--; // Go back to step 1
                });
              },
              child: Text("Previous", style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                AlertDialog(
                  title: Text("Add Property"),
                  content: Text(
                      "Create this property?"),
                  actions: [
                    TextButton(
                        onPressed: () => {},
                        child: Text("Cancel")),
                    TextButton(
                        onPressed: () => {
                          Get.back()
                        },
                        child: Text("Confirm"))
                  ],
                );
                print("Property Title: ${_propertyTitleController.text}");
                print("Property Address: ${_addressController.text}");
              },
              child: Text("Confirm", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ],
    );
  }
}
