import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize the local notifications plugin (reuse or initialize in main)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _showLocalNotification(
    {required String title, required String body}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel',
    'Default Channel',
    channelDescription: 'General notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // notification id
    title,
    body,
    platformDetails,
  );
}

// This must be a top-level or static function
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize the plugin if needed here
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  if (message.notification != null) {
    await _showLocalNotification(
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
    );
  } else if (message.data.isNotEmpty) {
    await _showLocalNotification(
      title: message.data['title'] ?? 'Background Notification',
      body: message.data['body'] ?? '',
    );
  }
}
