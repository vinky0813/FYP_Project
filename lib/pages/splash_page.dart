import 'package:flutter/material.dart';
import 'package:fyp_project/pages/home.dart';
import 'package:fyp_project/pages/login.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final user = session.user;
      final response = await Supabase.instance.client
          .from('profiles')
          .select('user_type')
          .eq('id', user.id)
          .single();

      if (response.isNotEmpty) {
        final userType = response["user_type"] as String;
        if (userType == "renter") {
          Get.offAll(() => HomePage());
        }
        if (userType == "owner") {
          Get.offAll(() => const DashboardOwner());
        }
      }
        } else {
      Get.offAll(() => const Login());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}