import 'package:flutter/material.dart';
import 'package:fyp_project/pages/login_form.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpForm extends StatelessWidget {

  final String userType;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignUpForm({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10,),
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Image.asset("images/magnifying-glass.png"),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
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
    if (userType == "renter") {
      return renterSIgnUpForm();
    } else {
      return ownerSignUpForm();
    }
  }

  Padding renterSIgnUpForm() {
    return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
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
                    ],
                    onChanged: (gender) {
                      print(gender);
                    },
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Age",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      keyboardType: TextInputType.number,
                    ),)
              ],
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Student ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              obscureText: true,
              controller: passwordController,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              obscureText: true,
              controller: confirmPasswordController,
            ),
            SizedBox(height: 20,),
            TextButton(
              onPressed: () async {
                if (confirmPasswordController.text == passwordController.text) {
                  final AuthResponse res = await supabase.auth.signUp(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  Get.back();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text("Sign Up",
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
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
                    ],
                    onChanged: (gender) {
                      print(gender);
                    },
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    keyboardType: TextInputType.number,
                  ),)
              ],
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20,),
            TextField(
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                Get.back();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: Text("Sign Up",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),),
            ),
          ],)
    );
  }
}