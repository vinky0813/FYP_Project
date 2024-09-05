import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: "https://dsueczxvnypqhjsdhfmq.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzdWVjenh2bnlwcWhqc2RoZm1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU0NzA5OTIsImV4cCI6MjA0MTA0Njk5Mn0.pGB9fff5nC685S0tTfFPUNQ8UlLhLLTfoK_ci031qnI");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Roboto"),
      home: Login()
    );
  }
}
