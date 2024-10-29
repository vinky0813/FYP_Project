import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SignUpForm extends StatefulWidget {

  final String userType;

  SignUpForm({super.key, required this.userType});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isValidPassword(String password) {
    final hasSpecialCharacter = RegExp(r'[!@#\$&*~]');
    return password.length >= 8 && hasSpecialCharacter.hasMatch(password);
  }

  Future<void> _signUp(String userType) async {
    final String fullName = fullNameController.text;
    final String gender = genderController.text;
    final String nationality = nationalityController.text;
    final String contactNo = contactNumberController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    if (!_isValidPassword(password)) {
      Get.snackbar("Error", "Password must be at least 8 characters long and include a special character");
      return;
    }

    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      Get.snackbar("Error", "Please fill in all required fields");
      return;
    }

    if (userType == "renter" && (nationality.isEmpty || gender.isEmpty || contactNo.isEmpty)) {
      Get.snackbar("Error", "Please fill in all required fields");
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        Get.snackbar("Error", "Something went wrong. Please try again");
        return;
      }

      await Supabase.instance.client.auth.refreshSession();

      await Supabase.instance.client
          .from('profiles')
          .upsert({
        'id': user.id,
        'user_type': userType,
        'full_name': fullName,
      });

      developer.log("user type: $userType");

      if (userType == "renter") {
        await Supabase.instance.client
            .from('Renters')
            .insert({
          'user_id': user.id,
          'name': fullName,
          'contact_no': contactNo,
          'sex': gender,
          'nationality': nationality,
          'isAccommodating': false,
        });
        Get.offAll(const HomePage());
      } else if (userType == "owner") {
        await Supabase.instance.client
            .from('Owners')
            .insert({
          'user_id': user.id,
          'name': fullName,
          'contact_no': contactNo,
        });
        Get.offAll(const DashboardOwner());
      }

      Get.snackbar("Success", "Sign up successful!");
    } catch (e) {
      Get.snackbar("Error", "An error occurred during sign up");
      developer.log('Exception: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10,),
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Image.asset("images/magnifying-glass.png"),
                    ),
                    const SizedBox(width: 20,),
                    const Expanded(
                        child: Text("INTI Accommodation Finder",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        )
                    ),
                  ],
                ),
                getForm()
              ]
          ),
        )
    );
  }

  getForm() {
    if (widget.userType == "renter") {
      return renterSIgnUpForm();
    } else {
      return ownerSignUpForm();
    }
  }

  Padding renterSIgnUpForm() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
              maxLength: 50,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Gender",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: "male", child: Text("Male")),
                      DropdownMenuItem(value: "female", child: Text("Female")),
                    ],
                    onChanged: (gender) {
                      genderController.text=gender!;
                    },
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Nationality",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: "malaysian", child: Text("Malaysian")),
                      DropdownMenuItem(value: "non malaysian", child: Text("Non-Malaysian")),
                    ],
                    onChanged: (nationality) {
                      nationalityController.text = nationality!;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: contactNumberController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
              maxLength: 15,
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              maxLength: 20,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              maxLength: 20,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
            ),
            const SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                _signUp(widget.userType);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text("Sign Up",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),),
            ),
          ],)
    );
  }

  Padding ownerSignUpForm() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
              maxLength: 50,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: contactNumberController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
              maxLength: 15,
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              maxLength: 20,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              maxLength: 20,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
            ),
            const SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                _signUp(widget.userType);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text("Sign Up",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),),
            ),
          ],)
    );
  }
}