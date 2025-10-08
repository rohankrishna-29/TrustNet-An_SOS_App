import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = "OFF";
  Timer? _locationTimer;
  String? username; // For readability in Realtime DB
  final Map<String, Color> statusColors = {
    "OFF": Colors.grey,
    "GREEN": Colors.green,
    "RED": Colors.red,
  };

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    "users",
  );

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() {
      username = doc.data()?['name'] ?? uid;
    });
  }

  void toggleStatus() {
    setState(() {
      if (status == "OFF") {
        status = "GREEN";
        _startLiveLocation();
      } else if (status == "GREEN") {
        status = "RED";
        _sendRedAlert();
      } else if (status == "RED") {
        status = "OFF";
        _stopLiveLocation();
      }
    });
  }

  void _startLiveLocation() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null || username == null) return;

        await _dbRef.child(uid).set({
          "username": username,
          "latitude": pos.latitude,
          "longitude": pos.longitude,
          "status": "GREEN",
          "lastUpdated": DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint("Location update failed: $e");
      }
    });
  }

  void _sendRedAlert() async {
    _locationTimer?.cancel();
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || username == null) return;

    await _dbRef.child(uid).set({
      "username": username,
      "latitude": pos.latitude,
      "longitude": pos.longitude,
      "status": "RED",
      "alert": true,
      "lastUpdated": DateTime.now().toIso8601String(),
    });
  }

  void _stopLiveLocation() async {
    _locationTimer?.cancel();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || username == null) return;

    await _dbRef.child(uid).set({
      "username": username,
      "status": "OFF",
      "lastUpdated": DateTime.now().toIso8601String(),
    });
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
                child: const Center(
                  child: Icon(Icons.golf_course_rounded), // placeholder logo
                ),
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
