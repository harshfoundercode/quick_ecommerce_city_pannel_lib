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
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';

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
//   // ── Map ──────────────────────────────────────────────────────────────────
//   final Completer<GoogleMapController> _mapControllerCompleter = Completer();
//   GoogleMapController? _mapController;
//
//   bool _isSelectingFromSearch = false;
//
//   // ── City boundary ────────────────────────────────────────────────────────
//   late LatLng _cityCenter;
//   late double _cityRadiusKm;
//
//   // ── Selected pin ─────────────────────────────────────────────────────────
//   late LatLng _selectedLocation;
//   bool _isOutsideBoundary = false;
//
//   // ── Hub radius ───────────────────────────────────────────────────────────
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
//   bool _searchResultOutside = false;
//   String _searchOutsideMsg = '';
//
//   // ── Animation ────────────────────────────────────────────────────────────
//   late AnimationController _slideCtrl;
//   late Animation<double> _slideAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _cityCenter = widget.cityZone != null
//         ? LatLng(
//             double.parse(widget.cityZone!.lat.toString()),
//             double.parse(widget.cityZone!.long.toString()),
//           )
//         : const LatLng(26.8467, 80.9462);
//
//     _cityRadiusKm =
//         double.tryParse(widget.cityZone?.radiuskm?.toString() ?? '') ?? 10.0;
//     _selectedLocation = _cityCenter;
//     _hubRadius = _hubRadius.clamp(0.5, _cityRadiusKm);
//     _radiusCtrl = TextEditingController(text: _hubRadius.toStringAsFixed(1));
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
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
//   // ── Camera ───────────────────────────────────────────────────────────────
//
//   void _fitCityBoundary() {
//     _mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: _cityCenter, zoom: _radiusToZoom(_cityRadiusKm)),
//       ),
//     );
//   }
//
//   void _fitHubCoverage() {
//     _mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: _selectedLocation,
//           zoom: _radiusToZoom(_hubRadius),
//         ),
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
//   // ── Geo helpers ──────────────────────────────────────────────────────────
//
//   double _distanceKm(LatLng a, LatLng b) {
//     const r = 6371.0;
//     final dLat = _deg2rad(b.latitude - a.latitude);
//     final dLon = _deg2rad(b.longitude - a.longitude);
//     final s =
//         sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(a.latitude)) *
//             cos(_deg2rad(b.latitude)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);
//     return r * 2 * atan2(sqrt(s), sqrt(1 - s));
//   }
//
//   double _deg2rad(double d) => d * pi / 180;
//
//   bool _isInsideCity(LatLng p) => _distanceKm(p, _cityCenter) <= _cityRadiusKm;
//
//   bool _isOverlapping() => _checkOverlapWith(_selectedLocation, _hubRadius);
//
//   bool _checkOverlapWith(LatLng loc, double rad) {
//     final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
//     for (final z in hubVM.hubZones) {
//       final c = LatLng(
//         double.parse(z.latitude.toString()),
//         double.parse(z.longitude.toString()),
//       );
//       final r = double.parse(z.radiuskm.toString());
//       if (_distanceKm(loc, c) < (rad + r)) return true;
//     }
//     return false;
//   }
//
//   // ── Overlays ─────────────────────────────────────────────────────────────
//
//   Set<Circle> get _circles {
//     final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
//     return {
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
//       for (final z in hubVM.hubZones)
//         Circle(
//           circleId: CircleId('existing_${z.id}'),
//           center: LatLng(
//             double.parse(z.latitude.toString()),
//             double.parse(z.longitude.toString()),
//           ),
//           radius: double.parse(z.radiuskm.toString()) * 1000,
//           fillColor: Colors.orange.withValues(alpha: 0.10),
//           strokeColor: Colors.orange.withValues(alpha: 0.6),
//           strokeWidth: 2,
//         ),
//     };
//   }
//
//   LatLng _clampToCity(LatLng point) {
//     final dist = _distanceKm(point, _cityCenter);
//
//     if (dist <= _cityRadiusKm) return point;
//
//     final ratio = _cityRadiusKm / dist;
//
//     final lat =
//         _cityCenter.latitude + (point.latitude - _cityCenter.latitude) * ratio;
//
//     final lng =
//         _cityCenter.longitude +
//         (point.longitude - _cityCenter.longitude) * ratio;
//
//     return LatLng(lat, lng);
//   }
//
//   Set<Marker> get _markers => {
//     Marker(
//       markerId: const MarkerId('city_center'),
//       position: _cityCenter,
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       infoWindow: InfoWindow(
//         title: widget.cityZone?.name?.toString() ?? 'City Zone',
//         snippet: 'City boundary center',
//       ),
//       alpha: 0.7,
//     ),
//     Marker(
//       markerId: const MarkerId('hub'),
//       position: _selectedLocation,
//       draggable: true, // ✅ enable drag
//       icon: BitmapDescriptor.defaultMarkerWithHue(
//         _isOutsideBoundary
//             ? BitmapDescriptor.hueRed
//             : BitmapDescriptor.hueGreen,
//       ),
//       onDragStart: (pos) {
//         // optional
//         debugPrint("Dragging started");
//       },
//       onDrag: (pos) {
//         if (_isInsideCity(pos)) {
//           setState(() {
//             _selectedLocation = pos;
//           });
//         }
//       },
//       onDragEnd: (pos) async {
//         // 🔥 MAIN LOGIC
//
//         if (!_isInsideCity(pos)) {
//           CustomSnackBar.show(
//             context,
//             message: '❌ You can only drag inside blue zone',
//             type: SnackBarType.error,
//           );
//
//           // 🔥 snap back inside boundary
//           pos = _clampToCity(pos);
//         }
//
//         if (_checkOverlapWith(pos, _hubRadius)) {
//           CustomSnackBar.show(
//             context,
//             message: '❌ Overlapping another hub zone',
//             type: SnackBarType.error,
//           );
//           return;
//         }
//
//         setState(() {
//           _selectedLocation = pos;
//           _isOutsideBoundary = !_isInsideCity(pos);
//         });
//
//         await _fetchAddress(pos);
//
//         _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
//       },
//     ),
//   };
//
//   // ── Map tap (works on mobile + web) ──────────────────────────────────────
//
//   Future<void> _onMapTap(LatLng latLng) async {
//     if (_isSelectingFromSearch) return; // ✅ prevent unwanted tap
//
//     if (_checkOverlapWith(latLng, _hubRadius)) {
//       CustomSnackBar.show(
//         context,
//         message: 'This location overlaps an existing hub zone!',
//         type: SnackBarType.error,
//       );
//       return;
//     }
//     if (!_isInsideCity(latLng)) {
//       CustomSnackBar.show(
//         context,
//         message: 'Outside zone! Auto adjusting...',
//         type: SnackBarType.error,
//       );
//
//       // 🔥 Move to nearest valid point (simple fallback)
//       latLng = _cityCenter;
//     }
//
//     setState(() {
//       _selectedLocation = latLng;
//       _isOutsideBoundary = !_isInsideCity(latLng);
//       _searchResultOutside = false;
//     });
//     _fetchAddress(latLng);
//     _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
//   }
//
//   // ── Address ───────────────────────────────────────────────────────────────
//
//   Future<void> _fetchAddress(LatLng latLng) async {
//     if (!mounted) return;
//     setState(() {
//       _addressLoading = true;
//       _street = _city = _state = _pincode = '';
//     });
//     try {
//       final uri = Uri.parse(
//         'https://maps.googleapis.com/maps/api/geocode/json'
//         '?latlng=${latLng.latitude},${latLng.longitude}&components=country:IN&result_type=street_address|premise|subpremise|route|locality|postal_code&key=AIzaSyAW2lp2BYRmy8oD3ppvvegrql2MlMa-4tI',
//       );
//       final res = await http.get(uri).timeout(const Duration(seconds: 10));
//       if (!mounted) return;
//       if (res.statusCode == 200) {
//         final json = jsonDecode(res.body);
//         final List results = json['results'] ?? [];
//         if (results.isEmpty) return;
//
//         Map<String, dynamic>? best;
//         for (final r in results) {
//           final types = List<String>.from(r['types'] ?? []);
//           if (types.contains('street_address') ||
//               types.contains('premise') ||
//               types.contains('subpremise')) {
//             best = r;
//             break;
//           }
//         }
//         best ??= results.firstWhere(
//           (r) => (r['types'] as List).contains('locality'),
//           orElse: () => results.first,
//         );
//
//         if (best!['address_components'] != null) {
//           _parseComponents(best['address_components']);
//         }
//
//         // Force pincode from ALL results
//         for (final r in results) {
//           for (final c in (r['address_components'] ?? [])) {
//             if ((c['types'] as List).contains('postal_code')) {
//               setState(() => _pincode = c['long_name'] ?? '');
//               break;
//             }
//           }
//           if (_pincode.isNotEmpty) break;
//         }
//
//         if (_street.isEmpty && _city.isEmpty && _state.isEmpty) {
//           setState(() => _street = results.first['formatted_address'] ?? '');
//         }
//       }
//     } catch (e) {
//       debugPrint('_fetchAddress: $e');
//     } finally {
//       if (mounted) setState(() => _addressLoading = false);
//     }
//   }
//
//   void _parseComponents(List<dynamic> components) {
//     String streetNumber = '',
//         route = '',
//         sublocality = '',
//         locality = '',
//         adminArea = '',
//         pincode = '';
//     for (final c in components) {
//       final types = List<String>.from(c['types'] ?? []);
//       final long = c['long_name'] ?? '';
//       if (types.contains('street_number')) streetNumber = long;
//       if (types.contains('route')) route = long;
//       if (types.contains('sublocality') ||
//           types.contains('sublocality_level_1')) {
//         sublocality = long;
//       }
//       if (types.contains('locality')) locality = long;
//       if (types.contains('administrative_area_level_1')) adminArea = long;
//       if (types.contains('postal_code')) pincode = long;
//     }
//     setState(() {
//       _street = [streetNumber, route].where((e) => e.isNotEmpty).join(' ');
//       _city = [sublocality, locality].where((e) => e.isNotEmpty).join(', ');
//       _state = adminArea;
//       if (pincode.isNotEmpty) _pincode = pincode;
//     });
//   }
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
//       () => _searchPlaces(q),
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
//   Future<void> _selectPlace(String placeId) async {
//     print("dwgeyfd");
//     _isSelectingFromSearch = true;
//     setState(() {
//       _searchResults = [];
//       _searchResultOutside = false;
//       _searchOutsideMsg = '';
//     });
//     _searchCtrl.clear();
//     _searchFocus.unfocus();
//     try {
//       final res = await http.get(Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId)));
//       if (!mounted) return;
//       final data = jsonDecode(res.body);
//       final loc = data['data'];
//       print(loc);
//       print("loc");
//       print(ApiUrl.mapPlaceDetailsUrl(placeId));
//       print("ApiUrl.mapPlaceDetailsUrl(placeId)");
//       if (loc == null) {
//         CustomSnackBar.show(
//           context,
//           message: 'Could not fetch location details.',
//           type: SnackBarType.error,
//         );
//         return;
//       }
//       final latLng = LatLng(
//         double.parse(loc['lat'].toString()),
//         double.parse(loc['lng'].toString()),
//       );
//       print("Selected place lat: ${latLng.latitude}");
//       print("Selected place lng: ${latLng.longitude}");
//       print("Distance from center: ${_distanceKm(latLng, _cityCenter)} km");
//       final outside = !_isInsideCity(latLng);
//       if (outside) {
//         setState(() {
//           _searchResultOutside = true;
//           _searchOutsideMsg =
//               'This place is outside the city zone '
//               '"${widget.cityZone?.name ?? 'boundary'}". '
//               'Only locations inside the blue circle are allowed.';
//           _selectedLocation = latLng;
//           _isOutsideBoundary = true;
//         });
//       } else {
//         if (_checkOverlapWith(latLng, _hubRadius)) {
//           CustomSnackBar.show(
//             context,
//             message: 'This location overlaps an existing hub zone!',
//             type: SnackBarType.error,
//           );
//           return;
//         }
//         setState(() {
//           _selectedLocation = latLng;
//           _isOutsideBoundary = false;
//         });
//       }
//       await _fetchAddress(latLng);
//       await _mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: latLng, zoom: 14.0),
//         ),
//       );
//     } catch (e) {
//       debugPrint('_selectPlace: $e');
//       if (mounted)
//         CustomSnackBar.show(
//           context,
//           message: 'Failed to load place details.',
//           type: SnackBarType.error,
//         );
//     } finally {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         _isSelectingFromSearch = false; // ✅ unlock after animation
//       });
//     }
//   }
//
//   // ── Radius ────────────────────────────────────────────────────────────────
//
//   void _onRadiusSlider(double val) {
//     if (_checkOverlapWith(_selectedLocation, val)) {
//       CustomSnackBar.show(
//         context,
//         message: 'Radius will overlap an existing hub zone!',
//         type: SnackBarType.error,
//       );
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
//       if (_checkOverlapWith(_selectedLocation, parsed)) {
//         CustomSnackBar.show(
//           context,
//           message: 'This radius overlaps an existing hub zone!',
//           type: SnackBarType.error,
//         );
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
//       CustomSnackBar.show(
//         context,
//         message: 'Hub overlaps with an existing zone!',
//         type: SnackBarType.error,
//       );
//       return;
//     }
//     Navigator.pop(context, {
//       'lat': _selectedLocation.latitude,
//       'lng': _selectedLocation.longitude,
//       'address': _fullAddress,
//       'pincode': _pincode,
//       'radius': _hubRadius,
//     });
//     if (kDebugMode) {
//       print({
//         'lat': _selectedLocation.latitude,
//         'lng': _selectedLocation.longitude,
//         'address': _fullAddress,
//         'pincode': _pincode,
//         'radius': _hubRadius,
//       });
//     }
//     if (kDebugMode) {
//       print("dkkgjg");
//     }
//   }
//
//
//   // ── Build ─────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isWeb = kIsWeb || size.width > 700;
//
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: isWeb
//             ? (size.width > 1100 ? (size.width - 1000) / 2 : 20)
//             : 12,
//         vertical: isWeb ? 24 : 16,
//       ),
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, 0.06),
//           end: Offset.zero,
//         ).animate(_slideAnim),
//         child: FadeTransition(
//           opacity: _slideAnim,
//           child: Container(
//             width: isWeb ? 1000 : double.infinity,
//             height: isWeb ? size.height * 0.88 : size.height * 0.92,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F9FB),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.16),
//                   blurRadius: 48,
//                   offset: const Offset(0, 16),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Column(
//                 children: [
//                   _buildHeader(isWeb),
//                   Expanded(
//                     child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
//                   ),
//                 ],
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
//   Widget _buildHeader(bool isWeb) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(20, isWeb ? 18 : 14, 14, isWeb ? 18 : 14),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(bottom: BorderSide(color: Color(0xFFE8ECF0))),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(9),
//             decoration: BoxDecoration(
//               color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(
//               Icons.map_rounded,
//               size: 18,
//               color: ColorConst.primaryGreen,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Select Hub Location',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF111827),
//                   ),
//                 ),
//                 Text(
//                   'City Zone: ${widget.cityZone?.name ?? "—"}  •  '
//                   'Radius: ${_cityRadiusKm.toStringAsFixed(1)} km',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Fit zone button
//           _HeaderBtn(
//             icon: Icons.fit_screen_rounded,
//             label: 'Fit Zone',
//             color: const Color(0xFF2563EB),
//             onTap: _fitCityBoundary,
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F5F9),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 size: 18,
//                 color: Color(0xFF374151),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Web layout: map left, panel right ────────────────────────────────────
//
//   Widget _buildWebLayout() {
//     return Row(
//       children: [
//         // Left: map (fills remaining space)
//         Expanded(
//           flex: 6,
//           child: Stack(
//             children: [
//               _buildGoogleMap(),
//               // Search bar overlaid on map top-left
//               Positioned(
//                 top: 16,
//                 left: 16,
//                 right: 16,
//                 child: Column(
//                   children: [
//                     _buildSearchBar(),
//                     if (_searchResults.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       _buildSearchDropdown(),
//                     ],
//                     if (_searchResultOutside) ...[
//                       const SizedBox(height: 4),
//                       _buildSearchOutsideWarning(),
//                     ],
//                     if (_isOutsideBoundary && !_searchResultOutside) ...[
//                       const SizedBox(height: 4),
//                       _buildOutsideWarning(),
//                     ],
//                   ],
//                 ),
//               ),
//               // Legend bottom-left
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _HintChip(
//                       label: _isOutsideBoundary
//                           ? '⚠ Outside boundary'
//                           : 'Click inside the blue circle',
//                       isWarning: _isOutsideBoundary,
//                     ),
//                     const SizedBox(height: 6),
//                     const _LegendChip(
//                       color: Color(0xFFFB923C),
//                       label: 'Existing hub zones',
//                     ),
//                   ],
//                 ),
//               ),
//               // Zoom controls bottom-right
//               Positioned(
//                 bottom: 16,
//                 right: 16,
//                 child: Column(
//                   children: [
//                     _MapBtn(
//                       icon: Icons.add_rounded,
//                       onTap: () =>
//                           _mapController?.animateCamera(CameraUpdate.zoomIn()),
//                     ),
//                     const SizedBox(height: 6),
//                     _MapBtn(
//                       icon: Icons.remove_rounded,
//                       onTap: () =>
//                           _mapController?.animateCamera(CameraUpdate.zoomOut()),
//                     ),
//                     const SizedBox(height: 6),
//                     _MapBtn(
//                       icon: Icons.my_location_rounded,
//                       onTap: _fitCityBoundary,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Divider
//         const VerticalDivider(width: 1, color: Color(0xFFE8ECF0)),
//
//         // Right: panel
//         SizedBox(width: 320, child: _buildRightPanel()),
//       ],
//     );
//   }
//
//   // ── Mobile layout: stacked ────────────────────────────────────────────────
//
//   Widget _buildMobileLayout() {
//     return SingleChildScrollView(
//       child: Container(
//         height: Sizes.screenHeight,
//         width: Sizes.screenWidth,
//         child: Column(
//           children: [
//             // Search
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
//               child: Column(
//                 children: [
//                   _buildSearchBar(),
//                   if (_searchResults.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     _buildSearchDropdown(),
//                   ],
//                   if (_searchResultOutside) ...[
//                     const SizedBox(height: 4),
//                     _buildSearchOutsideWarning(),
//                   ],
//                   if (_isOutsideBoundary && !_searchResultOutside) ...[
//                     const SizedBox(height: 4),
//                     _buildOutsideWarning(),
//                   ],
//                 ],
//               ),
//             ),
//
//             // Map
//             Expanded(
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: _buildGoogleMap(),
//                     ),
//                   ),
//                   // Legend
//                   Positioned(
//                     top: 18,
//                     left: 18,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _HintChip(
//                           label: _isOutsideBoundary
//                               ? '⚠ Outside boundary'
//                               : 'Tap inside the blue circle',
//                           isWarning: _isOutsideBoundary,
//                         ),
//                         const SizedBox(height: 5),
//                         const _LegendChip(
//                           color: Color(0xFFFB923C),
//                           label: 'Existing hub zones',
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Zoom controls
//                   Positioned(
//                     bottom: 12,
//                     right: 18,
//                     child: Column(
//                       children: [
//                         _MapBtn(
//                           icon: Icons.add_rounded,
//                           onTap: () =>
//                               _mapController?.animateCamera(CameraUpdate.zoomIn()),
//                         ),
//                         const SizedBox(height: 6),
//                         _MapBtn(
//                           icon: Icons.remove_rounded,
//                           onTap: () =>
//                               _mapController?.animateCamera(CameraUpdate.zoomOut()),
//                         ),
//                         const SizedBox(height: 6),
//                         _MapBtn(
//                           icon: Icons.my_location_rounded,
//                           onTap: _fitCityBoundary,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Bottom panel
//             _buildMobileBottomPanel(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Google Map widget (shared) ────────────────────────────────────────────
//   // KEY FIX: gestureRecognizers for web, onLongPress fallback
//
//   Widget _buildGoogleMap() {
//     final isDropdownOpen = _searchResults.isNotEmpty;
//     return GoogleMap(
//       initialCameraPosition: CameraPosition(
//         target: _cityCenter,
//         zoom: _radiusToZoom(_cityRadiusKm),
//       ),
//       onMapCreated: (c) {
//         _mapController = c;
//         if (!_mapControllerCompleter.isCompleted) {
//           _mapControllerCompleter.complete(c);
//         }
//       },
//       onTap: _isSelectingFromSearch ? null : _onMapTap, // Disable onTap during search
//       // Web fix: onLongPress as fallback when onTap doesn't fire
//       onLongPress: _isSelectingFromSearch ? null : _onMapTap,
//       circles: _circles,
//       markers: _markers,
//       zoomControlsEnabled: false,
//       myLocationButtonEnabled: false,
//       mapToolbarEnabled: false,
//       // Web fix: EagerGestureRecognizer captures pointer events on web
//       // ✅ PLATFORM-SAFE FIX
//       // CRITICAL FIX: Disable ALL map gestures when dropdown is open OR selecting
//       gestureRecognizers: (isDropdownOpen || _isSelectingFromSearch)
//           ? <Factory<OneSequenceGestureRecognizer>>{} // Completely disable map gestures
//           : (kIsWeb
//           ? {
//         Factory<EagerGestureRecognizer>(
//               () => EagerGestureRecognizer(),
//         ),
//       }
//           : {}),
//     );
//   }
//
//   // ── Right panel (web only) ────────────────────────────────────────────────
//
//   Widget _buildRightPanel() {
//     return Container(
//       color: Colors.white,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Coordinates
//             _buildCoordinatesCard(),
//             const SizedBox(height: 20),
//
//             // Address
//             _buildPanelSection('Detected Address', Icons.location_on_rounded),
//             const SizedBox(height: 10),
//             _buildAddressContent(),
//             const SizedBox(height: 20),
//
//             // Radius
//             _buildPanelSection('Hub Coverage Radius', Icons.radar_rounded),
//             const SizedBox(height: 10),
//             _buildRadiusContent(),
//             const SizedBox(height: 24),
//
//             // Confirm
//             _buildConfirmButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Mobile bottom panel ───────────────────────────────────────────────────
//
//   Widget _buildMobileBottomPanel() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle
//           Center(
//             child: Container(
//               width: 36,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE5E7EB),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//
//           // Coordinates
//           _buildCoordinatesCard(),
//           const SizedBox(height: 12),
//
//           // Address
//           _buildAddressContent(),
//           const SizedBox(height: 12),
//
//           // Radius
//           _buildRadiusContent(),
//           const SizedBox(height: 14),
//
//           // Confirm
//           _buildConfirmButton(),
//         ],
//       ),
//     );
//   }
//
//   // ── Shared sub-widgets ────────────────────────────────────────────────────
//
//   Widget _buildPanelSection(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: ColorConst.primaryGreen),
//         const SizedBox(width: 6),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF374151),
//             letterSpacing: 0.2,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCoordinatesCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0FDF4),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFBBF7D0)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.gps_fixed_rounded,
//             size: 14,
//             color: ColorConst.primaryGreen,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'COORDINATES',
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF6B7280),
//                     letterSpacing: 0.8,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${_selectedLocation.latitude.toStringAsFixed(6)}, '
//                   '${_selectedLocation.longitude.toStringAsFixed(6)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF111827),
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
//   Widget _buildAddressContent() {
//     if (_addressLoading) {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF9FAFB),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFFE5E7EB)),
//         ),
//         child: const Row(
//           children: [
//             SizedBox(
//               width: 13,
//               height: 13,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: ColorConst.primaryGreen,
//               ),
//             ),
//             SizedBox(width: 10),
//             Text(
//               'Fetching address…',
//               style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_street.isEmpty && _city.isEmpty && _state.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF9FAFB),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFFE5E7EB)),
//         ),
//         child: const Row(
//           children: [
//             Icon(
//               Icons.info_outline_rounded,
//               size: 14,
//               color: Color(0xFF9CA3AF),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Tap/click inside the blue circle to pick a location',
//                 style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return Column(
//       children: [
//         if (_street.isNotEmpty || _city.isNotEmpty)
//           Row(
//             children: [
//               if (_street.isNotEmpty)
//                 Expanded(
//                   child: _AddrTile(
//                     icon: Icons.signpost_rounded,
//                     color: ColorConst.primaryGreen,
//                     label: 'Street',
//                     value: _street,
//                   ),
//                 ),
//               if (_street.isNotEmpty && _city.isNotEmpty)
//                 const SizedBox(width: 8),
//               if (_city.isNotEmpty)
//                 Expanded(
//                   child: _AddrTile(
//                     icon: Icons.location_city_rounded,
//                     color: const Color(0xFF2563EB),
//                     label: 'City',
//                     value: _city,
//                   ),
//                 ),
//             ],
//           ),
//         if ((_street.isNotEmpty || _city.isNotEmpty) &&
//             (_state.isNotEmpty || _pincode.isNotEmpty))
//           const SizedBox(height: 8),
//         if (_state.isNotEmpty || _pincode.isNotEmpty)
//           Row(
//             children: [
//               if (_state.isNotEmpty)
//                 Expanded(
//                   child: _AddrTile(
//                     icon: Icons.map_outlined,
//                     color: const Color(0xFFD97706),
//                     label: 'State',
//                     value: _state,
//                   ),
//                 ),
//               if (_state.isNotEmpty && _pincode.isNotEmpty)
//                 const SizedBox(width: 8),
//               if (_pincode.isNotEmpty)
//                 Expanded(
//                   child: _AddrTile(
//                     icon: Icons.pin_rounded,
//                     color: const Color(0xFFF472B6),
//                     label: 'Pincode',
//                     value: _pincode,
//                   ),
//                 ),
//             ],
//           ),
//       ],
//     );
//   }
//
//   Widget _buildRadiusContent() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: SliderTheme(
//                 data: SliderThemeData(
//                   activeTrackColor: ColorConst.primaryGreen,
//                   inactiveTrackColor: const Color(0xFFE5E7EB),
//                   thumbColor: ColorConst.primaryGreen,
//                   overlayColor: ColorConst.primaryGreen.withValues(alpha: 0.1),
//                   trackHeight: 3,
//                   thumbShape: const RoundSliderThumbShape(
//                     enabledThumbRadius: 7,
//                   ),
//                 ),
//                 child: Slider(
//                   value: _hubRadius.clamp(0.5, _cityRadiusKm),
//                   min: 0.5,
//                   max: _cityRadiusKm,
//                   divisions: ((_cityRadiusKm - 0.5) * 2).round().clamp(1, 199),
//                   onChanged: _onRadiusSlider,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             SizedBox(
//               width: 74,
//               height: 36,
//               child: TextField(
//                 controller: _radiusCtrl,
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//                 ],
//                 onChanged: _onRadiusField,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: ColorConst.primaryGreen,
//                 ),
//                 decoration: InputDecoration(
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 9,
//                   ),
//                   suffixText: 'km',
//                   suffixStyle: const TextStyle(
//                     fontSize: 10,
//                     color: Color(0xFF9CA3AF),
//                     fontWeight: FontWeight.w500,
//                   ),
//                   filled: true,
//                   fillColor: ColorConst.primaryGreen.withValues(alpha: 0.07),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 '0.5 km',
//                 style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
//               ),
//               Text(
//                 '${_cityRadiusKm.toStringAsFixed(1)} km (max)',
//                 style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildConfirmButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 48,
//       child: ElevatedButton.icon(
//         onPressed: _isOutsideBoundary ? null : _confirm,
//         icon: Icon(
//           _isOutsideBoundary
//               ? Icons.block_rounded
//               : Icons.check_circle_outline_rounded,
//           size: 18,
//         ),
//         label: Text(
//           _isOutsideBoundary ? 'Outside Boundary' : 'Confirm Location',
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _isOutsideBoundary
//               ? Colors.red.shade400
//               : ColorConst.primaryGreen,
//           disabledBackgroundColor: Colors.red.shade400,
//           foregroundColor: Colors.white,
//           disabledForegroundColor: Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Search bar ────────────────────────────────────────────────────────────
//
//   Widget _buildSearchBar() {
//     return Container(
//       height: 46,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 12),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: _searchLoading
//                 ? const SizedBox(
//                     key: ValueKey('load'),
//                     width: 15,
//                     height: 15,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: ColorConst.primaryGreen,
//                     ),
//                   )
//                 : const Icon(
//                     Icons.search_rounded,
//                     key: ValueKey('icon'),
//                     size: 18,
//                     color: ColorConst.primaryGreen,
//                   ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: _searchCtrl,
//               focusNode: _searchFocus,
//               onChanged: _onSearchChanged,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF111827),
//               ),
//               decoration: const InputDecoration(
//                 hintText: 'Search a place or landmark…',
//                 hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
//                 border: InputBorder.none,
//                 isDense: true,
//               ),
//             ),
//           ),
//           if (_searchCtrl.text.isNotEmpty)
//             GestureDetector(
//               onTap: () {
//                 _searchCtrl.clear();
//                 setState(() {
//                   _searchResults = [];
//                   _searchResultOutside = false;
//                   _searchOutsideMsg = '';
//                 });
//               },
//               child: Container(
//                 width: 26,
//                 height: 26,
//                 margin: const EdgeInsets.only(right: 10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF1F5F9),
//                   borderRadius: BorderRadius.circular(7),
//                 ),
//                 child: const Icon(
//                   Icons.close_rounded,
//                   size: 13,
//                   color: Color(0xFF6B7280),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchDropdown() {
//     return Container(
//       constraints: const BoxConstraints(maxHeight: 200),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           shrinkWrap: true,
//           itemCount: _searchResults.length,
//           separatorBuilder: (_, __) =>
//               const Divider(height: 1, color: Color(0xFFE5E7EB)),
//           itemBuilder: (_, i) {
//             final place = _searchResults[i];
//             final desc = place['description'] as String? ?? '';
//             final parts = desc.split(',');
//             final main = parts.first.trim();
//             final sub = parts.length > 1
//                 ? parts.sublist(1).join(',').trim()
//                 : '';
//             return GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () {
//                 print("✅ TAP WORKING (WEB + MOBILE)");
//                 _selectPlace(place['place_id']);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 10,
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: ColorConst.primaryGreen.withValues(alpha: 0.08),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.location_on_rounded,
//                         size: 16,
//                         color: ColorConst.primaryGreen,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             main,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF111827),
//                             ),
//                           ),
//                           if (sub.isNotEmpty)
//                             Text(
//                               sub,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: Color(0xFF9CA3AF),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const Icon(
//                       Icons.north_west_rounded,
//                       size: 13,
//                       color: Color(0xFF9CA3AF),
//                     ),
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
//
//   Widget _buildOutsideWarning() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.warning_amber_rounded,
//             size: 16,
//             color: Colors.red.shade600,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'Outside city boundary — move pin inside the blue circle.',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.red.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               setState(() {
//                 _selectedLocation = _cityCenter;
//                 _isOutsideBoundary = false;
//                 _searchResultOutside = false;
//               });
//               _mapController?.animateCamera(
//                 CameraUpdate.newLatLng(_cityCenter),
//               );
//               await _fetchAddress(_cityCenter);
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 'Reset',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.red.shade700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchOutsideWarning() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.location_off_rounded,
//             size: 16,
//             color: Colors.red.shade600,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Location Outside City Zone',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.red.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _searchOutsideMsg,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.red.shade700,
//                     height: 1.4,
//                   ),
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
//               _mapController?.animateCamera(
//                 CameraUpdate.newLatLng(_cityCenter),
//               );
//               await _fetchAddress(_cityCenter);
//               print(_cityCenter.longitude);
//               print(_cityCenter.latitude);
//               print("fdgeuyfyudefi");
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade600,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 'Reset',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Reusable small widgets ────────────────────────────────────────────────────
//
// class _HeaderBtn extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;
//   const _HeaderBtn({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: color.withValues(alpha: 0.2)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 13, color: color),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _HintChip extends StatelessWidget {
//   final String label;
//   final bool isWarning;
//   const _HintChip({required this.label, this.isWarning = false});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = isWarning ? Colors.red.shade600 : ColorConst.primaryGreen;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.94),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             isWarning ? Icons.warning_amber_rounded : Icons.touch_app_rounded,
//             size: 12,
//             color: color,
//           ),
//           const SizedBox(width: 5),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
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
//         color: Colors.white.withValues(alpha: 0.94),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.3),
//               shape: BoxShape.circle,
//               border: Border.all(color: color, width: 1.5),
//             ),
//           ),
//           const SizedBox(width: 5),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF374151),
//             ),
//           ),
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
//               color: Colors.black.withValues(alpha: 0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, size: 18, color: const Color(0xFF374151)),
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
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: FontWeight.w700,
//                     color: color,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF111827),
//                   ),
//                 ),
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
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_zone_list_model.dart';
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

  bool _isSelectingFromSearch = false;

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

  // ── FIX: OverlayEntry for web-safe dropdown ───────────────────────────────
  OverlayEntry? _dropdownOverlay;
  final GlobalKey _searchBarKey = GlobalKey();

  // ── Animation ────────────────────────────────────────────────────────────
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

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
      _fetchAddress(_selectedLocation);
      Future.delayed(const Duration(milliseconds: 500), _fitCityBoundary);
    });

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    );
    _slideCtrl.forward();

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _removeDropdownOverlay();
            setState(() => _searchResults = []);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _removeDropdownOverlay();
    _mapController?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _radiusCtrl.dispose();
    _slideCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Overlay dropdown helpers ──────────────────────────────────────────────

  /// Web pe OverlayEntry use karo taaki map ke HtmlElementView se
  /// pointer-event conflict na ho. Mobile pe normal Column dropdown kaafi hai.
  void _showDropdownOverlay() {
    if (!kIsWeb) return;
    _removeDropdownOverlay();

    // Search bar ki RenderBox se exact screen position nikalo
    final renderBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _dropdownOverlay = OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4, // search bar ke neeche 4px gap
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: _WebSearchDropdownList(
            results: List.from(_searchResults),
            onSelect: (placeId) {
              _removeDropdownOverlay();
              _selectPlace(placeId);
            },
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _removeDropdownOverlay() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  // ── Camera ───────────────────────────────────────────────────────────────

  void _fitCityBoundary() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _cityCenter, zoom: _radiusToZoom(_cityRadiusKm)),
      ),
    );
  }

  void _fitHubCoverage() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedLocation,
          zoom: _radiusToZoom(_hubRadius),
        ),
      ),
    );
  }

  double _radiusToZoom(double radiusKm) {
    const double base = 16.0;
    final double delta = log(radiusKm / 0.5) / log(2);
    return (base - delta).clamp(3.0, 18.0);
  }

  // ── Geo helpers ──────────────────────────────────────────────────────────

  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final s =
        sin(dLat / 2) * sin(dLat / 2) +
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
      final c = LatLng(
        double.parse(z.latitude.toString()),
        double.parse(z.longitude.toString()),
      );
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
          center: LatLng(
            double.parse(z.latitude.toString()),
            double.parse(z.longitude.toString()),
          ),
          radius: double.parse(z.radiuskm.toString()) * 1000,
          fillColor: Colors.orange.withValues(alpha: 0.10),
          strokeColor: Colors.orange.withValues(alpha: 0.6),
          strokeWidth: 2,
        ),
    };
  }

  LatLng _clampToCity(LatLng point) {
    final dist = _distanceKm(point, _cityCenter);
    if (dist <= _cityRadiusKm) return point;
    final ratio = _cityRadiusKm / dist;
    final lat =
        _cityCenter.latitude + (point.latitude - _cityCenter.latitude) * ratio;
    final lng =
        _cityCenter.longitude +
            (point.longitude - _cityCenter.longitude) * ratio;
    return LatLng(lat, lng);
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
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _isOutsideBoundary
            ? BitmapDescriptor.hueRed
            : BitmapDescriptor.hueGreen,
      ),
      onDragStart: (_) => debugPrint("Dragging started"),
      onDrag: (pos) {
        if (_isInsideCity(pos)) {
          setState(() => _selectedLocation = pos);
        }
      },
      onDragEnd: (pos) async {
        if (!_isInsideCity(pos)) {
          CustomSnackBar.show(
            context,
            message: '❌ You can only drag inside blue zone',
            type: SnackBarType.error,
          );
          pos = _clampToCity(pos);
        }
        if (_checkOverlapWith(pos, _hubRadius)) {
          CustomSnackBar.show(
            context,
            message: '❌ Overlapping another hub zone',
            type: SnackBarType.error,
          );
          return;
        }
        setState(() {
          _selectedLocation = pos;
          _isOutsideBoundary = !_isInsideCity(pos);
        });
        await _fetchAddress(pos);
        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      },
    ),
  };

  // ── Map tap ───────────────────────────────────────────────────────────────

  Future<void> _onMapTap(LatLng latLng) async {
    if (_isSelectingFromSearch) return;
    if (_checkOverlapWith(latLng, _hubRadius)) {
      CustomSnackBar.show(
        context,
        message: 'This location overlaps an existing hub zone!',
        type: SnackBarType.error,
      );
      return;
    }
    if (!_isInsideCity(latLng)) {
      CustomSnackBar.show(
        context,
        message: 'Outside zone! Auto adjusting...',
        type: SnackBarType.error,
      );
      latLng = _cityCenter;
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
            '?latlng=${latLng.latitude},${latLng.longitude}&components=country:IN'
            '&result_type=street_address|premise|subpremise|route|locality|postal_code'
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
    String streetNumber = '',
        route = '',
        sublocality = '',
        locality = '',
        adminArea = '',
        pincode = '';
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
      _street = [streetNumber, route].where((e) => e.isNotEmpty).join(' ');
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
      _removeDropdownOverlay();
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searchLoading = true);
    _debounce = Timer(
      const Duration(milliseconds: 450),
          () => _searchPlaces(q),
    );
  }

  Future<void> _searchPlaces(String q) async {
    try {
      final res = await http.get(Uri.parse(ApiUrl.mapPlaceAutoCompleteUrl(q)));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['data'] ?? [];
        setState(() => _searchResults = results);
        // Web: OverlayEntry use karo; mobile: setState se rebuild ho jaata hai
        if (kIsWeb && results.isNotEmpty) {
          _showDropdownOverlay();
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  Future<void> _selectPlace(String placeId) async {
    _isSelectingFromSearch = true;
    _removeDropdownOverlay();
    setState(() {
      _searchResults = [];
      _searchResultOutside = false;
      _searchOutsideMsg = '';
    });
    _searchCtrl.clear();
    _searchFocus.unfocus();

    try {
      final res = await http.get(Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId)));
      if (!mounted) return;
      final data = jsonDecode(res.body);
      final loc = data['data'];
      if (loc == null) {
        CustomSnackBar.show(
          context,
          message: 'Could not fetch location details.',
          type: SnackBarType.error,
        );
        return;
      }
      final latLng = LatLng(
        double.parse(loc['lat'].toString()),
        double.parse(loc['lng'].toString()),
      );

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
          CustomSnackBar.show(
            context,
            message: 'This location overlaps an existing hub zone!',
            type: SnackBarType.error,
          );
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
          CameraPosition(target: latLng, zoom: 14.0),
        ),
      );
    } catch (e) {
      debugPrint('_selectPlace: $e');
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to load place details.',
          type: SnackBarType.error,
        );
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isSelectingFromSearch = false;
      });
    }
  }

  // ── Radius ────────────────────────────────────────────────────────────────

  void _onRadiusSlider(double val) {
    if (_checkOverlapWith(_selectedLocation, val)) {
      CustomSnackBar.show(
        context,
        message: 'Radius will overlap an existing hub zone!',
        type: SnackBarType.error,
      );
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
        CustomSnackBar.show(
          context,
          message: 'This radius overlaps an existing hub zone!',
          type: SnackBarType.error,
        );
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
      CustomSnackBar.show(
        context,
        message: 'Hub overlaps with an existing zone!',
        type: SnackBarType.error,
      );
      return;
    }
    Navigator.pop(context, {
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _fullAddress,
      'pincode': _pincode,
      'radius': _hubRadius,
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb || size.width > 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb
            ? (size.width > 1100 ? (size.width - 1000) / 2 : 20)
            : 12,
        vertical: isWeb ? 24 : 16,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_slideAnim),
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
                    child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
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
            child: const Icon(
              Icons.map_rounded,
              size: 18,
              color: ColorConst.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Hub Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'City Zone: ${widget.cityZone?.name ?? "—"}  •  '
                      'Radius: ${_cityRadiusKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
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
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Web layout ────────────────────────────────────────────────────────────

  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              _buildGoogleMap(),
              // ✅ FIX: Search bar + warnings in a non-intercepting layer.
              // IgnorePointer wraps nothing here — we DO want pointer events
              // on the search bar. The key fix is using OverlayEntry for the
              // dropdown so it lives ABOVE the map's HtmlElementView entirely.
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // GlobalKey se position track karo overlay ke liye
                    _buildSearchBar(key: _searchBarKey),
                    // Mobile-only: show dropdown inline (no overlay needed)
                    if (!kIsWeb && _searchResults.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildSearchDropdown(onSelect: _selectPlace),
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
              // Legend
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
                      label: 'Existing hub zones',
                    ),
                  ],
                ),
              ),
              // Zoom controls
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    _MapBtn(
                      icon: Icons.add_rounded,
                      onTap: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                    const SizedBox(height: 6),
                    _MapBtn(
                      icon: Icons.remove_rounded,
                      onTap: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                    const SizedBox(height: 6),
                    _MapBtn(
                      icon: Icons.my_location_rounded,
                      onTap: _fitCityBoundary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE8ECF0)),
        SizedBox(width: 320, child: _buildRightPanel()),
      ],
    );
  }

  // ── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Container(
        height: Sizes.screenHeight,
        width: Sizes.screenWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildSearchDropdown(onSelect: _selectPlace),
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
                          label: 'Existing hub zones',
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 18,
                    child: Column(
                      children: [
                        _MapBtn(
                          icon: Icons.add_rounded,
                          onTap: () => _mapController
                              ?.animateCamera(CameraUpdate.zoomIn()),
                        ),
                        const SizedBox(height: 6),
                        _MapBtn(
                          icon: Icons.remove_rounded,
                          onTap: () => _mapController
                              ?.animateCamera(CameraUpdate.zoomOut()),
                        ),
                        const SizedBox(height: 6),
                        _MapBtn(
                          icon: Icons.my_location_rounded,
                          onTap: _fitCityBoundary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildMobileBottomPanel(),
          ],
        ),
      ),
    );
  }

  // ── Google Map widget ─────────────────────────────────────────────────────

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
      // ✅ onTap: sirf tab disable karo jab selecting ho.
      // Dropdown open hone se onTap band NAHI karna — dropdown ab Overlay mein
      // hai aur map ke upar nahi, isliye conflict nahi hoga.
      onTap: _isSelectingFromSearch ? null : _onMapTap,
      onLongPress: _isSelectingFromSearch ? null : _onMapTap,
      circles: _circles,
      markers: _markers,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      // ✅ gestureRecognizers: hamesha zoom/pan allow karo.
      // Web pe EagerGestureRecognizer chahiye pointer capture ke liye.
      // Dropdown ab Overlay mein hai to gestureRecognizers band karne ki
      // zaroorat NAHI hai.
      gestureRecognizers: kIsWeb
          ? <Factory<OneSequenceGestureRecognizer>>{
        Factory<EagerGestureRecognizer>(
              () => EagerGestureRecognizer(),
        ),
      }
          : <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  // ── Right panel ───────────────────────────────────────────────────────────

  Widget _buildRightPanel() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoordinatesCard(),
            const SizedBox(height: 20),
            _buildPanelSection('Detected Address', Icons.location_on_rounded),
            const SizedBox(height: 10),
            _buildAddressContent(),
            const SizedBox(height: 20),
            _buildPanelSection('Hub Coverage Radius', Icons.radar_rounded),
            const SizedBox(height: 10),
            _buildRadiusContent(),
            const SizedBox(height: 24),
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
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          _buildCoordinatesCard(),
          const SizedBox(height: 12),
          _buildAddressContent(),
          const SizedBox(height: 12),
          _buildRadiusContent(),
          const SizedBox(height: 14),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
            letterSpacing: 0.2,
          ),
        ),
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
          const Icon(
            Icons.gps_fixed_rounded,
            size: 14,
            color: ColorConst.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COORDINATES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_selectedLocation.latitude.toStringAsFixed(6)}, '
                      '${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                strokeWidth: 2,
                color: ColorConst.primaryGreen,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Fetching address…',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    if (_street.isEmpty && _city.isEmpty && _state.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF9CA3AF)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap/click inside the blue circle to pick a location',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
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
                    value: _street,
                  ),
                ),
              if (_street.isNotEmpty && _city.isNotEmpty)
                const SizedBox(width: 8),
              if (_city.isNotEmpty)
                Expanded(
                  child: _AddrTile(
                    icon: Icons.location_city_rounded,
                    color: const Color(0xFF2563EB),
                    label: 'City',
                    value: _city,
                  ),
                ),
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
                    value: _state,
                  ),
                ),
              if (_state.isNotEmpty && _pincode.isNotEmpty)
                const SizedBox(width: 8),
              if (_pincode.isNotEmpty)
                Expanded(
                  child: _AddrTile(
                    icon: Icons.pin_rounded,
                    color: const Color(0xFFF472B6),
                    label: 'Pincode',
                    value: _pincode,
                  ),
                ),
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
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: _onRadiusField,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.primaryGreen,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 9,
                  ),
                  suffixText: 'km',
                  suffixStyle: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
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
              const Text(
                '0.5 km',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
              Text(
                '${_cityRadiusKm.toStringAsFixed(1)} km (max)',
                style:
                const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isOutsideBoundary
              ? Colors.red.shade400
              : ColorConst.primaryGreen,
          disabledBackgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar({Key? key}) {
    return Container(
      key: key,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
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
                color: ColorConst.primaryGreen,
              ),
            )
                : const Icon(
              Icons.search_rounded,
              key: ValueKey('icon'),
              size: 18,
              color: ColorConst.primaryGreen,
            ),
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
                color: Color(0xFF111827),
              ),
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
                _removeDropdownOverlay();
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
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Inline dropdown (mobile only) ─────────────────────────────────────────

  Widget _buildSearchDropdown({required Function(String) onSelect}) {
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
            offset: const Offset(0, 4),
          ),
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
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(place['place_id']),
              child: _SearchResultTile(main: main, sub: sub),
            );
          },
        ),
      ),
    );
  }

  // ── Warning widgets ───────────────────────────────────────────────────────

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
          Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Outside city boundary — move pin inside the blue circle.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                _selectedLocation = _cityCenter;
                _isOutsideBoundary = false;
                _searchResultOutside = false;
              });
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(_cityCenter),
              );
              await _fetchAddress(_cityCenter);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reset',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
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
          Icon(Icons.location_off_rounded, size: 16, color: Colors.red.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Outside City Zone',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _searchOutsideMsg,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade700,
                    height: 1.4,
                  ),
                ),
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
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(_cityCenter),
              );
              await _fetchAddress(_cityCenter);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Web Overlay Dropdown List ─────────────────────────────────────────────────
//
// Yeh sirf list widget hai — positioning _showDropdownOverlay() mein
// Positioned se hoti hai jo RenderBox se exact screen coords leta hai.

class _WebSearchDropdownList extends StatelessWidget {
  final List<dynamic> results;
  final Function(String placeId) onSelect;

  const _WebSearchDropdownList({
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          itemBuilder: (_, i) {
            final place = results[i];
            final desc = place['description'] as String? ?? '';
            final parts = desc.split(',');
            final main = parts.first.trim();
            final sub =
            parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(place['place_id']),
                child: _SearchResultTile(main: main, sub: sub),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Shared tile widget ────────────────────────────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final String main;
  final String sub;
  const _SearchResultTile({required this.main, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: ColorConst.primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  main,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.north_west_rounded,
            size: 13,
            color: Color(0xFF9CA3AF),
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
  const _HeaderBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
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
    final color = isWarning ? Colors.red.shade600 : ColorConst.primaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.touch_app_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
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
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
          ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
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
              offset: const Offset(0, 2),
            ),
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
  const _AddrTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}