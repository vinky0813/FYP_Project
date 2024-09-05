import 'package:flutter/material.dart';
import 'package:fyp_project/pages/forgot_password_email.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/sign_up_form.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LoginForm extends StatelessWidget {

  final String userType;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginForm({super.key, required this.userType});

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
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: 20,),
                      TextButton(
                        onPressed: () async {
                          if (userType == "renter") {

                            final authResponse = await supabase.auth.signInWithPassword(
                              password: passwordController.text,
                              email: emailController.text);

                            if (authResponse.session == null){
                              print("Login Failed");
                            } else {
                              GetPage(
                                name: '/homepage',
                                page: () => HomePage(),
                                transition: Transition.circularReveal,);
                            }
                          }
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
                          Get.to(() => SignUpForm(userType: userType),
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