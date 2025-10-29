import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trustnet/services/location_service.dart'; // 👈 update this import

class SOSMapPage extends StatefulWidget {
  final String currentUserId; // 🔹 pass the current user’s ID to know whose contacts to fetch
  const SOSMapPage({required this.currentUserId, super.key});

  @override
  State<SOSMapPage> createState() => _SOSMapPageState();
}

class _SOSMapPageState extends State<SOSMapPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  /// This will hold the real-time updated contact locations
  final Map<String, Map<String, dynamic>> _contactLocations = {};

  @override
  void initState() {
    super.initState();

    // Step 1: Start listening to trusted contacts
    _locationService.subscribeToTrustedContacts(widget.currentUserId);

    // Step 2: Listen to incoming updates
    _locationService.contactUpdatesStream.listen((update) {
      setState(() {
        _contactLocations[update['userId']] = update;
      });
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
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(12.9716, 77.5946),
          initialZoom: 13.0,
        ),
        children: [
          // 🔹 Base map tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sosapp',
          ),

          // 🔹 Markers for each contact
          MarkerLayer(
            markers: _contactLocations.values.map((contact) {
              final lat = contact['latitude'];
              final lng = contact['longitude'];
              final status = contact['status'];

              // Pick color based on status (optional)
              Color pinColor;
              switch (status) {
                case 'GREEN': pinColor = Colors.green;
                  break;
                case 'YELLOW': pinColor = Colors.amber;
                  break;
                case 'RED': pinColor = Colors.red;
                  break;
                default: pinColor = Colors.grey;
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
          ),
        ],
      ),
    );
  }
}
