import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordTac extends StatelessWidget {

  ForgotPasswordTac({super.key});

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
                            labelText: "TAC",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
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