import 'package:flutter/material.dart';
import 'package:fyp_project/pages/forgot_password_tac.dart';
import 'package:get/get.dart';

class ForgotPasswordEmail extends StatelessWidget {

  ForgotPasswordEmail({super.key});

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
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Get.to(() => ForgotPasswordTac(),
                                transition: Transition.circularReveal,
                                duration: const Duration(seconds: 1));
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text("Confirm",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),),
                        ),
                      ],)
                )
              ]
          ),
        )
    );
  }
}