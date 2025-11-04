import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmLocalNotificationHandler {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialization settings for Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');


    // Initialization settings for both platforms
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    // Setup FCM message listener for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      } else if (message.data.isNotEmpty) {
        // Handle data-only messages if desired, e.g.:
        _showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.data['title'] ?? 'Notification',
          body: message.data['body'] ?? '',
        );
      }
    });
  }

  static Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );


    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails,);

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: '', // Optional: data for tap behavior later
    );
  }
}
