// lib/main.dart
import 'package:flutter/material.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart'; // ეს ხაზი წაიშალა
import 'package:sulisenergetika/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // ეს საჭიროა მხოლოდ თუ სხვა დესკტოპის ლოგიკა გექნება, თორემ ესეც შეიძლება ამოიღო

// Global variable to store the alwaysOnTop preference
// bool _alwaysOnTop = false; // ეს ხაზი წაიშალა
SharedPreferences? _prefs; // ეს მაინც დაგჭირდება თუ shared_preferences-ს იყენებ

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are initialized

  // Initialize SharedPreferences
  _prefs = await SharedPreferences.getInstance();
  // _alwaysOnTop = _prefs?.getBool('alwaysOnTop') ?? false; // ეს ხაზი წაიშალა

  // Run the app
  runApp(const MyApp());

  // Configure bitsdojo_window for desktop platforms
  // ეს მთელი ბლოკი წაიშალა, რადგან აღარ გვჭირდება bitsdojo_window
  // if (defaultTargetPlatform == TargetPlatform.linux ||
  //     defaultTargetPlatform == TargetPlatform.macOS ||
  //     defaultTargetPlatform == TargetPlatform.windows) {
  //   doWhenWindowReady(() {
  //     const initialSize = Size(800, 600);
  //     appWindow
  //       ..minSize = const Size(300, 400)
  //       ..size = initialSize
  //       ..alignment = Alignment.center
  //       ..title = "SulisEnergetika - Todo App"
  //       ..show();
  //
  //     // Apply the saved alwaysOnTop preference when the window is ready
  //     appWindow.setAlwaysOnTop(_alwaysOnTop);
  //   });
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SulisEnergetika',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Orbitron',
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          displayMedium: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          displaySmall: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          headlineLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          headlineMedium: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          headlineSmall: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          titleLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          titleMedium: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          titleSmall: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          bodyLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          bodySmall: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          labelLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          labelMedium: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          labelSmall: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

