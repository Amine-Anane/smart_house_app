import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SmartHouseApp());
}

class SmartHouseApp extends StatelessWidget {
  const SmartHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart House',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060B12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4D9FFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
