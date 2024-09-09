import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final User user = User(
    username: "JohnDoe",
    profilePic: "https://via.placeholder.com/150", // Placeholder
    contactDetails: "0123456789",
    sex: "Male",
    nationality: "American",
    isAccommodating: false,
    id: "1",
  );

  bool isEditing = false;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactDetailsController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameController.text = user.username;
    contactDetailsController.text = user.contactDetails;
    sexController.text = user.sex;
    nationalityController.text = user.nationality;
  }

  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage == null ? NetworkImage(user.profilePic) : FileImage(_profileImage!)),
                if (isEditing == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: _pickProfilePicture,
                      icon: Icon(Icons.edit),)
                  )
              ],
            ),

            SizedBox(height: 20,),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              style: TextStyle(
                fontSize: 18,
                color: isEditing ? Colors.black : Colors.grey,
              ),
              readOnly: !isEditing,
            ),
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Contact Details",
                border: OutlineInputBorder(),
              ),
              enabled: isEditing,
              style: TextStyle(
                fontSize: 18,
                color: isEditing ? Colors.black : Colors.grey,
              ),
              readOnly: !isEditing,
            ),
            SizedBox(height: 20),
            TextField(
              controller: sexController,
              decoration: InputDecoration(
                labelText: "Sex",
                border: OutlineInputBorder(),
              ),
              readOnly: !isEditing,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nationalityController,
              decoration: InputDecoration(
                labelText: "Nationality",
                border: OutlineInputBorder(),
              ),
              readOnly: !isEditing,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  //https://stackoverflow.com/questions/73502152/trying-make-a-status-based-on-a-boolean-value-to-change-an-icon-to-tick-in-dart
  AppBar Appbar() {
    return AppBar(
      title: Text("Account Information"),
      actions: [
        IconButton(
          icon: Icon(isEditing ? Icons.save : Icons.edit),
          onPressed: () {
            setState(() {
              if (isEditing == true) {
                user.username = usernameController.text;
                user.contactDetails = contactDetailsController.text;

                if (_profileImage != null) {
                  // update profile pic in backend here
                  user.profilePic = _profileImage!.path;
                }
              }
              isEditing = !isEditing;
            });
          },
        )
      ],
    );
  }
}
