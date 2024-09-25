import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fyp_project/pages/manage_listing.dart';
import 'package:fyp_project/pages/manage_property.dart';
import 'package:fyp_project/pages/owner_home.dart';
import 'package:fyp_project/pages/splash_page.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/SearchBarLocation.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env["SUPABASE_URL"] ?? "";
  final supabaseAnonKey = dotenv.env["API_KEY"] ?? "";
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Roboto"),
      home: SplashPage(),
      getPages: [
        GetPage(name: '/manageProperty', page: () => ManageProperty()),
      ],
    );
  }
}
