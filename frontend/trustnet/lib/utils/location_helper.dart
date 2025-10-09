// lib/utils/location_helper.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  /// Requests permission and returns the user's current location
  static Future<Position?> getCurrentLocation() async {
    // Request permission first
    var permission = await Permission.location.status;
    if (!permission.isGranted) {
      permission = await Permission.location.request();
      if (!permission.isGranted) {
        print("Location permission denied");
        return null;
      }
    }

    try {
      // Get current GPS position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}
