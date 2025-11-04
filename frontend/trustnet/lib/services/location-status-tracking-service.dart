import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_geohash/dart_geohash.dart';

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

  /// 🆕 Compute geohash for given lat/lon
  String _computeGeohash(double latitude, double longitude) {
    final geoHasher = GeoHasher();
    return geoHasher.encode(longitude, latitude);
  }

  /// Initialize the service with the current user ID
  Future<void> initialize(String userId) async {
    _userId = userId;

    final name = await getUserName(userId);
    if (name != null) {
      await _dbRef.child(userId).update({
        "name": name,
      });
    }

    // Start passive updates immediately at launch (OFF mode)
    startPassiveLocationUpdates();
  }

  Future<String?> getUserName(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.get('name') as String?;
      } else {
        debugPrint("User document doesnt exist for user id: $userId");
        return null;
      }
    } catch (e) {
      debugPrint("Failed to fetch username: $e");
      return null;
    }
  }

  /// Start passive OFF mode updates: immediate + every 2 minutes
  void startPassiveLocationUpdates() {
    _locationTimer?.cancel();
    _updateLocationPassive(); // immediate update once

    _locationTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      await _updateLocationPassive();
    });
  }

  /// Passive location update (does not change status)
  Future<void> _updateLocationPassive() async {
    if (_userId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final mapsUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      final geohash = _computeGeohash(position.latitude, position.longitude);

      await _dbRef.child(_userId!).update({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "geohash": geohash,
        "mapsUrl": mapsUrl,
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      debugPrint("📍 Passive OFF update sent (no status change)");
    } catch (e) {
      debugPrint("⚠️ Passive location update failed: $e");
    }
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

    _locationTimer?.cancel();

    if (newStatus == "OFF") {
      // 🟤 When going OFF: update with status OFF + location + time, then slow updates
      await _updateLocationAndStatusOff();
      startPassiveLocationUpdates();
    } else {
      // 🟢/🔴 For GREEN/RED: immediate update, then every 20 sec
      await _updateLocationInDB(redMode: _isRedMode);
      _startLiveLocation();
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

  /// Update location and status=OFF explicitly when turning off
  Future<void> _updateLocationAndStatusOff() async {
    if (_userId == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final mapsUrl =
          "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
      final geohash = _computeGeohash(position.latitude, position.longitude);

      await _dbRef.child(_userId!).update({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "geohash": geohash,
        "mapsUrl": mapsUrl,
        "status": "OFF",
        "lastUpdated": DateTime.now().toIso8601String(),
      });

      debugPrint("🟤 Switched to OFF: location and status updated immediately");
    } catch (e) {
      debugPrint("⚠️ Failed to update OFF status: $e");
    }
  }

  /// Update location and status (GREEN or RED)
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
      
      final geohash = _computeGeohash(position.latitude, position.longitude);

      final data = {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "geohash": geohash,
        "mapsUrl": mapsUrl,
        "status": redMode ? "RED" : "GREEN",
        "lastUpdated": DateTime.now().toIso8601String(),
      };

      await _dbRef.child(_userId!).update(data);
      debugPrint("📍 Location updated: $data");
    } catch (e) {
      debugPrint("⚠️ Location update failed: $e");
    }
  }

  /// Dispose resources
  void dispose() {
    _locationTimer?.cancel();
    _statusController.close();
  }
}
