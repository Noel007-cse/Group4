import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:spacebook/Homepage.dart';
import 'package:spacebook/widgets/search_result_widget.dart';
import 'package:spacebook/auth_screen.dart';
import 'package:spacebook/main_screen.dart';
import 'package:spacebook/mybookings.dart';
import 'package:spacebook/widgets/space_frame_widget.dart';
import 'package:spacebook/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SpaceBookApp());
}

class SpaceBookApp extends StatefulWidget {
  const SpaceBookApp({super.key});

  // ✅ THIS METHOD WAS MISSING
  static _SpaceBookAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SpaceBookAppState>();
  }

  @override
  State<SpaceBookApp> createState() => _SpaceBookAppState();
}

class _SpaceBookAppState extends State<SpaceBookApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.green,
          surface: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.green,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
