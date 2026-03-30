// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_zone_list_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_zone_list_view_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';
//
// class MapPickerPopup extends StatefulWidget {
//   final Data? cityZone;
//   const MapPickerPopup({super.key, this.cityZone});
//
//   @override
//   State<MapPickerPopup> createState() => _MapPickerPopupState();
// }
//
// class _MapPickerPopupState extends State<MapPickerPopup>
//     with SingleTickerProviderStateMixin {
//   // ── Map controller ──────────────────────────────────────────────────────
//   final Completer<GoogleMapController> _mapControllerCompleter = Completer();
//   GoogleMapController? _mapController;
//
//   // ── City boundary ───────────────────────────────────────────────────────
//   late LatLng _cityCenter;
//   late double _cityRadiusKm;
//
//   // ── Selected hub pin ─────────────────────────────────────────────────────
//   late LatLng _selectedLocation;
//   bool _isOutsideBoundary = false;
//
//   // ── Hub coverage radius ──────────────────────────────────────────────────
//   double _hubRadius = 1.0;
//   late TextEditingController _radiusCtrl;
//
//   // ── Address ──────────────────────────────────────────────────────────────
//   String _street = '';
//   String _city = '';
//   String _state = '';
//   String _pincode = '';
//   bool _addressLoading = false;
//
//   // ── Search ───────────────────────────────────────────────────────────────
//   final TextEditingController _searchCtrl = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();
//   List<dynamic> _searchResults = [];
//   bool _searchLoading = false;
//   Timer? _debounce;
//
//   // ── Search outside-city warning ─────────────────────────────────────────
//   bool _searchResultOutside = false;
//   String _searchOutsideMsg = '';
//
//   // ── Entry animation ──────────────────────────────────────────────────────
//   late AnimationController _slideCtrl;
//   late Animation<double> _slideAnim;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.cityZone != null) {
//       _cityCenter = LatLng(
//         double.parse(widget.cityZone!.lat.toString()),
//         double.parse(widget.cityZone!.long.toString()),
//       );
//     } else {
//       _cityCenter = const LatLng(26.8467, 80.9462);
//     }
//     _cityRadiusKm =
//         double.tryParse(widget.cityZone?.radiuskm?.toString() ?? '') ?? 10.0;
//
//     _selectedLocation = _cityCenter;
//     _hubRadius = (_hubRadius).clamp(0.5, _cityRadiusKm);
//     _radiusCtrl = TextEditingController(text: _hubRadius.toStringAsFixed(1));
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<HubZoneViewModel>(context, listen: false).getHubZoneListDataApi(context);
//       print("kjkgjgjhgjg");
//       Provider.of<CityZoneListViewModel>(context, listen: false)
//           .getCityZoneDataApi(context);
//       _fetchAddress(_selectedLocation);
//       Future.delayed(const Duration(milliseconds: 500), _fitCityBoundary);
//     });
//
//     _slideCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 380),
//     );
//     _slideAnim = CurvedAnimation(
//       parent: _slideCtrl,
//       curve: Curves.easeOutCubic,
//     );
//     _slideCtrl.forward();
//
//     _searchFocus.addListener(() {
//       if (!_searchFocus.hasFocus) {
//         Future.delayed(const Duration(milliseconds: 150), () {
//           if (mounted) setState(() => _searchResults = []);
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _mapController?.dispose();
//     _searchCtrl.dispose();
//     _searchFocus.dispose();
//     _radiusCtrl.dispose();
//     _slideCtrl.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   // ── Camera helpers ──────────────────────────────────────────────────────
//
//   void _fitCityBoundary() {
//     if (_mapController == null) return;
//     final zoom = _radiusToZoom(_cityRadiusKm);
//     _mapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: _cityCenter, zoom: zoom),
//       ),
//     );
//   }
//
//   void _fitHubCoverage() {
//     if (_mapController == null) return;
//     final zoom = _radiusToZoom(_hubRadius);
//     _mapController!.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: _selectedLocation, zoom: zoom),
//       ),
//     );
//   }
//
//   double _radiusToZoom(double radiusKm) {
//     const double base = 14.0;
//     final double delta = log(radiusKm / 0.5) / log(2);
//     return (base - delta).clamp(3.0, 18.0);
//   }
//
//   // ── Distance / boundary helpers ─────────────────────────────────────────
//
//   double _distanceKm(LatLng a, LatLng b) {
//     const r = 6371.0;
//     final dLat = _deg2rad(b.latitude - a.latitude);
//     final dLon = _deg2rad(b.longitude - a.longitude);
//     final sinDLat = sin(dLat / 2);
//     final sinDLon = sin(dLon / 2);
//     final x = sinDLat * sinDLat +
//         cos(_deg2rad(a.latitude)) *
//             cos(_deg2rad(b.latitude)) *
//             sinDLon *
//             sinDLon;
//     return r * 2 * atan2(sqrt(x), sqrt(1 - x));
//   }
//
//   double _deg2rad(double deg) => deg * pi / 180;
//
//   bool _isInsideCity(LatLng point) =>
//       _distanceKm(point, _cityCenter) <= _cityRadiusKm;
//
//   bool _isOverlapping() {
//     final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
//     for (var zone in hubVM.hubZones) {
//       final existingCenter = LatLng(
//         double.parse(zone.latitude.toString()),
//         double.parse(zone.longitude.toString()),
//       );
//       final existingRadius = double.parse(zone.radiuskm.toString());
//       if (_distanceKm(_selectedLocation, existingCenter) <
//           (_hubRadius + existingRadius)) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   bool _checkOverlapWithNewLocation(LatLng newLocation) {
//     final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
//     for (var zone in hubVM.hubZones) {
//       final existingCenter = LatLng(
//         double.parse(zone.latitude.toString()),
//         double.parse(zone.longitude.toString()),
//       );
//       final existingRadius = double.parse(zone.radiuskm.toString());
//       if (_distanceKm(newLocation, existingCenter) <
//           (_hubRadius + existingRadius)) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   bool _checkOverlapWithRadius(double testRadius) {
//     final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
//     for (var zone in hubVM.hubZones) {
//       final existingCenter = LatLng(
//         double.parse(zone.latitude.toString()),
//         double.parse(zone.longitude.toString()),
//       );
//       final existingRadius = double.parse(zone.radiuskm.toString());
//       if (_distanceKm(_selectedLocation, existingCenter) <
//           (testRadius + existingRadius)) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   // ── Overlays ─────────────────────────────────────────────────────────────
//
//   Set<Circle> get _circles {
//     final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
//     Set<Circle> allCircles = {
//       Circle(
//         circleId: const CircleId('city_boundary'),
//         center: _cityCenter,
//         radius: _cityRadiusKm * 1000,
//         fillColor: const Color(0xFF2563EB).withValues(alpha: 0.06),
//         strokeColor: _isOutsideBoundary
//             ? Colors.red.withValues(alpha: 0.7)
//             : const Color(0xFF2563EB).withValues(alpha: 0.5),
//         strokeWidth: _isOutsideBoundary ? 3 : 2,
//       ),
//       Circle(
//         circleId: const CircleId('hub_coverage'),
//         center: _selectedLocation,
//         radius: _hubRadius * 1000,
//         fillColor: _isOutsideBoundary
//             ? Colors.red.withValues(alpha: 0.10)
//             : ColorConst.primaryGreen.withValues(alpha: 0.12),
//         strokeColor: _isOutsideBoundary
//             ? Colors.red.withValues(alpha: 0.6)
//             : ColorConst.primaryGreen.withValues(alpha: 0.7),
//         strokeWidth: 2,
//       ),
//     };
//     for (var zone in hubVM.hubZones) {
//       allCircles.add(
//         Circle(
//           circleId: CircleId("existing_${zone.id}"),
//           center: LatLng(
//             double.parse(zone.latitude.toString()),
//             double.parse(zone.longitude.toString()),
//           ),
//           radius: double.parse(zone.radiuskm.toString()) * 1000,
//           fillColor: Colors.orange.withValues(alpha: 0.10),
//           strokeColor: Colors.orange.withValues(alpha: 0.6),
//           strokeWidth: 2,
//         ),
//       );
//     }
//     return allCircles;
//   }
//
//   Set<Marker> get _markers => {
//     Marker(
//       markerId: const MarkerId('city_center'),
//       position: _cityCenter,
//       icon:
//       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       infoWindow: InfoWindow(
//         title: widget.cityZone?.name?.toString() ?? 'City Zone',
//         snippet: 'City boundary center',
//       ),
//       alpha: 0.7,
//     ),
//     Marker(
//       markerId: const MarkerId('hub'),
//       position: _selectedLocation,
//       icon: BitmapDescriptor.defaultMarkerWithHue(
//         _isOutsideBoundary
//             ? BitmapDescriptor.hueRed
//             : BitmapDescriptor.hueGreen,
//       ),
//     ),
//   };
//
//   // ── Map tap ───────────────────────────────────────────────────────────────
//
//   Future<void> _onMapTap(LatLng latLng) async {
//     final outside = !_isInsideCity(latLng);
//     final isOverlap = _checkOverlapWithNewLocation(latLng);
//
//     if (isOverlap) {
//       _showSnack("This location overlaps an existing hub zone!", isError: true);
//       return;
//     }
//
//     setState(() {
//       _selectedLocation = latLng;
//       _isOutsideBoundary = outside;
//       _searchResultOutside = false;
//     });
//
//     _fetchAddress(latLng);
//     _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
//   }
//
//   // ── Address ───────────────────────────────────────────────────────────────
//
//
//   Future<void> _fetchAddress(LatLng latLng) async {
//     if (!mounted) return;
//
//     setState(() {
//       _addressLoading = true;
//       _street = '';
//       _city = '';
//       _state = '';
//       _pincode = '';
//     });
//
//     try {
//       final uri = Uri.parse(
//         "https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=AIzaSyAW2lp2BYRmy8oD3ppvvegrql2MlMa-4tI",
//       );
//
//       final res = await http.get(uri).timeout(const Duration(seconds: 10));
//       if (!mounted) return;
//
//       if (res.statusCode == 200) {
//         final json = jsonDecode(res.body);
//         final List results = json['results'] ?? [];
//
//         if (results.isEmpty) return;
//
//         Map<String, dynamic>? bestResult;
//
//         // ✅ STEP 1: Find best result (priority based)
//         for (var r in results) {
//           final types = List<String>.from(r['types'] ?? []);
//
//           if (types.contains('street_address') ||
//               types.contains('premise') ||
//               types.contains('subpremise')) {
//             bestResult = r;
//             break;
//           }
//         }
//
//         // ✅ fallback to locality
//         bestResult ??= results.firstWhere(
//               (r) => (r['types'] as List).contains('locality'),
//           orElse: () => results.first,
//         );
//
//         // ✅ STEP 2: Parse address components
//         if (bestResult!['address_components'] != null) {
//           _parseGoogleComponents(bestResult['address_components']);
//         }
//
//         // ✅ STEP 3: FORCE pincode extraction from ALL results
//         String foundPincode = '';
//
//         for (var r in results) {
//           final components = r['address_components'] ?? [];
//           for (var comp in components) {
//             final types = List<String>.from(comp['types'] ?? []);
//             if (types.contains('postal_code')) {
//               foundPincode = comp['long_name'] ?? '';
//               break;
//             }
//           }
//           if (foundPincode.isNotEmpty) break;
//         }
//
//         if (foundPincode.isNotEmpty) {
//           setState(() => _pincode = foundPincode);
//         }
//
//         // ✅ STEP 4: fallback (if everything empty)
//         if (_street.isEmpty &&
//             _city.isEmpty &&
//             _state.isEmpty &&
//             results.isNotEmpty) {
//           final fallback = results.first['formatted_address'] ?? '';
//           setState(() {
//             _street = fallback;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('_fetchAddress error: $e');
//     } finally {
//       if (mounted) setState(() => _addressLoading = false);
//     }
//   }
//
//   /// Parses a raw Google Geocoding API `address_components` array.
//   void _parseGoogleComponents(List<dynamic> components) {
//     String streetNumber = '';
//     String route = '';
//     String sublocality = '';
//     String locality = '';
//     String adminArea = '';
//     String pincode = '';
//
//     for (final comp in components) {
//       final types = List<String>.from(comp['types'] ?? []);
//       final long = comp['long_name'] ?? '';
//
//       if (types.contains('street_number')) streetNumber = long;
//       if (types.contains('route')) route = long;
//       if (types.contains('sublocality') ||
//           types.contains('sublocality_level_1')) sublocality = long;
//       if (types.contains('locality')) locality = long;
//       if (types.contains('administrative_area_level_1')) adminArea = long;
//       if (types.contains('postal_code')) pincode = long;
//     }
//
//     setState(() {
//       _street = [streetNumber, route]
//           .where((e) => e.isNotEmpty)
//           .join(' ');
//       _city = [sublocality, locality]
//           .where((e) => e.isNotEmpty)
//           .join(', ');
//       _state = adminArea;
//       if (pincode.isNotEmpty) _pincode = pincode;
//     });
//   }
//
//   String _joinParts(List<String?> parts) =>
//       parts.where((p) => p != null && p.isNotEmpty).join(', ');
//
//   String get _fullAddress => [
//     if (_street.isNotEmpty) _street,
//     if (_city.isNotEmpty) _city,
//     if (_state.isNotEmpty) _state,
//     if (_pincode.isNotEmpty) _pincode,
//   ].join(', ');
//
//   // ── Search ────────────────────────────────────────────────────────────────
//
//   void _onSearchChanged(String q) {
//     _debounce?.cancel();
//     setState(() {
//       _searchResultOutside = false;
//       _searchOutsideMsg = '';
//     });
//     if (q.trim().isEmpty) {
//       setState(() => _searchResults = []);
//       return;
//     }
//     setState(() => _searchLoading = true);
//     _debounce = Timer(
//       const Duration(milliseconds: 450),
//           () => _searchPlaces(q),
//     );
//   }
//
//   Future<void> _searchPlaces(String q) async {
//     try {
//       final res = await http.get(Uri.parse(ApiUrl.mapPlaceAutoCompleteUrl(q)));
//       if (!mounted) return;
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         setState(() => _searchResults = data['data'] ?? []);
//       }
//     } catch (_) {
//     } finally {
//       if (mounted) setState(() => _searchLoading = false);
//     }
//   }
//
//   /// FIX 1: Properly await address fetch before setState
//   /// FIX 2: Check if searched location is outside city boundary and show warning
//   Future<void> _selectPlace(String placeId) async {
//     // Clear search UI immediately
//     setState(() {
//       _searchResults = [];
//       _searchCtrl.clear();
//       _searchResultOutside = false;
//       _searchOutsideMsg = '';
//     });
//     _searchFocus.unfocus();
//
//     try {
//       final res =
//       await http.get(Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId)));
//       if (!mounted) return;
//
//       final data = jsonDecode(res.body);
//       final loc = data['data'];
//
//       if (loc == null) {
//         _showSnack("Could not fetch location details.", isError: true);
//         return;
//       }
//
//       final latLng = LatLng(
//         double.parse(loc['lat'].toString()),
//         double.parse(loc['lng'].toString()),
//       );
//
//       final outside = !_isInsideCity(latLng);
//
//       // FIX 2: Show warning if searched place is outside city zone
//       if (outside) {
//         setState(() {
//           _searchResultOutside = true;
//           _searchOutsideMsg =
//           'This place is outside the city zone "${widget.cityZone?.name ?? 'boundary'}". '
//               'Only locations inside the blue circle are allowed.';
//           // Still move camera so user can see where it is
//           _selectedLocation = latLng;
//           _isOutsideBoundary = true;
//         });
//       } else {
//         // Check overlap
//         final isOverlap = _checkOverlapWithNewLocation(latLng);
//         if (isOverlap) {
//           _showSnack("This location overlaps an existing hub zone!",
//               isError: true);
//           return;
//         }
//         setState(() {
//           _selectedLocation = latLng;
//           _isOutsideBoundary = false;
//           _searchResultOutside = false;
//         });
//       }
//
//       // FIX 1: Fetch address and THEN update state (await properly)
//       await _fetchAddress(latLng);
//
//       // FIX 1: Move camera AFTER address fetch, guaranteed to reach location
//       if (_mapController != null) {
//         await _mapController!.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(target: latLng, zoom: 14.0),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("SELECT PLACE ERROR: $e");
//       if (mounted) _showSnack("Failed to load place details.", isError: true);
//     }
//   }
//
//   // ── Radius ────────────────────────────────────────────────────────────────
//
//   void _onRadiusSlider(double val) {
//     final isOverlap = _checkOverlapWithRadius(val);
//     if (isOverlap) {
//       _showSnack("Radius will overlap an existing hub zone!", isError: true);
//       return;
//     }
//     setState(() {
//       _hubRadius = val;
//       _radiusCtrl.text = val.toStringAsFixed(1);
//     });
//     _fitHubCoverage();
//   }
//
//   void _onRadiusField(String val) {
//     final parsed = double.tryParse(val);
//     if (parsed != null && parsed >= 0.5 && parsed <= _cityRadiusKm) {
//       final isOverlap = _checkOverlapWithRadius(parsed);
//       if (isOverlap) {
//         _showSnack("This radius overlaps an existing hub zone!", isError: true);
//         return;
//       }
//       setState(() => _hubRadius = parsed);
//       _fitHubCoverage();
//     }
//   }
//
//   // ── Confirm ───────────────────────────────────────────────────────────────
//
//   void _confirm() {
//     if (_isOutsideBoundary) return;
//     if (_isOverlapping()) {
//       _showSnack("Hub overlaps with an existing zone!", isError: true);
//       return;
//     }
//     Navigator.pop(context, {
//       'lat': _selectedLocation.latitude,
//       'lng': _selectedLocation.longitude,
//       'address': _fullAddress,
//       'pincode': _pincode,
//       'radius': _hubRadius,
//     });
//     print({
//       'lat': _selectedLocation.latitude,
//       'lng': _selectedLocation.longitude,
//       'address': _fullAddress,
//       'pincode': _pincode,
//       'radius': _hubRadius,
//     });
//     print("dwbdwbd");
//   }
//
//   // ── Snackbar helper ───────────────────────────────────────────────────────
//
//   void _showSnack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
//               color: Colors.white,
//               size: 16,
//             ),
//             const SizedBox(width: 8),
//             Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
//           ],
//         ),
//         backgroundColor:
//         isError ? const Color(0xFFEF4444) : ColorConst.primaryGreen,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   // ── Build ─────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;
//
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: sw > 700 ? (sw - 680) / 2 : 12,
//         vertical: 20,
//       ),
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, 0.08),
//           end: Offset.zero,
//         ).animate(_slideAnim),
//         child: FadeTransition(
//           opacity: _slideAnim,
//           child: Container(
//             width: 680,
//             height: sh * 0.9,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.14),
//                   blurRadius: 40,
//                   offset: const Offset(0, 12),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(24),
//               child: SingleChildScrollView(
//                 child: Container(
//                   height: Sizes.screenHeight,
//                   child: Column(
//                     children: [
//                       _buildHeader(),
//                       _buildZoneStrip(),
//                       _buildSearchBar(),
//                       if (_searchResults.isNotEmpty) _buildSearchDropdown(),
//                       // FIX 2: Show outside-city warning below search results
//                       if (_searchResultOutside) _buildSearchOutsideWarning(),
//                       Expanded(child: _buildMap()),
//                       _buildBottomPanel(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Header ────────────────────────────────────────────────────────────────
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.map_rounded,
//                 size: 18, color: ColorConst.primaryGreen),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Select Hub Location',
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF111827))),
//                 Text('Hub must be inside the city boundary',
//                     style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F5F9),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.close_rounded,
//                   size: 18, color: Color(0xFF374151)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── City zone strip ───────────────────────────────────────────────────────
//
//   Widget _buildZoneStrip() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2563EB).withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//             color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2563EB).withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.location_city_rounded,
//                 size: 14, color: Color(0xFF2563EB)),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: RichText(
//               text: TextSpan(
//                 style:
//                 const TextStyle(fontSize: 12, color: Color(0xFF374151)),
//                 children: [
//                   const TextSpan(
//                       text: 'City Zone: ',
//                       style: TextStyle(fontWeight: FontWeight.w500)),
//                   TextSpan(
//                       text: widget.cityZone?.name?.toString() ?? '—',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF2563EB))),
//                   TextSpan(
//                       text:
//                       '  •  Radius: ${_cityRadiusKm.toStringAsFixed(1)} km'),
//                 ],
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: _fitCityBoundary,
//             child: Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2563EB).withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.fit_screen_rounded,
//                       size: 12, color: Color(0xFF2563EB)),
//                   SizedBox(width: 4),
//                   Text('Fit Zone',
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2563EB))),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Out-of-boundary warning (map tap) ─────────────────────────────────────
//
//   Widget _buildOutsideWarning() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade300),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning_amber_rounded,
//               size: 16, color: Colors.red.shade600),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'This location is outside the city boundary. '
//                   'Move the pin inside the blue circle to continue.',
//               style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.red.shade700,
//                   fontWeight: FontWeight.w500),
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               setState(() {
//                 _selectedLocation = _cityCenter;
//                 _isOutsideBoundary = false;
//                 _searchResultOutside = false;
//               });
//               _mapController
//                   ?.animateCamera(CameraUpdate.newLatLng(_cityCenter));
//               await _fetchAddress(_cityCenter);
//             },
//             child: Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text('Reset',
//                   style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.red.shade700)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── NEW: Outside warning specifically for search results ──────────────────
//
//   Widget _buildSearchOutsideWarning() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 250),
//       margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.red.shade50, Colors.orange.shade50],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(5),
//             decoration: BoxDecoration(
//               color: Colors.red.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.location_off_rounded,
//                 size: 14, color: Colors.red.shade700),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Location Outside City Zone',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.red.shade800),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _searchOutsideMsg,
//                   style: TextStyle(
//                       fontSize: 11, color: Colors.red.shade700, height: 1.4),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               setState(() {
//                 _selectedLocation = _cityCenter;
//                 _isOutsideBoundary = false;
//                 _searchResultOutside = false;
//                 _searchOutsideMsg = '';
//               });
//               _mapController
//                   ?.animateCamera(CameraUpdate.newLatLng(_cityCenter));
//               await _fetchAddress(_cityCenter);
//             },
//             child: Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade600,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text('Reset',
//                   style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Search bar ────────────────────────────────────────────────────────────
//
//   Widget _buildSearchBar() {
//     return Column(
//       children: [
//         Container(
//           margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//           height: 46,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(13),
//             border: Border.all(color: const Color(0xFFE5E7EB)),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.04),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2)),
//             ],
//           ),
//           child: Row(
//             children: [
//               const SizedBox(width: 12),
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 200),
//                 child: _searchLoading
//                     ? const SizedBox(
//                   key: ValueKey('load'),
//                   width: 15,
//                   height: 15,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: ColorConst.primaryGreen),
//                 )
//                     : const Icon(Icons.search_rounded,
//                     key: ValueKey('icon'),
//                     size: 18,
//                     color: ColorConst.primaryGreen),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _searchCtrl,
//                   focusNode: _searchFocus,
//                   onChanged: _onSearchChanged,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF111827)),
//                   decoration: const InputDecoration(
//                     hintText: 'Search a place or landmark…',
//                     hintStyle:
//                     TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
//                     border: InputBorder.none,
//                     isDense: true,
//                   ),
//                 ),
//               ),
//               if (_searchCtrl.text.isNotEmpty)
//                 GestureDetector(
//                   onTap: () {
//                     _searchCtrl.clear();
//                     setState(() {
//                       _searchResults = [];
//                       _searchResultOutside = false;
//                       _searchOutsideMsg = '';
//                     });
//                   },
//                   child: Container(
//                     width: 26,
//                     height: 26,
//                     margin: const EdgeInsets.only(right: 10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF1F5F9),
//                       borderRadius: BorderRadius.circular(7),
//                     ),
//                     child: const Icon(Icons.close_rounded,
//                         size: 13, color: Color(0xFF6B7280)),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         if (_isOutsideBoundary && !_searchResultOutside)
//           _buildOutsideWarning(),
//       ],
//     );
//   }
//
//   // ── Search dropdown ───────────────────────────────────────────────────────
//
//   Widget _buildSearchDropdown() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
//       constraints: const BoxConstraints(maxHeight: 200),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.07),
//               blurRadius: 16,
//               offset: const Offset(0, 4)),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           shrinkWrap: true,
//           itemCount: _searchResults.length,
//           separatorBuilder: (_, __) =>
//           const Divider(height: 1, color: Color(0xFFE5E7EB)),
//           itemBuilder: (_, i) {
//             final place = _searchResults[i];
//             final desc = place['description'] as String? ?? '';
//             final parts = desc.split(',');
//             final main = parts.first.trim();
//             final sub =
//             parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
//             return InkWell(
//               onTap: () => _selectPlace(place['place_id']),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 10),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: ColorConst.primaryGreen
//                             .withValues(alpha: 0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(Icons.location_on_rounded,
//                           size: 16, color: ColorConst.primaryGreen),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(main,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF111827))),
//                           if (sub.isNotEmpty)
//                             Text(sub,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     fontSize: 11,
//                                     color: Color(0xFF9CA3AF))),
//                         ],
//                       ),
//                     ),
//                     const Icon(Icons.north_west_rounded,
//                         size: 13, color: Color(0xFF9CA3AF)),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   // ── Map ───────────────────────────────────────────────────────────────────
//
//   Widget _buildMap() {
//     return Stack(
//       children: [
//         GoogleMap(
//           initialCameraPosition: CameraPosition(
//             target: _cityCenter,
//             zoom: _radiusToZoom(_cityRadiusKm),
//           ),
//           onMapCreated: (c) {
//             _mapController = c;
//             if (!_mapControllerCompleter.isCompleted) {
//               _mapControllerCompleter.complete(c);
//             }
//           },
//           onTap: _onMapTap,
//           circles: _circles,
//           markers: _markers,
//           zoomControlsEnabled: false,
//           myLocationButtonEnabled: false,
//           mapToolbarEnabled: false,
//         ),
//
//         // Legend
//         Positioned(
//           top: 12,
//           left: 12,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _HintChip(
//                 label: _isOutsideBoundary
//                     ? '⚠ Outside boundary'
//                     : 'Tap inside the blue circle',
//                 isWarning: _isOutsideBoundary,
//               ),
//               const SizedBox(height: 6),
//               _LegendChip(
//                   color: Colors.orange.shade400, label: 'Existing hub zones'),
//             ],
//           ),
//         ),
//
//         // Zoom controls
//         Positioned(
//           bottom: 16,
//           right: 12,
//           child: Column(
//             children: [
//               _MapBtn(
//                   icon: Icons.add_rounded,
//                   onTap: () =>
//                       _mapController?.animateCamera(CameraUpdate.zoomIn())),
//               const SizedBox(height: 6),
//               _MapBtn(
//                   icon: Icons.remove_rounded,
//                   onTap: () =>
//                       _mapController?.animateCamera(CameraUpdate.zoomOut())),
//               const SizedBox(height: 6),
//               _MapBtn(
//                   icon: Icons.my_location_rounded, onTap: _fitCityBoundary),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Bottom panel ──────────────────────────────────────────────────────────
//
//   Widget _buildBottomPanel() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(7),
//                   decoration: BoxDecoration(
//                     color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: const Icon(Icons.radar_rounded,
//                       size: 15, color: ColorConst.primaryGreen),
//                 ),
//                 const SizedBox(width: 8),
//                 const Text('Hub Coverage Radius',
//                     style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF111827))),
//                 const Spacer(),
//                 SizedBox(
//                   width: 78,
//                   height: 34,
//                   child: TextField(
//                     controller: _radiusCtrl,
//                     keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true),
//                     inputFormatters: [
//                       FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//                     ],
//                     onChanged: _onRadiusField,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: ColorConst.primaryGreen),
//                     decoration: InputDecoration(
//                       isDense: true,
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 8),
//                       suffixText: 'km',
//                       suffixStyle: const TextStyle(
//                           fontSize: 11,
//                           color: Color(0xFF9CA3AF),
//                           fontWeight: FontWeight.w500),
//                       filled: true,
//                       fillColor:
//                       ColorConst.primaryGreen.withValues(alpha: 0.07),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SliderTheme(
//             data: SliderThemeData(
//               activeTrackColor: ColorConst.primaryGreen,
//               inactiveTrackColor: const Color(0xFFE5E7EB),
//               thumbColor: ColorConst.primaryGreen,
//               overlayColor: ColorConst.primaryGreen.withValues(alpha: 0.1),
//               trackHeight: 3,
//               thumbShape:
//               const RoundSliderThumbShape(enabledThumbRadius: 7),
//             ),
//             child: Slider(
//               value: _hubRadius.clamp(0.5, _cityRadiusKm),
//               min: 0.5,
//               max: _cityRadiusKm,
//               divisions:
//               ((_cityRadiusKm - 0.5) * 2).round().clamp(1, 199),
//               onChanged: _onRadiusSlider,
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('0.5 km',
//                     style:
//                     TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
//                 Text('${_cityRadiusKm.toStringAsFixed(1)} km (max)',
//                     style: const TextStyle(
//                         fontSize: 10, color: Color(0xFF9CA3AF))),
//               ],
//             ),
//           ),
//
//           const Divider(height: 1, color: Color(0xFFE5E7EB)),
//
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: _addressLoading
//                 ? const Row(
//               children: [
//                 SizedBox(
//                   width: 13,
//                   height: 13,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: ColorConst.primaryGreen),
//                 ),
//                 SizedBox(width: 8),
//                 Text('Fetching address…',
//                     style: TextStyle(
//                         fontSize: 12, color: Color(0xFF9CA3AF))),
//               ],
//             )
//                 : _buildAddressRows(),
//           ),
//
//           const SizedBox(height: 12),
//           const Divider(height: 1, color: Color(0xFFE5E7EB)),
//
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF9FAFB),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFFE5E7EB)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('COORDINATES',
//                             style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w800,
//                                 color: Color(0xFF9CA3AF),
//                                 letterSpacing: 0.6)),
//                         const SizedBox(height: 3),
//                         Text(
//                           '${_selectedLocation.latitude.toStringAsFixed(5)}, '
//                               '${_selectedLocation.longitude.toStringAsFixed(5)}',
//                           style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF111827)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 SizedBox(
//                   height: 48,
//                   child: ElevatedButton.icon(
//                     onPressed: _isOutsideBoundary ? null : _confirm,
//                     icon: Icon(
//                       _isOutsideBoundary
//                           ? Icons.block_rounded
//                           : Icons.check_rounded,
//                       size: 18,
//                     ),
//                     label: Text(
//                       _isOutsideBoundary
//                           ? 'Outside Boundary'
//                           : 'Confirm Location',
//                       style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w700),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isOutsideBoundary
//                           ? Colors.red.shade400
//                           : ColorConst.primaryGreen,
//                       disabledBackgroundColor: Colors.red.shade400,
//                       foregroundColor: Colors.white,
//                       disabledForegroundColor: Colors.white,
//                       elevation: 0,
//                       padding:
//                       const EdgeInsets.symmetric(horizontal: 18),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddressRows() {
//     if (_street.isEmpty && _city.isEmpty && _state.isEmpty) {
//       return Container(
//         width: double.infinity,
//         padding:
//         const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF9FAFB),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFFE5E7EB)),
//         ),
//         child: const Row(
//           children: [
//             Icon(Icons.info_outline_rounded,
//                 size: 14, color: Color(0xFF9CA3AF)),
//             SizedBox(width: 8),
//             Text('Tap inside the blue circle to pick a location',
//                 style:
//                 TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
//           ],
//         ),
//       );
//     }
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             children: [
//               if (_street.isNotEmpty)
//                 _AddrTile(
//                     icon: Icons.signpost_rounded,
//                     color: ColorConst.primaryGreen,
//                     label: 'Street',
//                     value: _street),
//               if (_street.isNotEmpty) const SizedBox(height: 6),
//               if (_city.isNotEmpty)
//                 _AddrTile(
//                     icon: Icons.location_city_rounded,
//                     color: const Color(0xFF2563EB),
//                     label: 'City',
//                     value: _city),
//             ],
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             children: [
//               if (_state.isNotEmpty)
//                 _AddrTile(
//                     icon: Icons.map_outlined,
//                     color: const Color(0xFFD97706),
//                     label: 'State',
//                     value: _state),
//               if (_state.isNotEmpty && _pincode.isNotEmpty)
//                 const SizedBox(height: 6),
//               if (_pincode.isNotEmpty)
//                 _AddrTile(
//                     icon: Icons.pin_rounded,
//                     color: const Color(0xFFF472B6),
//                     label: 'Pincode',
//                     value: _pincode),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ── Small widgets ─────────────────────────────────────────────────────────────
//
// class _HintChip extends StatelessWidget {
//   final String label;
//   final bool isWarning;
//   const _HintChip({required this.label, this.isWarning = false});
//
//   @override
//   Widget build(BuildContext context) {
//     final color =
//     isWarning ? Colors.red.shade600 : ColorConst.primaryGreen;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.92),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//               isWarning
//                   ? Icons.warning_amber_rounded
//                   : Icons.touch_app_rounded,
//               size: 12,
//               color: color),
//           const SizedBox(width: 5),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   color: color)),
//         ],
//       ),
//     );
//   }
// }
//
// class _LegendChip extends StatelessWidget {
//   final Color color;
//   final String label;
//   const _LegendChip({required this.color, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.92),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//               width: 10,
//               height: 10,
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.3),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: color, width: 1.5),
//               )),
//           const SizedBox(width: 5),
//           Text(label,
//               style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF374151))),
//         ],
//       ),
//     );
//   }
// }
//
// class _MapBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _MapBtn({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.08),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2)),
//           ],
//         ),
//         child:
//         Icon(icon, size: 18, color: const Color(0xFF374151)),
//       ),
//     );
//   }
// }
//
// class _AddrTile extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final String value;
//   const _AddrTile({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.06),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withValues(alpha: 0.18)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 13, color: color),
//           const SizedBox(width: 7),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: 9,
//                         fontWeight: FontWeight.w700,
//                         color: color,
//                         letterSpacing: 0.5)),
//                 Text(value,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF111827))),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_zone_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';

class MapPickerPopup extends StatefulWidget {
  final Data? cityZone;
  const MapPickerPopup({super.key, this.cityZone});

  @override
  State<MapPickerPopup> createState() => _MapPickerPopupState();
}

class _MapPickerPopupState extends State<MapPickerPopup>
    with SingleTickerProviderStateMixin {
  // ── Map ──────────────────────────────────────────────────────────────────
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;

  // ── City boundary ────────────────────────────────────────────────────────
  late LatLng _cityCenter;
  late double _cityRadiusKm;

  // ── Selected pin ─────────────────────────────────────────────────────────
  late LatLng _selectedLocation;
  bool _isOutsideBoundary = false;

  // ── Hub radius ───────────────────────────────────────────────────────────
  double _hubRadius = 1.0;
  late TextEditingController _radiusCtrl;

  // ── Address ──────────────────────────────────────────────────────────────
  String _street = '';
  String _city = '';
  String _state = '';
  String _pincode = '';
  bool _addressLoading = false;

  // ── Search ───────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<dynamic> _searchResults = [];
  bool _searchLoading = false;
  Timer? _debounce;
  bool _searchResultOutside = false;
  String _searchOutsideMsg = '';

  // ── Animation ────────────────────────────────────────────────────────────
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

  // ── Web: track pointer for tap simulation ────────────────────────────────
  LatLng? _pendingWebTap;

  @override
  void initState() {
    super.initState();
    _cityCenter = widget.cityZone != null
        ? LatLng(
      double.parse(widget.cityZone!.lat.toString()),
      double.parse(widget.cityZone!.long.toString()),
    )
        : const LatLng(26.8467, 80.9462);

    _cityRadiusKm =
        double.tryParse(widget.cityZone?.radiuskm?.toString() ?? '') ?? 10.0;
    _selectedLocation = _cityCenter;
    _hubRadius = _hubRadius.clamp(0.5, _cityRadiusKm);
    _radiusCtrl = TextEditingController(text: _hubRadius.toStringAsFixed(1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HubZoneViewModel>(context, listen: false)
          .getHubZoneListDataApi(context);
      Provider.of<CityZoneListViewModel>(context, listen: false)
          .getCityZoneDataApi(context);
      _fetchAddress(_selectedLocation);
      Future.delayed(const Duration(milliseconds: 500), _fitCityBoundary);
    });

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
    _slideCtrl.forward();

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _searchResults = []);
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _radiusCtrl.dispose();
    _slideCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Camera ───────────────────────────────────────────────────────────────

  void _fitCityBoundary() {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _cityCenter, zoom: _radiusToZoom(_cityRadiusKm)),
    ));
  }

  void _fitHubCoverage() {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _selectedLocation, zoom: _radiusToZoom(_hubRadius)),
    ));
  }

  double _radiusToZoom(double radiusKm) {
    const double base = 14.0;
    final double delta = log(radiusKm / 0.5) / log(2);
    return (base - delta).clamp(3.0, 18.0);
  }

  // ── Geo helpers ──────────────────────────────────────────────────────────

  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final s = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(s), sqrt(1 - s));
  }

  double _deg2rad(double d) => d * pi / 180;

  bool _isInsideCity(LatLng p) => _distanceKm(p, _cityCenter) <= _cityRadiusKm;

  bool _isOverlapping() => _checkOverlapWith(_selectedLocation, _hubRadius);

  bool _checkOverlapWith(LatLng loc, double rad) {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
    for (final z in hubVM.hubZones) {
      final c = LatLng(double.parse(z.latitude.toString()),
          double.parse(z.longitude.toString()));
      final r = double.parse(z.radiuskm.toString());
      if (_distanceKm(loc, c) < (rad + r)) return true;
    }
    return false;
  }

  // ── Overlays ─────────────────────────────────────────────────────────────

  Set<Circle> get _circles {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
    return {
      Circle(
        circleId: const CircleId('city_boundary'),
        center: _cityCenter,
        radius: _cityRadiusKm * 1000,
        fillColor: const Color(0xFF2563EB).withValues(alpha: 0.06),
        strokeColor: _isOutsideBoundary
            ? Colors.red.withValues(alpha: 0.7)
            : const Color(0xFF2563EB).withValues(alpha: 0.5),
        strokeWidth: _isOutsideBoundary ? 3 : 2,
      ),
      Circle(
        circleId: const CircleId('hub_coverage'),
        center: _selectedLocation,
        radius: _hubRadius * 1000,
        fillColor: _isOutsideBoundary
            ? Colors.red.withValues(alpha: 0.10)
            : ColorConst.primaryGreen.withValues(alpha: 0.12),
        strokeColor: _isOutsideBoundary
            ? Colors.red.withValues(alpha: 0.6)
            : ColorConst.primaryGreen.withValues(alpha: 0.7),
        strokeWidth: 2,
      ),
      for (final z in hubVM.hubZones)
        Circle(
          circleId: CircleId('existing_${z.id}'),
          center: LatLng(double.parse(z.latitude.toString()),
              double.parse(z.longitude.toString())),
          radius: double.parse(z.radiuskm.toString()) * 1000,
          fillColor: Colors.orange.withValues(alpha: 0.10),
          strokeColor: Colors.orange.withValues(alpha: 0.6),
          strokeWidth: 2,
        ),
    };
  }

  Set<Marker> get _markers => {
    Marker(
      markerId: const MarkerId('city_center'),
      position: _cityCenter,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: widget.cityZone?.name?.toString() ?? 'City Zone',
        snippet: 'City boundary center',
      ),
      alpha: 0.7,
    ),
    Marker(
      markerId: const MarkerId('hub'),
      position: _selectedLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _isOutsideBoundary
            ? BitmapDescriptor.hueRed
            : BitmapDescriptor.hueGreen,
      ),
    ),
  };

  // ── Map tap (works on mobile + web) ──────────────────────────────────────

  Future<void> _onMapTap(LatLng latLng) async {
    if (_checkOverlapWith(latLng, _hubRadius)) {
      _showSnack('This location overlaps an existing hub zone!', isError: true);
      return;
    }
    setState(() {
      _selectedLocation = latLng;
      _isOutsideBoundary = !_isInsideCity(latLng);
      _searchResultOutside = false;
    });
    _fetchAddress(latLng);
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  // ── Address ───────────────────────────────────────────────────────────────

  Future<void> _fetchAddress(LatLng latLng) async {
    if (!mounted) return;
    setState(() {
      _addressLoading = true;
      _street = _city = _state = _pincode = '';
    });
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?latlng=${latLng.latitude},${latLng.longitude}'
            '&key=AIzaSyAW2lp2BYRmy8oD3ppvvegrql2MlMa-4tI',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List results = json['results'] ?? [];
        if (results.isEmpty) return;

        Map<String, dynamic>? best;
        for (final r in results) {
          final types = List<String>.from(r['types'] ?? []);
          if (types.contains('street_address') ||
              types.contains('premise') ||
              types.contains('subpremise')) {
            best = r;
            break;
          }
        }
        best ??= results.firstWhere(
              (r) => (r['types'] as List).contains('locality'),
          orElse: () => results.first,
        );

        if (best!['address_components'] != null) {
          _parseComponents(best['address_components']);
        }

        // Force pincode from ALL results
        for (final r in results) {
          for (final c in (r['address_components'] ?? [])) {
            if ((c['types'] as List).contains('postal_code')) {
              setState(() => _pincode = c['long_name'] ?? '');
              break;
            }
          }
          if (_pincode.isNotEmpty) break;
        }

        if (_street.isEmpty && _city.isEmpty && _state.isEmpty) {
          setState(() => _street = results.first['formatted_address'] ?? '');
        }
      }
    } catch (e) {
      debugPrint('_fetchAddress: $e');
    } finally {
      if (mounted) setState(() => _addressLoading = false);
    }
  }

  void _parseComponents(List<dynamic> components) {
    String streetNumber = '', route = '', sublocality = '', locality = '',
        adminArea = '', pincode = '';
    for (final c in components) {
      final types = List<String>.from(c['types'] ?? []);
      final long = c['long_name'] ?? '';
      if (types.contains('street_number')) streetNumber = long;
      if (types.contains('route')) route = long;
      if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        sublocality = long;
      }
      if (types.contains('locality')) locality = long;
      if (types.contains('administrative_area_level_1')) adminArea = long;
      if (types.contains('postal_code')) pincode = long;
    }
    setState(() {
      _street =
          [streetNumber, route].where((e) => e.isNotEmpty).join(' ');
      _city = [sublocality, locality].where((e) => e.isNotEmpty).join(', ');
      _state = adminArea;
      if (pincode.isNotEmpty) _pincode = pincode;
    });
  }

  String get _fullAddress => [
    if (_street.isNotEmpty) _street,
    if (_city.isNotEmpty) _city,
    if (_state.isNotEmpty) _state,
    if (_pincode.isNotEmpty) _pincode,
  ].join(', ');

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    setState(() {
      _searchResultOutside = false;
      _searchOutsideMsg = '';
    });
    if (q.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searchLoading = true);
    _debounce = Timer(
        const Duration(milliseconds: 450), () => _searchPlaces(q));
  }

  Future<void> _searchPlaces(String q) async {
    try {
      final res =
      await http.get(Uri.parse(ApiUrl.mapPlaceAutoCompleteUrl(q)));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _searchResults = data['data'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  Future<void> _selectPlace(String placeId) async {
    setState(() {
      _searchResults = [];
      _searchResultOutside = false;
      _searchOutsideMsg = '';
    });
    _searchCtrl.clear();
    _searchFocus.unfocus();
    try {
      final res =
      await http.get(Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId)));
      if (!mounted) return;
      final data = jsonDecode(res.body);
      final loc = data['data'];
      if (loc == null) {
        _showSnack('Could not fetch location details.', isError: true);
        return;
      }
      final latLng = LatLng(double.parse(loc['lat'].toString()),
          double.parse(loc['lng'].toString()));
      final outside = !_isInsideCity(latLng);
      if (outside) {
        setState(() {
          _searchResultOutside = true;
          _searchOutsideMsg =
          'This place is outside the city zone '
              '"${widget.cityZone?.name ?? 'boundary'}". '
              'Only locations inside the blue circle are allowed.';
          _selectedLocation = latLng;
          _isOutsideBoundary = true;
        });
      } else {
        if (_checkOverlapWith(latLng, _hubRadius)) {
          _showSnack('This location overlaps an existing hub zone!',
              isError: true);
          return;
        }
        setState(() {
          _selectedLocation = latLng;
          _isOutsideBoundary = false;
        });
      }
      await _fetchAddress(latLng);
      await _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 14.0)));
    } catch (e) {
      debugPrint('_selectPlace: $e');
      if (mounted) _showSnack('Failed to load place details.', isError: true);
    }
  }

  // ── Radius ────────────────────────────────────────────────────────────────

  void _onRadiusSlider(double val) {
    if (_checkOverlapWith(_selectedLocation, val)) {
      _showSnack('Radius will overlap an existing hub zone!', isError: true);
      return;
    }
    setState(() {
      _hubRadius = val;
      _radiusCtrl.text = val.toStringAsFixed(1);
    });
    _fitHubCoverage();
  }

  void _onRadiusField(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null && parsed >= 0.5 && parsed <= _cityRadiusKm) {
      if (_checkOverlapWith(_selectedLocation, parsed)) {
        _showSnack('This radius overlaps an existing hub zone!', isError: true);
        return;
      }
      setState(() => _hubRadius = parsed);
      _fitHubCoverage();
    }
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  void _confirm() {
    if (_isOutsideBoundary) return;
    if (_isOverlapping()) {
      _showSnack('Hub overlaps with an existing zone!', isError: true);
      return;
    }
    Navigator.pop(context, {
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _fullAddress,
      'pincode': _pincode,
      'radius': _hubRadius,
    });
    print({
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _fullAddress,
      'pincode': _pincode,
      'radius': _hubRadius,
    });
    print("dkkgjg");
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor:
        isError ? const Color(0xFFEF4444) : ColorConst.primaryGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb || size.width > 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? (size.width > 1100 ? (size.width - 1000) / 2 : 20) : 12,
        vertical: isWeb ? 24 : 16,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(_slideAnim),
        child: FadeTransition(
          opacity: _slideAnim,
          child: Container(
            width: isWeb ? 1000 : double.infinity,
            height: isWeb ? size.height * 0.88 : size.height * 0.92,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 48,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  _buildHeader(isWeb),
                  Expanded(
                    child: isWeb
                        ? _buildWebLayout()
                        : _buildMobileLayout(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isWeb) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, isWeb ? 18 : 14, 14, isWeb ? 18 : 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECF0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.map_rounded,
                size: 18, color: ColorConst.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Hub Location',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                Text(
                  'City Zone: ${widget.cityZone?.name ?? "—"}  •  '
                      'Radius: ${_cityRadiusKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          // Fit zone button
          _HeaderBtn(
            icon: Icons.fit_screen_rounded,
            label: 'Fit Zone',
            color: const Color(0xFF2563EB),
            onTap: _fitCityBoundary,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Web layout: map left, panel right ────────────────────────────────────

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Left: map (fills remaining space)
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              _buildGoogleMap(),
              // Search bar overlaid on map top-left
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    _buildSearchBar(),
                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildSearchDropdown(),
                    ],
                    if (_searchResultOutside) ...[
                      const SizedBox(height: 4),
                      _buildSearchOutsideWarning(),
                    ],
                    if (_isOutsideBoundary && !_searchResultOutside) ...[
                      const SizedBox(height: 4),
                      _buildOutsideWarning(),
                    ],
                  ],
                ),
              ),
              // Legend bottom-left
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HintChip(
                      label: _isOutsideBoundary
                          ? '⚠ Outside boundary'
                          : 'Click inside the blue circle',
                      isWarning: _isOutsideBoundary,
                    ),
                    const SizedBox(height: 6),
                    const _LegendChip(
                        color: Color(0xFFFB923C),
                        label: 'Existing hub zones'),
                  ],
                ),
              ),
              // Zoom controls bottom-right
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    _MapBtn(
                        icon: Icons.add_rounded,
                        onTap: () => _mapController
                            ?.animateCamera(CameraUpdate.zoomIn())),
                    const SizedBox(height: 6),
                    _MapBtn(
                        icon: Icons.remove_rounded,
                        onTap: () => _mapController
                            ?.animateCamera(CameraUpdate.zoomOut())),
                    const SizedBox(height: 6),
                    _MapBtn(
                        icon: Icons.my_location_rounded,
                        onTap: _fitCityBoundary),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Divider
        const VerticalDivider(width: 1, color: Color(0xFFE8ECF0)),

        // Right: panel
        SizedBox(
          width: 320,
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  // ── Mobile layout: stacked ────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              _buildSearchBar(),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildSearchDropdown(),
              ],
              if (_searchResultOutside) ...[
                const SizedBox(height: 4),
                _buildSearchOutsideWarning(),
              ],
              if (_isOutsideBoundary && !_searchResultOutside) ...[
                const SizedBox(height: 4),
                _buildOutsideWarning(),
              ],
            ],
          ),
        ),

        // Map
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildGoogleMap(),
                ),
              ),
              // Legend
              Positioned(
                top: 18,
                left: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HintChip(
                      label: _isOutsideBoundary
                          ? '⚠ Outside boundary'
                          : 'Tap inside the blue circle',
                      isWarning: _isOutsideBoundary,
                    ),
                    const SizedBox(height: 5),
                    const _LegendChip(
                        color: Color(0xFFFB923C),
                        label: 'Existing hub zones'),
                  ],
                ),
              ),
              // Zoom controls
              Positioned(
                bottom: 12,
                right: 18,
                child: Column(
                  children: [
                    _MapBtn(
                        icon: Icons.add_rounded,
                        onTap: () => _mapController
                            ?.animateCamera(CameraUpdate.zoomIn())),
                    const SizedBox(height: 6),
                    _MapBtn(
                        icon: Icons.remove_rounded,
                        onTap: () => _mapController
                            ?.animateCamera(CameraUpdate.zoomOut())),
                    const SizedBox(height: 6),
                    _MapBtn(
                        icon: Icons.my_location_rounded,
                        onTap: _fitCityBoundary),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom panel
        _buildMobileBottomPanel(),
      ],
    );
  }

  // ── Google Map widget (shared) ────────────────────────────────────────────
  // KEY FIX: gestureRecognizers for web, onLongPress fallback

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _cityCenter,
        zoom: _radiusToZoom(_cityRadiusKm),
      ),
      onMapCreated: (c) {
        _mapController = c;
        if (!_mapControllerCompleter.isCompleted) {
          _mapControllerCompleter.complete(c);
        }
      },
      onTap: _onMapTap,
      // Web fix: onLongPress as fallback when onTap doesn't fire
      onLongPress: _onMapTap,
      circles: _circles,
      markers: _markers,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      // Web fix: EagerGestureRecognizer captures pointer events on web
      gestureRecognizers: kIsWeb
          ? <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(
              () => EagerGestureRecognizer(),
        ),
      }
          : const {},
    );
  }

  // ── Right panel (web only) ────────────────────────────────────────────────

  Widget _buildRightPanel() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coordinates
            _buildCoordinatesCard(),
            const SizedBox(height: 20),

            // Address
            _buildPanelSection('Detected Address', Icons.location_on_rounded),
            const SizedBox(height: 10),
            _buildAddressContent(),
            const SizedBox(height: 20),

            // Radius
            _buildPanelSection(
                'Hub Coverage Radius', Icons.radar_rounded),
            const SizedBox(height: 10),
            _buildRadiusContent(),
            const SizedBox(height: 24),

            // Confirm
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  // ── Mobile bottom panel ───────────────────────────────────────────────────

  Widget _buildMobileBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Coordinates
          _buildCoordinatesCard(),
          const SizedBox(height: 12),

          // Address
          _buildAddressContent(),
          const SizedBox(height: 12),

          // Radius
          _buildRadiusContent(),
          const SizedBox(height: 14),

          // Confirm
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ── Shared sub-widgets ────────────────────────────────────────────────────

  Widget _buildPanelSection(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ColorConst.primaryGreen),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
                letterSpacing: 0.2)),
      ],
    );
  }

  Widget _buildCoordinatesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed_rounded,
              size: 14, color: ColorConst.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('COORDINATES',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(
                  '${_selectedLocation.latitude.toStringAsFixed(6)}, '
                      '${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressContent() {
    if (_addressLoading) {
      return Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: ColorConst.primaryGreen),
            ),
            SizedBox(width: 10),
            Text('Fetching address…',
                style:
                TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    if (_street.isEmpty && _city.isEmpty && _state.isEmpty) {
      return Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 14, color: Color(0xFF9CA3AF)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Tap/click inside the blue circle to pick a location',
                  style:
                  TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_street.isNotEmpty || _city.isNotEmpty)
          Row(
            children: [
              if (_street.isNotEmpty)
                Expanded(
                    child: _AddrTile(
                        icon: Icons.signpost_rounded,
                        color: ColorConst.primaryGreen,
                        label: 'Street',
                        value: _street)),
              if (_street.isNotEmpty && _city.isNotEmpty)
                const SizedBox(width: 8),
              if (_city.isNotEmpty)
                Expanded(
                    child: _AddrTile(
                        icon: Icons.location_city_rounded,
                        color: const Color(0xFF2563EB),
                        label: 'City',
                        value: _city)),
            ],
          ),
        if ((_street.isNotEmpty || _city.isNotEmpty) &&
            (_state.isNotEmpty || _pincode.isNotEmpty))
          const SizedBox(height: 8),
        if (_state.isNotEmpty || _pincode.isNotEmpty)
          Row(
            children: [
              if (_state.isNotEmpty)
                Expanded(
                    child: _AddrTile(
                        icon: Icons.map_outlined,
                        color: const Color(0xFFD97706),
                        label: 'State',
                        value: _state)),
              if (_state.isNotEmpty && _pincode.isNotEmpty)
                const SizedBox(width: 8),
              if (_pincode.isNotEmpty)
                Expanded(
                    child: _AddrTile(
                        icon: Icons.pin_rounded,
                        color: const Color(0xFFF472B6),
                        label: 'Pincode',
                        value: _pincode)),
            ],
          ),
      ],
    );
  }

  Widget _buildRadiusContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: ColorConst.primaryGreen,
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  thumbColor: ColorConst.primaryGreen,
                  overlayColor:
                  ColorConst.primaryGreen.withValues(alpha: 0.1),
                  trackHeight: 3,
                  thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: _hubRadius.clamp(0.5, _cityRadiusKm),
                  min: 0.5,
                  max: _cityRadiusKm,
                  divisions:
                  ((_cityRadiusKm - 0.5) * 2).round().clamp(1, 199),
                  onChanged: _onRadiusSlider,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 74,
              height: 36,
              child: TextField(
                controller: _radiusCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: _onRadiusField,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorConst.primaryGreen),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 9),
                  suffixText: 'km',
                  suffixStyle: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor:
                  ColorConst.primaryGreen.withValues(alpha: 0.07),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0.5 km',
                  style:
                  TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              Text('${_cityRadiusKm.toStringAsFixed(1)} km (max)',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isOutsideBoundary ? null : _confirm,
        icon: Icon(
          _isOutsideBoundary
              ? Icons.block_rounded
              : Icons.check_circle_outline_rounded,
          size: 18,
        ),
        label: Text(
          _isOutsideBoundary ? 'Outside Boundary' : 'Confirm Location',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isOutsideBoundary
              ? Colors.red.shade400
              : ColorConst.primaryGreen,
          disabledBackgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _searchLoading
                ? const SizedBox(
              key: ValueKey('load'),
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorConst.primaryGreen),
            )
                : const Icon(Icons.search_rounded,
                key: ValueKey('icon'),
                size: 18,
                color: ColorConst.primaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Search a place or landmark…',
                hintStyle:
                TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() {
                  _searchResults = [];
                  _searchResultOutside = false;
                  _searchOutsideMsg = '';
                });
              },
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 13, color: Color(0xFF6B7280)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          itemBuilder: (_, i) {
            final place = _searchResults[i];
            final desc = place['description'] as String? ?? '';
            final parts = desc.split(',');
            final main = parts.first.trim();
            final sub = parts.length > 1
                ? parts.sublist(1).join(',').trim()
                : '';
            return InkWell(
              onTap: () => _selectPlace(place['place_id']),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ColorConst.primaryGreen
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          size: 16, color: ColorConst.primaryGreen),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(main,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827))),
                          if (sub.isNotEmpty)
                            Text(sub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                    const Icon(Icons.north_west_rounded,
                        size: 13, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutsideWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 16, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Outside city boundary — move pin inside the blue circle.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                _selectedLocation = _cityCenter;
                _isOutsideBoundary = false;
                _searchResultOutside = false;
              });
              _mapController
                  ?.animateCamera(CameraUpdate.newLatLng(_cityCenter));
              await _fetchAddress(_cityCenter);
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Reset',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOutsideWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_off_rounded,
              size: 16, color: Colors.red.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location Outside City Zone',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade800)),
                const SizedBox(height: 2),
                Text(_searchOutsideMsg,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                        height: 1.4)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                _selectedLocation = _cityCenter;
                _isOutsideBoundary = false;
                _searchResultOutside = false;
                _searchOutsideMsg = '';
              });
              _mapController
                  ?.animateCamera(CameraUpdate.newLatLng(_cityCenter));
              await _fetchAddress(_cityCenter);
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Reset',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable small widgets ────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _HeaderBtn(
      {required this.icon,
        required this.label,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String label;
  final bool isWarning;
  const _HintChip({required this.label, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final color =
    isWarning ? Colors.red.shade600 : ColorConst.primaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.touch_app_rounded,
              size: 12,
              color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
        ],
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF374151)),
      ),
    );
  }
}

class _AddrTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _AddrTile(
      {required this.icon,
        required this.color,
        required this.label,
        required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5)),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}