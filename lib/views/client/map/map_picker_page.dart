import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selected;

  static const LatLng initialLocation =
      LatLng(-7.9425, 112.6131);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
      ),
      body: Stack(
        children: [
          /// MAP
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: initialLocation,
              zoom: 14,
            ),
            onTap: (LatLng position) {
              setState(() {
                selected = position;
              });
            },
            markers: selected == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selected!,
                    )
                  },
          ),

          /// INFO TEXT
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Text(
                selected == null
                    ? "Tap pada peta untuk memilih lokasi"
                    : "Lokasi dipilih ✔",
                textAlign: TextAlign.center,
              ),
            ),
          ),

          /// BUTTON BAWAH (SATU-SATUNYA KONFIRMASI)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: selected == null
                  ? null
                  : () {
                      Navigator.pop(context, selected);
                    },
              child: const Text("Confirm Location"),
            ),
          )
        ],
      ),
    );
  }
}