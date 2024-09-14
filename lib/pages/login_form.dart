import 'package:flutter/material.dart';
import 'package:fyp_project/pages/forgot_password_email.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:fyp_project/pages/sign_up_form.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginForm extends StatefulWidget {

  final String userType;

  LoginForm({super.key, required this.userType});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(userType) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter both email and password");
      return;
    }

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      Get.snackbar("Login Error", "Failed to authenticate user");
      return;
    }

    final userId = response.user!.id;

    final profileResponse = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    final profileData = profileResponse as Map<String, dynamic>?;

    final user_type = profileData!["user_type"] as String?;

    if (user_type!= userType) {
      return;
    }

    if (user_type == "renter") {
      Get.off(() => HomePage(), transition: Transition.circularReveal, duration: const Duration(seconds: 1));
    } else if (user_type == "owner") {
      Get.off(() => DashboardOwner(), transition: Transition.circularReveal, duration: const Duration(seconds: 1));
    } else {
      Get.snackbar("Error", "Unknown user type.");
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
              SizedBox(height: 100,),
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
                        maxLines: 2,)),
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      SizedBox(height: 20,),
                      TextButton(
                        onPressed: () {
                          _login(widget.userType);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Text("Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),),
                      ),
                      SizedBox(height: 5,),
                      TextButton(
                        onPressed: () {
                          Get.to(() => SignUpForm(userType: widget.userType),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
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
                      SizedBox(height: 10,),
                      Container(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.to(() => ForgotPasswordEmail(),
                              transition: Transition.circularReveal,
                              duration: const Duration(seconds: 1));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            child: Text("Forgot Password",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.right,),
                          ),
                        )
                      ),
                    ],)
              )
            ]
        ),
      )
    );
  }
}