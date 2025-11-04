import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ added
import 'package:trustnet/services/location-status-tracking-service.dart';
import 'package:trustnet/services/trusted-contacts-service.dart';
import 'package:trustnet/services/notification-service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  String status = "OFF";
  Timer? _locationTimer;
  String? userId;
  String? username;
  Position? _lastPosition;
  bool redMode = false;
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  final bool _isRedMode = false;

  @override
  bool get wantKeepAlive => true;

  final Map<String, Color> statusColors = {
    "OFF": Colors.grey,
    "GREEN": Colors.green,
    "RED": Colors.red,
  };

  late final LocationStatusTrackingService _locationStatusService;

  @override
  void initState() {
    super.initState();
    _locationStatusService = LocationStatusTrackingService();
    _requestLocationPermission();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    userId = user.uid;
    await _locationStatusService.initialize(userId!);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      setState(() {
        username = doc.data()?['name'] ?? userId;
      });

      _locationStatusService.startPassiveLocationUpdates();
    } catch (e) {
      debugPrint("Error fetching username: $e");
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      final result = await Permission.locationWhenInUse.request();
      if (!result.isGranted) {
        debugPrint("Location permission denied.");
      }
    }
  }

  void toggleStatus() async {
    final newStatus = await _locationStatusService.toggleStatus(status);
    setState(() {
      status = newStatus;
    });

    if (status == 'RED') {
      _startRecording();
    } else if (status == 'OFF') {
      _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        PermissionStatus status = await Permission.manageExternalStorage.request();
        if (status.isGranted || await Permission.storage.isGranted) {
          final trustnetDir = Directory('/storage/emulated/0/Music/TrustNet');
          await trustnetDir.create(recursive: true);
          final filePath =
              '${trustnetDir.path}/trustnet_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _recorder.start(const RecordConfig(), path: filePath);
          debugPrint("Recording started at: $filePath");
        } else {
          debugPrint("Storage permission denied");
        }
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      debugPrint("Recording stopped. File saved at: $path");
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  // ✅ Emergency services feature
  Future<void> _triggerEmergencyServices() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final lat = position.latitude;
      final lng = position.longitude;
      final mapsUrl = "https://www.google.com/maps?q=$lat,$lng";

      // 🚨 Option 1: Direct call to 112
      final callUri = Uri.parse('tel:+917678656817');
      await launchUrl(callUri);

      // 🚨 Option 2: Optional SMS to contact
      final trustedNumber = "+917678656817"; // or replace with a trusted contact number
      final smsUri = Uri.parse(
          'sms:$trustedNumber?body=🚨 Emergency! Please help! My location: $mapsUrl');
      await launchUrl(smsUri);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency alert sent')),
      );
    } catch (e) {
      debugPrint("Emergency services failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send emergency alert: $e')),
      );
    }
  }

  @override
  void dispose() {
    _locationStatusService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final color = statusColors[status]!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: toggleStatus,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "lib/assets/icons/TrustNet-logo-only.svg",
                    width: 150,
                    height: 150,
                    colorFilter: ColorFilter.mode(
                      status == "GREEN"
                          ? Colors.green
                          : status == "RED"
                              ? Colors.red
                              : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Status: $status",
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Emergency button
            ElevatedButton.icon(
              onPressed: _triggerEmergencyServices,
              icon: const Icon(Icons.emergency, color: Colors.white),
              label: const Text(
                "Emergency Services",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
