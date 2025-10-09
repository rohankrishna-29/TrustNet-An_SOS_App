import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    //_loadCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}