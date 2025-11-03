import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trustnet/services/background_message_handler.dart';
import 'package:trustnet/utils/user_logged_in_check.dart';
import 'firebase_options.dart'; //required for Firebase config
import 'package:trustnet/services/background_message_handler.dart';

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


/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  void _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (for iOS)
    await messaging.requestPermission();

    // Get the device token
    String? token = await messaging.getToken();
    setState(() => _token = token);
    print("FCM Token: $_token");

    // Messages received while app is foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground: ${message.messageId}');
      // Handle message in foreground, e.g., show in-app notification
    });

    // When user taps notification and opens app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!: ${message.messageId}');
      // Handle navigation based on message data
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('FCM Demo')),
        body: Center(
          child: Text('FCM Token:\n$_token', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
*/

