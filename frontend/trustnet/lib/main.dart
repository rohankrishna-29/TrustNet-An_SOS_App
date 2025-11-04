import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trustnet/services/background_message_handler.dart';
import 'package:trustnet/utils/user_logged_in_check.dart';
import 'firebase_options.dart'; //required for Firebase config

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //ensures plugin binding

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // initialize Firebase
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp()); // run app only after Firebase is ready
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

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
      home: const UserLoggedInCheck(), 
    );
  }
}