import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = "OFF";
  Timer? _locationTimer;
  String? username; // For readable DB entries
  Position? _lastPosition;
  bool redMode=false;

  final Map<String, Color> statusColors = {
    "OFF": Colors.grey,
    "GREEN": Colors.green,
    "RED": Colors.red,
  };

  late final DatabaseReference _dbRef;

  @override
  void initState() {
    super.initState();

    _dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://trustnet-an-sos-app-default-rtdb.asia-southeast1.firebasedatabase.app",
    ).ref().child("users");

    _requestLocationPermission();
    _fetchUsername();
  }

  // Fetch username from Firestore for Realtime DB readability
  Future<void> _fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      setState(() {
        username = doc.data()?['name'] ?? uid;
      });
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

  void toggleStatus() {
    setState(() {
      if (status == "OFF") {
        status = "GREEN";
        _startLiveLocation();
      } else if (status == "GREEN") {
        status = "RED";
        _startLiveLocation(redMode: true);
      } else if (status == "RED") {
        status = "OFF";
        _stopLiveLocation();
      }
    });
  }

  void _startLiveLocation({redMode = false}) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await _updateLocationInDB(redMode: redMode);
    });
  }

  void _stopLiveLocation() async {
    _locationTimer?.cancel();
    _locationTimer = null;

    if (username == null) return;

    await _dbRef.child(username!).update({
      "status": "OFF",
      "lastUpdated": DateTime.now().toIso8601String(),
    });
  }

  Future<void> _updateLocationInDB({ redMode = false}) async {
    if (username == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Skip update if user hasn't moved significantly (optional)
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance < 5 && !redMode) return;
      }
      _lastPosition = position;

      final mapsUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      final data = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "mapsUrl": mapsUrl,
        "status": redMode ? "RED" : "GREEN",
        "lastUpdated": DateTime.now().toIso8601String(),
      };

      if (redMode) data["alert"] = true;

      // Keyed by username
      await _dbRef.child(username!).update(data);
    } catch (e) {
      debugPrint("Location update failed: $e");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
