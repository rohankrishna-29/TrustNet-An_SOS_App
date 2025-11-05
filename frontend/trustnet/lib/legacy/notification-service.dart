import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trustnet/services/trusted-contacts-service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';

class NotificationService {
  final TrustedContactsService _contactsService;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Track previous status for each contact to detect changes
  final Map<String, String> _previousStatus = {};

  NotificationService(this._contactsService);

  Future<void> initialize() async {
    // Request notification permission
    await Permission.notification.request();
    // Initialize the notifications plugin
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    // Start listening to contact updates
    _listenToContactUpdates();
  }

  void _listenToContactUpdates() {
    _contactsService.contactUpdatesStream.listen((update) {
      final contactId = update['userId'] as String;
      final contactName = update['contactName'] as String;
      final newStatus = update['status'] as String;

      // Check if status has changed
      final previousStatus = _previousStatus[contactId];

      if (previousStatus != newStatus) {
        _previousStatus[contactId] = newStatus;
        _showNotification(contactName, newStatus, contactId);
      }
    });
  }

  Future<void> _showNotification(
      String contactName, String status, String contactId) async {
    String title = '';
    String body = '';
    Color notificationColor = Color(0xFF8B8B8B); // Default gray

    switch (status) {
      case 'GREEN':
        title = 'Location Sharing Active';
        body = '$contactName is sharing their location with you';
        notificationColor = Color(0xFF4CAF50); // Green
        break;
      case 'RED':
        title = '🚨 Red Alert';
        body = '$contactName has triggered a red alert';
        notificationColor = Color(0xFFFF5252); // Red
        break;
      case 'OFF':
        title = 'Location Sharing Stopped';
        body = '$contactName has stopped sharing their location';
        notificationColor = Color(0xFF9C27B0); // Purple
        break;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'trustnet_channel',
      'TrustNet Alerts',
      channelDescription: 'Notifications for trusted contact status changes',
      importance: Importance.high,
      priority: Priority.high,
      color: notificationColor,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      contactId.hashCode, // Use contact ID hash as notification ID
      title,
      body,
      notificationDetails,
    );

    print('📢 Notification shown for $contactName: $status');
  }

  void dispose() {
    // Cleanup if needed
  }
}
