import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'widgets/starry_background.dart';

void main() {
  runApp(const HestiaApp());
}

class HestiaApp extends StatelessWidget {
  const HestiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hestia App',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return StarryBackground(child: child);
      },
      theme: ThemeData(
        fontFamily: 'Urbanist',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE28B9B),
          secondary: Color(0xFF9070E0),
          background: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF131316),
          selectedItemColor: Color(0xFFE28B9B),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
