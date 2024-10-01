import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/owner.dart';
import '../models/user.dart' as project_user;
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  final userType;

  const AccountPage({super.key, required this.userType});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  String? userId;
  String? _profilePic;
  bool isLoading = true;

  String? initialUsername;
  String? initialContactDetails;

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    userId = user?.id;

    if (widget.userType == "renter") {
      project_user.User renter = await project_user.User.getUserById(userId!);

      setState(() {
        usernameController.text = renter.username;
        contactDetailsController.text = renter.contactDetails;
        sexController.text = renter.sex;
        nationalityController.text = renter.nationality;
        _profilePic = renter.profilePic;
        isLoading = false;

        initialUsername = renter.username;
        initialContactDetails = renter.contactDetails;
      });

    } else if (widget.userType == "owner") {
      Owner owner = await Owner.getOwnerWithId(userId!);

      setState(() {
        usernameController.text = owner.username;
        contactDetailsController.text = owner.contact_no;
        _profilePic = owner.profile_pic;
        isLoading =false;

        initialUsername = owner.username;
        initialContactDetails = owner.contact_no;
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

  Future<void> _saveProfileUpdates() async {
    String? imageUrl;
    if (_profileImage != null) {
      imageUrl = await _uploadImage(_profileImage!);
    }else {
      imageUrl = _profilePic;
    }
    if (widget.userType == "renter") {
      developer.log("${userId!}, ${usernameController.text}, ${contactDetailsController.text}, ${imageUrl!}");
      await project_user.User.updateUser(userId!, usernameController.text, contactDetailsController.text, imageUrl!);
    } else if (widget.userType == "owner") {
      await Owner.updateOwner(userId!, usernameController.text, contactDetailsController.text, imageUrl!,
      );
    }
    Supabase.instance.client
    .from("profiles")
    .upsert({
      "avatar_url": imageUrl,
      "username": usernameController.text,
      "user_id": userId});
  }
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
    _initialize();
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
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
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
                  backgroundImage: _profileImage == null ? NetworkImage(_profilePic!) : FileImage(_profileImage!)),
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
              controller: contactDetailsController,
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
            if (widget.userType == "renter")
              TextField(
                controller: sexController,
                decoration: InputDecoration(
                  labelText: "Sex",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            SizedBox(height: 20),
            if (widget.userType == "renter")
              TextField(
                controller: nationalityController,
                decoration: InputDecoration(
                  labelText: "Nationality",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
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
      automaticallyImplyLeading: !isEditing,
      actions: [
        IconButton(
          icon: Icon(isEditing ? Icons.save : Icons.edit),
          onPressed: () {
            setState(() {
              if (isEditing == true) {
                bool hasChanges = usernameController.text != initialUsername ||
                    contactDetailsController.text != initialContactDetails ||
                    _profileImage != null;
                if (hasChanges) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Update Profile"),
                          content:
                          Text("Are you sure you want to submit this form"),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                {
                                  Navigator.of(context).pop(),
                                },
                                child: Text("Cancel")),
                            TextButton(
                                onPressed: () async =>
                                {
                                  Navigator.of(context).pop(),
                                  _saveProfileUpdates(),
                                },
                                child: Text("Confirm"))
                          ],
                        );
                      });
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
