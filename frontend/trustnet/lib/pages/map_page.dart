import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSMapPage extends StatefulWidget {
  const SOSMapPage({super.key});

  @override
  State<SOSMapPage> createState() => _SOSMapPageState();
}

class _SOSMapPageState extends State<SOSMapPage> {
  final MapController _mapController = MapController();

  // example live user data — you’ll later replace this with Firebase data
  final List<Map<String, dynamic>> users = [
    {'name': 'Aditi', 'lat': 12.9716, 'lng': 77.5946},  // Bengaluru
    {'name': 'Rohan', 'lat': 13.0827, 'lng': 80.2707},  // Chennai
  ];

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
          initialCenter: LatLng(12.9716, 77.5946),
          initialZoom: 15.0,
        ),
        children: [
          // Base map layer (tiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.sosapp', // replace with your package name
          ),

          // Marker layer
          MarkerLayer(
            markers: users.map((user) {
              return Marker(
                width: 50,
                height: 50,
                point: LatLng(user['lat'], user['lng']),
                child: GestureDetector(
                  onTap: () => _launchMaps(user['lat'], user['lng']),
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 52),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
