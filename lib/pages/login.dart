import 'package:flutter/material.dart';
import 'package:fyp_project/pages/login_form.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
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
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20, top: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Your Role:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => LoginForm(userType: "renter"),
                                transition: Transition.noTransition,
                                duration: const Duration(seconds: 1));
                          },
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:BorderRadius.circular(10)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Renter",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                )),
                          ),
                        ),
                      )
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => LoginForm(userType: "owner"),
                            transition: Transition.noTransition,
                            duration: const Duration(seconds: 1));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:BorderRadius.circular(10)
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Property Owner",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16
                                  )),
                            ),
                          ),
                        )
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}