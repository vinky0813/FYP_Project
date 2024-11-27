import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:fyp_project/pages/sign_up_form.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:fyp_project/models/user.dart' as project_user;

import '../AccessTokenController.dart';

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

    developer.log("row level security problem here?");
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter both email and password");
      return;
    }

    try {

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final supabase = Supabase.instance.client;

    final session = response.session;

    developer.log("session email: ${session!.user.email}");

    if (session == null) {
      Get.snackbar("Login Error", "Failed to authenticate.");
      return;
    }
      Get.put(Accesstokencontroller());

      developer.log("row level security problem before here?");

      final userId = response.user!.id;

      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select("user_type")
          .eq('id', userId)
          .single();

      final user_type = profileResponse["user_type"];

      if (user_type!= userType) {
        await Supabase.instance.client.auth.signOut();
        _showErrorDialog(context, "wrong user type");
      } else if (user_type == "renter") {
        Get.off(() => const HomePage(), transition: Transition.circularReveal, duration: const Duration(seconds: 1));
      } else if (user_type == "owner") {
        Get.off(() => const DashboardOwner(), transition: Transition.circularReveal, duration: const Duration(seconds: 1));
      } else {
        Get.snackbar("Error", "Unknown user type.");
      }

    } catch (error) {
      developer.log(error.toString());
      Get.snackbar("Login Error", "Invalid email or password. Please try again.");
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
              const SizedBox(height: 100,),
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
                        maxLines: 2,)),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword, obscureText: true,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      TextButton(
                        onPressed: () {
                          _login(widget.userType);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: const Text("Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),),
                      ),
                      const SizedBox(height: 5,),
                      TextButton(
                        onPressed: () {
                          Get.to(() => SignUpForm(userType: widget.userType),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 1));
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
                      const SizedBox(height: 10,),
                    ],)
              )
            ]
        ),
      )
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}