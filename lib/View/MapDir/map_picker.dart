// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
//
// class MapPickerPopup extends StatefulWidget {
//   const MapPickerPopup({super.key});
//
//   @override
//   State<MapPickerPopup> createState() => _MapPickerPopupState();
// }
//
// class _MapPickerPopupState extends State<MapPickerPopup> {
//
//   LatLng selectedLocation = const LatLng(26.8467, 80.9462); // Lucknow
//   String address = "Select location";
//
//   Future<void> getAddress(LatLng latLng) async {
//
//     List<Placemark> placemarks =
//     await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
//
//     final place = placemarks.first;
//
//     setState(() {
//       address =
//       "${place.street}, ${place.locality}, ${place.administrativeArea}";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: 700,
//         height: 500,
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//
//             /// Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Select Hub Location",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 )
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             /// MAP
//             Expanded(
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: selectedLocation,
//                   zoom: 14,
//                 ),
//                 onTap: (LatLng latLng) async {
//                   setState(() {
//                     selectedLocation = latLng;
//                   });
//
//                   await getAddress(latLng);
//                 },
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId("hub"),
//                     position: selectedLocation,
//                   )
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// Address Preview
//             Container(
//               padding: const EdgeInsets.all(10),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(address),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// Confirm Button
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, {
//                   "lat": selectedLocation.latitude,
//                   "lng": selectedLocation.longitude,
//                   "address": address
//                 });
//               },
//               child: const Text("Confirm Location"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:quick_ecommerce_city_panel_redefined/View/MapDir/google_search_box.dart';

class MapPickerPopup extends StatefulWidget {
  const MapPickerPopup({super.key});

  @override
  State<MapPickerPopup> createState() => _MapPickerPopupState();
}

class _MapPickerPopupState extends State<MapPickerPopup> {
  GoogleMapController? mapController;

  LatLng selectedLocation = const LatLng(26.8467, 80.9462);
  String address = "Select location";

  double radius = 1; // KM
  Set<Circle> circles = {};

  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];

  Timer? _debounce;

  /// 🔑 PUT YOUR API KEY HERE
  // final String apiKey = "AIzaSyAW2lp2BYRmy8oD3ppvvegrql2MlMa-4tI";
  final String apiKey = "AIzaSyB0mG3CGok9-9RZau5J_VThUP4OTbQ_SFM";

  // ================= ADDRESS =================
  Future<void> getAddress(LatLng latLng) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = placemarks.first;

    setState(() {
      address =
      "${place.street}, ${place.locality}, ${place.administrativeArea}";
    });
  }

  // ================= CIRCLE =================
  void updateCircle() {
    setState(() {
      circles = {
        Circle(
          circleId: const CircleId("coverage"),
          center: selectedLocation,
          radius: radius * 1000,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        )
      };
    });
  }

  // ================= SEARCH =================
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchPlaces(query);
    });
  }

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        searchResults = data["predictions"];
      });
    }
  }



  Future<void> selectPlace(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final location = data["result"]["geometry"]["location"];

    final latLng = LatLng(location["lat"], location["lng"]);

    setState(() {
      selectedLocation = latLng;
      searchResults = [];
      searchController.clear();
    });

    await getAddress(latLng);
    updateCircle();

    mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }

  @override
  void initState() {
    super.initState();
    updateCircle();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [

            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Select Hub Location",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: onSearchChanged,
              ),
            ),
            // GoogleSearchBox(
            //   onSelected: (lat, lng, address) async {
            //     final latLng = LatLng(lat, lng);
            //
            //     setState(() {
            //       selectedLocation = latLng;
            //       this.address = address;
            //     });
            //
            //     updateCircle();
            //
            //     mapController?.animateCamera(
            //       CameraUpdate.newLatLng(latLng),
            //     );
            //   },
            // ),

            /// 🔍 SEARCH RESULTS
            if (searchResults.isNotEmpty)
              Container(
                height: 150,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final place = searchResults[index];

                    return ListTile(
                      title: Text(place["description"]),
                      onTap: () =>
                          selectPlace(place["place_id"]),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            /// MAP
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedLocation,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                },
                onTap: (LatLng latLng) async {
                  setState(() {
                    selectedLocation = latLng;
                  });

                  await getAddress(latLng);
                  updateCircle();
                },
                circles: circles,
                markers: {
                  Marker(
                    markerId: const MarkerId("hub"),
                    position: selectedLocation,
                  )
                },
              ),
            ),

            /// 🔥 RADIUS SLIDER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text("Radius: "),
                  Expanded(
                    child: Slider(
                      value: radius,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: "${radius.toInt()} KM",
                      onChanged: (value) {
                        setState(() {
                          radius = value;
                        });
                        updateCircle();
                      },
                    ),
                  ),
                  Text("${radius.toInt()} km"),
                ],
              ),
            ),

            /// ADDRESS
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(address),
            ),

            /// CONFIRM BUTTON
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "lat": selectedLocation.latitude,
                  "lng": selectedLocation.longitude,
                  "address": address,
                  "radius": radius,
                });
              },
              child: const Text("Confirm Location"),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}