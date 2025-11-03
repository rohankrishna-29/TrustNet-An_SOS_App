import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
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
  bool redMode=false;
  final AudioRecorder _recorder=AudioRecorder();
  String? _recordingPath;
  final bool _isRedMode = false;


  final Map<String, Color> statusColors = {
    "OFF": Colors.grey,
    "GREEN": Colors.green,
    "RED": Colors.red,
  };

  late final LocationStatusTrackingService _locationStatusService;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _locationStatusService = LocationStatusTrackingService();
    _requestLocationPermission();
   // _requestMicPermission();
    _fetchUsername();
  }

  // Fetch username from Firestore for Realtime DB readability
  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;

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

      // Initialize services AFTER getting userId
       /* final contactsService = TrustedContactsService();
        final notificationService = NotificationService(contactsService);
        
        await contactsService.subscribeToTrustedContacts(userId!);
        await notificationService.initialize();*/
        
    } catch (e) {
      debugPrint("Error fetching username: $e");
    }
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      final result = await Permission.locationWhenInUse.request();
      if (!result.isGranted) {
        debugPrint("Location permission denied.");
      }
    }
  }
  //Request mic permission
/*  Future<void> _requestMicPermission() async {
  final status = await Permission.microphone.status;
  if (!status.isGranted) {
    final result = await Permission.microphone.request();
    if (!result.isGranted) {
      debugPrint("Microphone permission denied.");
    }
  }
}*/

  void toggleStatus() async {
    final newStatus = await _locationStatusService.toggleStatus(status);
    setState(() {
      status = newStatus;
    });

    if(status == 'RED'){
      _startRecording();
    }
    else if(status == 'OFF'){
      _stopRecording();
    }
  }


  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        // Request MANAGE_EXTERNAL_STORAGE permission for Android 11+
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
                child: Center(child: SvgPicture.asset("lib/assets/icons/TrustNet-logo-only.svg",
                  width: 150,
                  height: 150,
                  colorFilter: ColorFilter.mode(status=="GREEN" ? Colors.green : status=="RED" ? Colors.red: Colors.grey, BlendMode.srcIn)
                    ,)),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: toggleStatus,
              child: Text(
                "Status: $status",
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
