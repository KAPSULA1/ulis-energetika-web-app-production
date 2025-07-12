import 'package:flutter/material.dart';
import 'package:sulisenergetika/screens/splash_screen.dart'; // <--- ახალი იმპორტი

void main() => runApp(const SulisEnergetikaApp());

class SulisEnergetikaApp extends StatelessWidget {
  const SulisEnergetikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sulis Energetika TODO',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        fontFamily: 'Orbitron',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // <--- ახლა იძახებს SplashScreen-ს!
    );
  }
}
