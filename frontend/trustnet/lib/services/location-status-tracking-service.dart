import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class LocationStatusTrackingService {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://trustnet-an-sos-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final DatabaseReference _dbRef;
  Timer? _locationTimer;
  Position? _lastPosition;
  bool _isRedMode = false;
  String? _userId;

  final StreamController<String> _statusController =
      StreamController.broadcast();

  Stream<String> get statusStream => _statusController.stream;

  LocationStatusTrackingService() {
    _dbRef = _rtdb.ref().child("users");
  }

  /// Initialize the service with the current user ID
  Future<void> initialize(String userId) async {
    _userId = userId;
  }

  /// Toggle status and update location
  /// Returns the new status
  Future<String> toggleStatus(String currentStatus) async {
    String newStatus;

    if (currentStatus == "OFF") {
      newStatus = "GREEN";
      _isRedMode = false;
    } else if (currentStatus == "GREEN") {
      newStatus = "RED";
      _isRedMode = true;
    } else {
      newStatus = "OFF";
      _isRedMode = false;
    }

    // Update immediately
    await _updateLocationInDB(redMode: _isRedMode);

    // Then start/stop periodic updates
    if (newStatus != "OFF") {
      _startLiveLocation();
    } else {
      await _stopLiveLocation();
    }

    _statusController.add(newStatus);
    return newStatus;
  }

  /// Start periodic location updates every 20 seconds
  void _startLiveLocation() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await _updateLocationInDB(redMode: _isRedMode);
    });
  }

  /// Stop location updates and set status to OFF
  Future<void> _stopLiveLocation() async {
    _locationTimer?.cancel();
    _locationTimer = null;

    if (_userId == null) return;
    await _dbRef.child(_userId!).update({
      "status": "OFF",
      "lastUpdated": DateTime.now().toIso8601String(),
    });
  }

  /// Update location and status in Realtime DB
  Future<void> _updateLocationInDB({required bool redMode}) async {
    if (_userId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Skip update if user hasn't moved significantly (unless in red mode)
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

      await _dbRef.child(_userId!).update(data);
      debugPrint("📍 Location updated: $data");
    } catch (e) {
      debugPrint("Location update failed: $e");
    }
  }

  /// Dispose resources
  void dispose() {
    _locationTimer?.cancel();
    _statusController.close();
  }
}
