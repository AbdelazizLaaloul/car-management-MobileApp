import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart'; // ← استيراد device_preview

import 'signup_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'user_page.dart';
import 'splash_screen.dart';
import 'welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: true, // ← يمكن تغييره لـ false فـ production
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true, // ← مهم لـ device_preview
      builder: DevicePreview.appBuilder, // ← ضروري باش يطبق device_preview
      locale: DevicePreview.locale(context), // ← باش يغير اللغة والتنسيق حسب الجهاز
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: SplashScreen(),
      routes: {
        "/signup": (context) => SignupPage(),
        "/login": (context) => LoginPage(),
        "/home": (context) => HomePage(),
        "/user": (context) => UserPage(),
        "/welcome": (context) => WelcomePage(),
      },
    );
  }
}
