import 'package:flutter/material.dart';
import 'package:trustnet/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrustNet: An SOS App for Women and Child Safety',

      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF784DD4),
          brightness: Brightness.light
        ),
      ),

      darkTheme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF784DD4),
          brightness: Brightness.dark,
        ),
      ),

      themeMode: ThemeMode.dark,
      home: HomeScreen(),
    );
  }
}

