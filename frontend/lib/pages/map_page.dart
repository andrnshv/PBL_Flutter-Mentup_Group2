import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _center = LatLng(-7.9425, 112.6131);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mentoring Location")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: _center, zoom: 15),
        markers: {
          const Marker(
            markerId: MarkerId('main_loc'),
            position: _center,
            infoWindow: InfoWindow(title: 'MentUp Center'),
          ),
        },
      ),
    );
  }
}
