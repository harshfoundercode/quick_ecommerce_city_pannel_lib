import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerPopup extends StatefulWidget {
  const MapPickerPopup({super.key});

  @override
  State<MapPickerPopup> createState() => _MapPickerPopupState();
}

class _MapPickerPopupState extends State<MapPickerPopup> {

  LatLng selectedLocation = const LatLng(26.8467, 80.9462); // Lucknow
  String address = "Select location";

  Future<void> getAddress(LatLng latLng) async {

    List<Placemark> placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = placemarks.first;

    setState(() {
      address =
      "${place.street}, ${place.locality}, ${place.administrativeArea}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 500,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [

            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Hub Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 10),

            /// MAP
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedLocation,
                  zoom: 14,
                ),
                onTap: (LatLng latLng) async {
                  setState(() {
                    selectedLocation = latLng;
                  });

                  await getAddress(latLng);
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("hub"),
                    position: selectedLocation,
                  )
                },
              ),
            ),

            const SizedBox(height: 10),

            /// Address Preview
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(address),
            ),

            const SizedBox(height: 10),

            /// Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "lat": selectedLocation.latitude,
                  "lng": selectedLocation.longitude,
                  "address": address
                });
              },
              child: const Text("Confirm Location"),
            )
          ],
        ),
      ),
    );
  }
}