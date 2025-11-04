import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trustnet/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class SOSMapPage extends StatefulWidget {
  final String currentUserId;
  const SOSMapPage({required this.currentUserId, super.key});

  @override
  State<SOSMapPage> createState() => _SOSMapPageState();
}

class _SOSMapPageState extends State<SOSMapPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  /// This will hold the real-time updated contact locations
  final Map<String, Map<String, dynamic>> _contactLocations = {};

  LatLng? _userLatLng; // 👈 your current position
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  Future<void> _initMapData() async {
    await _getUserLocation(); // fetch your current position first

    // Then subscribe to trusted contacts
    _locationService.subscribeToTrustedContacts(widget.currentUserId);

    // Listen for contact updates
    _locationService.contactUpdatesStream.listen((update) {
      setState(() {
        _contactLocations[update['userId']] = update;
      });
    });
  }

  /// Get the current user’s GPS location
  Future<void> _getUserLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint("❌ Location permission denied");
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint("❌ Location permission permanently denied");
    return;
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );

  setState(() {
    _userLatLng = LatLng(position.latitude, position.longitude);
    _isLoading = false;
  });

  // ✅ move only after map is rendered
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      try {
        _mapController.move(_userLatLng!, 15.0);
      } catch (e) {
        debugPrint("⚠️ Map not ready yet: $e");
      }
    }
  });
}



  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _userLatLng == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userLatLng!,
          initialZoom: 13.5,
        ),
        children: [
          // 🔹 Base map tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.trustnet',
          ),

          // 🔹 Markers (contacts + user)
          MarkerLayer(
            markers: [
              // 🟦 Your location marker
              Marker(
                width: 60,
                height: 60,
                point: _userLatLng!,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.blueAccent,
                  size: 48,
                ),
              ),

              // 🧍‍♂️ Trusted contacts
              ..._contactLocations.values.map((contact) {
                final lat = contact['latitude'];
                final lng = contact['longitude'];
                final status = contact['status'];

                Color pinColor;
                switch (status) {
                  case 'GREEN':
                    pinColor = Colors.green;
                    break;
                  case 'YELLOW':
                    pinColor = Colors.amber;
                    break;
                  case 'RED':
                    pinColor = Colors.red;
                    break;
                  default:
                    pinColor = Colors.grey;
                }

                return Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(lat, lng),
                  child: GestureDetector(
                    onTap: () => _launchMaps(lat, lng),
                    child: Icon(Icons.location_pin, color: pinColor, size: 52),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),

      // 🔄 Button to refresh your location manually
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.my_location),
        onPressed: _getUserLocation,
      ),
    );
  }
}
