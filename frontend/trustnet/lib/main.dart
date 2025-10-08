import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ required for Firebase config
import 'package:trustnet/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ ensures plugin binding
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ initialize Firebase
  );

  runApp(const MyApp()); // ✅ run app only after Firebase is ready
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrustNet: An SOS App for Women and Child Safety',

      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF784DD4),
          brightness: Brightness.light,
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
      home: const LoginPage(), // ✅ unchanged
    );
  }
}
