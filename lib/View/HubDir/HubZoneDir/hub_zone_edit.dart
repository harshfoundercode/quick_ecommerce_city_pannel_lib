//
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
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_edit_view_model.dart';
//
// // ── Design tokens ─────────────────────────────────────────────────────────────
// const _kAccent      = ColorConst.primaryGreen;
// const _kAccentLight = Color(0xFFEEF2FF);
// const _kBg          = Color(0xFFF8FAFC);
// const _kBorder      = Color(0xFFE2E8F0);
// const _kTextHead    = Color(0xFF1E293B);
// const _kTextMuted   = Color(0xFF94A3B8);
// const _kSuccess     = Color(0xFF10B981);
// const _kError       = Color(0xFFEF4444);
//
// /// Screen width >= this → web two-column layout
// const double _kWebBreakpoint = 860;
//
// // ── Place suggestion model ────────────────────────────────────────────────────
// class _PlaceSuggestion {
//   final String placeId;
//   final String mainText;
//   final String secondaryText;
//   const _PlaceSuggestion({
//     required this.placeId,
//     required this.mainText,
//     required this.secondaryText,
//   });
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HubZoneEditScreen
// // ─────────────────────────────────────────────────────────────────────────────
// class HubZoneEditScreen extends StatefulWidget {
//   final HubZoneListData zone;
//   final LatLng? cityZoneCenter;
//   final double? cityZoneRadiusKm;
//
//   const HubZoneEditScreen({
//     super.key,
//     required this.zone,
//     this.cityZoneCenter,
//     this.cityZoneRadiusKm,
//   });
//
//   @override
//   State<HubZoneEditScreen> createState() => _HubZoneEditScreenState();
// }
//
// class _HubZoneEditScreenState extends State<HubZoneEditScreen>
//     with SingleTickerProviderStateMixin {
//
//   // ── Form ──────────────────────────────────────────────────────────────────
//   final _formKey  = GlobalKey<FormState>();
//   late TextEditingController _nameCtrl;
//   late TextEditingController _addressCtrl;
//   late TextEditingController _pincodeCtrl;
//   late TextEditingController _radiusCtrl;
//   late TextEditingController _latCtrl;
//   late TextEditingController _lngCtrl;
//
//   // ── Search ────────────────────────────────────────────────────────────────
//   final TextEditingController _searchCtrl  = TextEditingController();
//   final FocusNode             _searchFocus = FocusNode();
//   final LayerLink             _layerLink   = LayerLink();
//   OverlayEntry? _overlayEntry;
//   List<_PlaceSuggestion> _suggestions  = [];
//   bool  _searchLoading = false;
//   Timer? _debounce;
//
//   // ── Map ───────────────────────────────────────────────────────────────────
//   GoogleMapController? _mapController;
//   late LatLng _pickedLatLng;
//   bool _isOutsideZone = false;
//
//   // ── City zone ─────────────────────────────────────────────────────────────
//   late LatLng  _cityCenter;
//   late double  _cityRadiusKm;
//
//   // ── Animation ─────────────────────────────────────────────────────────────
//   late AnimationController _fadeCtrl;
//   late Animation<double>   _fadeAnim;
//
//   // ── Scroll (mobile) ───────────────────────────────────────────────────────
//   final ScrollController _scrollCtrl = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     final z = widget.zone;
//     _nameCtrl    = TextEditingController(text: z.name?.toString()    ?? '');
//     _addressCtrl = TextEditingController(text: z.address?.toString() ?? '');
//     _pincodeCtrl = TextEditingController(text: z.pincode?.toString() ?? '');
//     _radiusCtrl  = TextEditingController(text: z.radiusInKm.toStringAsFixed(2));
//     _latCtrl     = TextEditingController(text: z.latitude.toString());
//     _lngCtrl     = TextEditingController(text: z.longitude.toString());
//
//     _pickedLatLng = LatLng(z.latitude, z.longitude);
//     _cityCenter   = widget.cityZoneCenter ?? _pickedLatLng;
//     _cityRadiusKm = widget.cityZoneRadiusKm ?? 5;
//
//     print("CITY CENTER: $_cityCenter");
//     print("CITY RADIUS: $_cityRadiusKm");
//
//     _fadeCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 450));
//     _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
//     _fadeCtrl.forward();
//
//     _radiusCtrl.addListener(() => setState(() {}));
//
//     _searchFocus.addListener(() {
//       if (!_searchFocus.hasFocus) {
//         Future.delayed(const Duration(milliseconds: 150), _removeOverlay);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();   _addressCtrl.dispose();
//     _pincodeCtrl.dispose(); _radiusCtrl.dispose();
//     _latCtrl.dispose();    _lngCtrl.dispose();
//     _searchCtrl.dispose(); _searchFocus.dispose();
//     _mapController?.dispose();
//     _fadeCtrl.dispose();   _scrollCtrl.dispose();
//     _debounce?.cancel();
//     _removeOverlay();
//     super.dispose();
//   }
//
//   // ── Boundary helpers ──────────────────────────────────────────────────────
//   double _distanceKm(LatLng a, LatLng b) {
//     const r = 6371.0;
//     final dLat = _deg2rad(b.latitude  - a.latitude);
//     final dLon = _deg2rad(b.longitude - a.longitude);
//     final s = sin(dLat / 2), t = sin(dLon / 2);
//     final x = s * s +
//         cos(_deg2rad(a.latitude)) * cos(_deg2rad(b.latitude)) * t * t;
//     return r * 2 * atan2(sqrt(x), sqrt(1 - x));
//   }
//
//   double _deg2rad(double d) => d * pi / 180;
//
//   bool _isInsideCity(LatLng p) =>
//       _cityRadiusKm == double.infinity ||
//           _distanceKm(p, _cityCenter) <= _cityRadiusKm;
//
//   // ── Map overlays ──────────────────────────────────────────────────────────
//   Set<Marker> get _markers => {
//     Marker(
//       markerId: const MarkerId('edit_pin'),
//       position: _pickedLatLng,
//       draggable: true,
//       icon: BitmapDescriptor.defaultMarkerWithHue(
//         _isOutsideZone
//             ? BitmapDescriptor.hueRed
//             : BitmapDescriptor.hueViolet,
//       ),
//       onDragEnd: _onLocationPicked,
//     ),
//   };
//
//   Set<Circle> get _circles {
//     final hubM =
//         (double.tryParse(_radiusCtrl.text) ?? widget.zone.radiusInKm) * 1000;
//     return {
//       if (_cityRadiusKm > 0)
//         Circle(
//           circleId: const CircleId('city_boundary'),
//           center:      _cityCenter,
//           radius:      _cityRadiusKm * 1000,
//           fillColor:   const Color(0xFF2563EB).withValues(alpha: 0.05),
//           strokeColor: _isOutsideZone
//               ? Colors.red.withValues(alpha: 0.7)
//               : const Color(0xFF2563EB).withValues(alpha: 0.45),
//           strokeWidth: 2,
//         ),
//       Circle(
//         circleId: const CircleId('hub_coverage'),
//         center:      _pickedLatLng,
//         radius:      hubM,
//         fillColor:   _isOutsideZone
//             ? Colors.red.withValues(alpha: 0.12)
//             : _kAccent.withValues(alpha: 0.13),
//         strokeColor: _isOutsideZone
//             ? Colors.red.withValues(alpha: 0.65)
//             : _kAccent.withValues(alpha: 0.7),
//         strokeWidth: 2,
//       ),
//     };
//   }
//
//   // ── Location pick ─────────────────────────────────────────────────────────
//   void _onLocationPicked(LatLng pos) {
//     final outside = !_isInsideCity(pos);
//     if (outside) {
//       _showSnack('⚠ Location is outside the city zone!', isError: true);
//     }
//     setState(() { _pickedLatLng = pos; _isOutsideZone = outside; });
//     _latCtrl.text = pos.latitude.toStringAsFixed(6);
//     _lngCtrl.text = pos.longitude.toStringAsFixed(6);
//     _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
//   }
//
//   void _resetToZoneCenter() {
//     setState(() { _pickedLatLng = _cityCenter; _isOutsideZone = false; });
//     _latCtrl.text = _cityCenter.latitude.toStringAsFixed(6);
//     _lngCtrl.text = _cityCenter.longitude.toStringAsFixed(6);
//     _mapController?.animateCamera(CameraUpdate.newLatLng(_cityCenter));
//   }
//
//   void _syncCoordsFromFields() {
//     final lat = double.tryParse(_latCtrl.text);
//     final lng = double.tryParse(_lngCtrl.text);
//     if (lat != null && lng != null) _onLocationPicked(LatLng(lat, lng));
//   }
//
//   // ── Search ────────────────────────────────────────────────────────────────
//   void _onSearchChanged(String query) {
//     _debounce?.cancel();
//     if (query.trim().isEmpty) {
//       _removeOverlay();
//       setState(() => _suggestions = []);
//       return;
//     }
//     _debounce = Timer(
//       const Duration(milliseconds: 400),
//           () => _fetchSuggestions(query.trim()),
//     );
//   }
//
//   Future<void> _fetchSuggestions(String input) async {
//     setState(() => _searchLoading = true);
//     try {
//       final res = await http.get(
//         Uri.parse(ApiUrl.mapPlaceAutoCompleteUrl(Uri.encodeComponent(input))),
//       );
//       if (!mounted) return;
//       if (res.statusCode == 200) {
//         final json = jsonDecode(res.body);
//         final preds = (json['data'] as List).map((p) {
//           final sf = p['structured_formatting'];
//           return _PlaceSuggestion(
//             placeId:       p['place_id'],
//             mainText:      sf != null
//                 ? (sf['main_text']      ?? p['description'] ?? '')
//                 : (p['description']     ?? ''),
//             secondaryText: sf != null ? (sf['secondary_text'] ?? '') : '',
//           );
//         }).toList();
//         setState(() => _suggestions = preds);
//         if (preds.isNotEmpty) _showOverlay();
//       }
//     } catch (_) {
//     } finally {
//       if (mounted) setState(() => _searchLoading = false);
//     }
//   }
//
//   Future<void> _fetchPlaceDetails(String placeId) async {
//     _removeOverlay();
//     setState(() { _suggestions = []; _searchLoading = true; });
//     _searchFocus.unfocus();
//
//     try {
//       final res = await http.get(Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId)));
//       if (!mounted) return;
//       if (res.statusCode != 200) {
//         _showSnack('Could not fetch location details.', isError: true);
//         return;
//       }
//
//       final json    = jsonDecode(res.body);
//       double lat    = 0, lng = 0;
//       String address = '', pincode = '';
//
//       if (json['data'] != null && json['data'] is Map) {
//         final data = json['data'] as Map<String, dynamic>;
//         if (data['lat'] != null && data['lng'] != null) {
//           lat     = double.parse(data['lat'].toString());
//           lng     = double.parse(data['lng'].toString());
//           address = data['address']?.toString() ?? '';
//           pincode = data['pincode']?.toString() ?? '';
//         } else if (data['geometry'] != null) {
//           final loc = data['geometry']['location'];
//           lat     = (loc['lat'] as num).toDouble();
//           lng     = (loc['lng'] as num).toDouble();
//           address = data['formatted_address']?.toString() ?? '';
//           for (final c in (data['address_components'] ?? [])) {
//             if ((c['types'] as List).contains('postal_code')) {
//               pincode = c['long_name']; break;
//             }
//           }
//         }
//       } else if (json['results'] is List &&
//           (json['results'] as List).isNotEmpty) {
//         final r   = json['results'][0];
//         final loc = r['geometry']['location'];
//         lat     = (loc['lat'] as num).toDouble();
//         lng     = (loc['lng'] as num).toDouble();
//         address = r['formatted_address']?.toString() ?? '';
//         for (final c in (r['address_components'] ?? [])) {
//           if ((c['types'] as List).contains('postal_code')) {
//             pincode = c['long_name']; break;
//           }
//         }
//       }
//
//       if (lat == 0 && lng == 0) {
//         _showSnack('Invalid location data.', isError: true);
//         return;
//       }
//
//       final newPos  = LatLng(lat, lng);
//       final outside = !_isInsideCity(newPos);
//
//       _searchCtrl.text  = address.isNotEmpty ? address : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
//       _addressCtrl.text = address;
//       if (pincode.isNotEmpty) _pincodeCtrl.text = pincode;
//
//       setState(() { _pickedLatLng = newPos; _isOutsideZone = outside; });
//       _latCtrl.text = lat.toStringAsFixed(6);
//       _lngCtrl.text = lng.toStringAsFixed(6);
//
//       await _mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(CameraPosition(target: newPos, zoom: 14)),
//       );
//
//       if (outside) {
//         _showSnack('Location is outside the city zone boundary.', isError: true);
//       } else {
//         _showSnack('Location updated successfully!');
//       }
//     } catch (e) {
//       debugPrint('_fetchPlaceDetails ERROR: $e');
//       if (mounted) _showSnack('Could not load place details.', isError: true);
//     } finally {
//       if (mounted) setState(() => _searchLoading = false);
//     }
//   }
//
//   // ── Overlay ───────────────────────────────────────────────────────────────
//   void _showOverlay() {
//     _removeOverlay();
//     _overlayEntry = OverlayEntry(builder: (_) => _buildDropdown());
//     Overlay.of(context).insert(_overlayEntry!);
//   }
//
//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
//
//   Widget _buildDropdown() {
//     final sw    = MediaQuery.of(context).size.width;
//     final isWeb = sw >= _kWebBreakpoint;
//     final w     = isWeb ? (sw / 2) - 48.0 : sw - 32.0;
//
//     return Positioned(
//       width: w,
//       child: CompositedTransformFollower(
//         link:             _layerLink,
//         showWhenUnlinked: false,
//         offset:           const Offset(0, 58),
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             constraints: const BoxConstraints(maxHeight: 260),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: _kBorder),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.10),
//                   blurRadius: 20, offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: ListView.separated(
//                 padding:    const EdgeInsets.symmetric(vertical: 6),
//                 shrinkWrap: true,
//                 itemCount:  _suggestions.length,
//                 separatorBuilder: (_, __) => Divider(height: 1, color: _kBorder),
//                 itemBuilder: (_, i) {
//                   final s = _suggestions[i];
//                   return InkWell(
//                     onTap: () => _fetchPlaceDetails(s.placeId),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 12),
//                       child: Row(children: [
//                         Container(
//                           width: 34, height: 34,
//                           decoration: BoxDecoration(
//                             color: _kAccentLight,
//                             borderRadius: BorderRadius.circular(9),
//                           ),
//                           child: const Icon(Icons.location_on_rounded,
//                               size: 17, color: _kAccent),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(s.mainText,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w700,
//                                       color: _kTextHead)),
//                               if (s.secondaryText.isNotEmpty) ...[
//                                 const SizedBox(height: 2),
//                                 Text(s.secondaryText,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(
//                                         fontSize: 11, color: _kTextMuted)),
//                               ],
//                             ],
//                           ),
//                         ),
//                         const Icon(Icons.north_west_rounded,
//                             size: 14, color: _kTextMuted),
//                       ]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Snackbar ──────────────────────────────────────────────────────────────
//   void _showSnack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(children: [
//           Icon(
//             isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
//             color: Colors.white, size: 18,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(msg,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//                 overflow: TextOverflow.ellipsis, maxLines: 2),
//           ),
//         ]),
//         backgroundColor: isError ? _kError : _kSuccess,
//         behavior:   SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   // ── Submit ────────────────────────────────────────────────────────────────
//   void _submit() {
//     if (_isOutsideZone) {
//       _showSnack('Cannot save — location is outside the city zone.', isError: true);
//       return;
//     }
//     if (!_formKey.currentState!.validate()) return;
//     FocusScope.of(context).unfocus();
//     Provider.of<HubZoneEditViewModel>(context, listen: false).editZoneApi(
//       context,
//       widget.zone.id.toString(),
//       widget.zone.cityzoneid.toString(),
//       _nameCtrl.text.trim(),
//       _radiusCtrl.text.trim(),
//       _latCtrl.text.trim(),
//       _lngCtrl.text.trim(),
//       _pincodeCtrl.text.trim(),
//       _addressCtrl.text.trim(),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => HubZoneEditViewModel(),
//       child: Scaffold(
//         backgroundColor: _kBg,
//         body: FadeTransition(
//           opacity: _fadeAnim,
//           child: Consumer<HubZoneEditViewModel>(
//             builder: (context, evm, _) => LayoutBuilder(
//               builder: (context, constraints) {
//                 final isWeb = constraints.maxWidth >= _kWebBreakpoint;
//                 return isWeb
//                     ? _buildWebLayout(evm)
//                     : _buildMobileLayout(evm);
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // WEB: two-column — left full-height map | right scrollable form
//   // ─────────────────────────────────────────────────────────────────────────
//   Widget _buildWebLayout(HubZoneEditViewModel evm) {
//     return Column(
//       children: [
//         // ── Top bar ───────────────────────────────────────────────────────
//         Container(
//           height: 60,
//           color: Colors.white,
//           child: Column(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Row(children: [
//                     // Back
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 7),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF1F5F9),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.arrow_back_ios_new_rounded,
//                                 size: 14, color: _kTextHead),
//                             SizedBox(width: 6),
//                             Text('Back',
//                                 style: TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                     color: _kTextHead)),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     // Title
//                     Container(
//                       padding: const EdgeInsets.all(7),
//                       decoration: BoxDecoration(
//                           color: _kAccentLight,
//                           borderRadius: BorderRadius.circular(9)),
//                       child: const Icon(Icons.edit_location_alt_rounded,
//                           size: 16, color: _kAccent),
//                     ),
//                     const SizedBox(width: 10),
//                     const Text('Edit Hub Zone',
//                         style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w700,
//                             color: _kTextHead)),
//                     const Spacer(),
//                     // Zone ID badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: _kAccentLight,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                             color: _kAccent.withValues(alpha: 0.3)),
//                       ),
//                       child: Row(mainAxisSize: MainAxisSize.min, children: [
//                         const Icon(Icons.tag_rounded,
//                             size: 13, color: _kAccent),
//                         const SizedBox(width: 4),
//                         Text('Zone ID ${widget.zone.id}',
//                             style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                                 color: _kAccent)),
//                       ]),
//                     ),
//                   ]),
//                 ),
//               ),
//               Divider(height: 1, color: _kBorder),
//             ],
//           ),
//         ),
//
//         // ── Body row ──────────────────────────────────────────────────────
//         Expanded(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // LEFT — full-height map
//               Expanded(
//                 flex: 55,
//                 child: _WebMapPanel(
//                   pickedLatLng:   _pickedLatLng,
//                   markers:        _markers,
//                   circles:        _circles,
//                   isOutsideZone:  _isOutsideZone,
//                   hasCityBoundary: _cityRadiusKm != double.infinity,
//                   onMapCreated:   (c) => _mapController = c,
//                   onTap:          _onLocationPicked,
//                   onZoomIn: () =>
//                       _mapController?.animateCamera(CameraUpdate.zoomIn()),
//                   onZoomOut: () =>
//                       _mapController?.animateCamera(CameraUpdate.zoomOut()),
//                   onRecenter: () => _mapController?.animateCamera(
//                       CameraUpdate.newLatLng(_pickedLatLng)),
//                 ),
//               ),
//
//               // Divider
//               Container(width: 1, color: _kBorder),
//
//               // RIGHT — scrollable form
//               Expanded(
//                 flex: 45,
//                 child: Container(
//                   color: _kBg,
//                   child: Form(
//                     key: _formKey,
//                     child: ListView(
//                       padding: const EdgeInsets.all(24),
//                       children: [
//                         _webSection(Icons.search_rounded,
//                             'Search Location', 'Find a place inside the city zone'),
//                         const SizedBox(height: 12),
//                         CompositedTransformTarget(
//                           link: _layerLink,
//                           child: _SearchBarWidget(
//                             controller: _searchCtrl,
//                             focusNode:  _searchFocus,
//                             isLoading:  _searchLoading,
//                             onChanged:  _onSearchChanged,
//                             onClear: () {
//                               _searchCtrl.clear();
//                               _removeOverlay();
//                               setState(() => _suggestions = []);
//                             },
//                           ),
//                         ),
//                         if (_isOutsideZone && _cityRadiusKm != double.infinity) ...[
//                           const SizedBox(height: 10),
//                           _OutsideBoundaryBanner(onReset: _resetToZoneCenter),
//                         ],
//
//                         const SizedBox(height: 24),
//                         _webSection(Icons.my_location_rounded,
//                             'Coordinates & Radius', 'Edit or drag the pin on the map'),
//                         const SizedBox(height: 12),
//                         Row(children: [
//                           Expanded(child: _EditField(
//                             controller: _latCtrl, label: 'Latitude',
//                             icon: Icons.my_location_rounded,
//                             keyboardType: const TextInputType.numberWithOptions(
//                                 decimal: true, signed: true),
//                             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
//                             onChanged: (_) => _syncCoordsFromFields(),
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           )),
//                           const SizedBox(width: 10),
//                           Expanded(child: _EditField(
//                             controller: _lngCtrl, label: 'Longitude',
//                             icon: Icons.explore_rounded,
//                             keyboardType: const TextInputType.numberWithOptions(
//                                 decimal: true, signed: true),
//                             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
//                             onChanged: (_) => _syncCoordsFromFields(),
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           )),
//                           const SizedBox(width: 10),
//                           Expanded(child: _EditField(
//                             controller: _radiusCtrl, label: 'Radius (km)',
//                             icon: Icons.radar_rounded,
//                             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
//                             validator: (v) {
//                               if (v == null || v.isEmpty) return 'Required';
//                               if (double.tryParse(v) == null) return 'Invalid';
//                               return null;
//                             },
//                           )),
//                         ]),
//
//                         const SizedBox(height: 24),
//                         _webSection(Icons.hub_rounded,
//                             'Zone Details', 'Name, address and pincode'),
//                         const SizedBox(height: 12),
//                         _EditField(
//                           controller: _nameCtrl, label: 'Zone Name',
//                           icon: Icons.label_rounded,
//                           validator: (v) => v == null || v.trim().isEmpty
//                               ? 'Zone name is required' : null,
//                         ),
//                         const SizedBox(height: 12),
//                         _EditField(
//                           controller: _addressCtrl, label: 'Address',
//                           icon: Icons.location_on_rounded,
//                           maxLines: 2,
//                           validator: (v) => v == null || v.trim().isEmpty
//                               ? 'Address is required' : null,
//                         ),
//                         const SizedBox(height: 12),
//                         _EditField(
//                           controller: _pincodeCtrl, label: 'Pincode',
//                           icon: Icons.pin_rounded,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(6),
//                           ],
//                           validator: (v) {
//                             if (v == null || v.isEmpty) return 'Pincode is required';
//                             if (v.length != 6) return 'Must be 6 digits';
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 32),
//                         _SaveButton(
//                           isLoading:  evm.editZoneLoading,
//                           isDisabled: _isOutsideZone,
//                           onTap:      _submit,
//                         ),
//                         const SizedBox(height: 24),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _webSection(IconData icon, String label, String subtitle) {
//     return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//       Container(
//         padding: const EdgeInsets.all(7),
//         decoration: BoxDecoration(
//             color: _kAccentLight, borderRadius: BorderRadius.circular(9)),
//         child: Icon(icon, size: 15, color: _kAccent),
//       ),
//       const SizedBox(width: 10),
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w700, color: _kTextHead)),
//         Text(subtitle,
//             style: const TextStyle(fontSize: 11, color: _kTextMuted)),
//       ]),
//     ]);
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // MOBILE: single-column scrollable
//   // ─────────────────────────────────────────────────────────────────────────
//   Widget _buildMobileLayout(HubZoneEditViewModel evm) {
//     return CustomScrollView(
//       controller: _scrollCtrl,
//       slivers: [
//         SliverAppBar(
//           expandedHeight: 56,
//           pinned: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           surfaceTintColor: Colors.white,
//           leading: GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                   color: const Color(0xFFF1F5F9),
//                   borderRadius: BorderRadius.circular(10)),
//               child: const Icon(Icons.arrow_back_ios_new_rounded,
//                   size: 18, color: _kTextHead),
//             ),
//           ),
//           title: const Text('Edit Hub Zone',
//               style: TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.w700, color: _kTextHead)),
//           actions: [
//             Container(
//               margin: const EdgeInsets.only(right: 16),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                   color: _kAccentLight, borderRadius: BorderRadius.circular(20)),
//               child: Text('ID #${widget.zone.id}',
//                   style: const TextStyle(
//                       fontSize: 12, fontWeight: FontWeight.w600, color: _kAccent)),
//             ),
//           ],
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(1),
//             child: Divider(height: 1, color: _kBorder),
//           ),
//         ),
//
//         SliverToBoxAdapter(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Search
//                 _mobileSection(Icons.search_rounded, 'Search Location',
//                     'Search inside the city zone'),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                   child: CompositedTransformTarget(
//                     link: _layerLink,
//                     child: _SearchBarWidget(
//                       controller: _searchCtrl,
//                       focusNode:  _searchFocus,
//                       isLoading:  _searchLoading,
//                       onChanged:  _onSearchChanged,
//                       onClear: () {
//                         _searchCtrl.clear();
//                         _removeOverlay();
//                         setState(() => _suggestions = []);
//                       },
//                     ),
//                   ),
//                 ),
//                 AnimatedSize(
//                   duration: const Duration(milliseconds: 200),
//                   child: (_suggestions.isEmpty && _searchCtrl.text.isEmpty)
//                       ? _SearchTipBanner()
//                       : const SizedBox.shrink(),
//                 ),
//                 if (_isOutsideZone && _cityRadiusKm != double.infinity) ...[
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: _OutsideBoundaryBanner(onReset: _resetToZoneCenter),
//                   ),
//                 ],
//
//                 // Map
//                 _mobileSection(Icons.map_rounded, 'Location & Coverage',
//                     'Tap map or drag pin — must stay inside blue circle'),
//                 _MobileMapCard(
//                   initialPosition: _pickedLatLng,
//                   markers:         _markers,
//                   circles:         _circles,
//                   onMapCreated:    (c) => _mapController = c,
//                   onTap:           _onLocationPicked,
//                   hasCityBoundary: _cityRadiusKm != double.infinity,
//                   isOutside:       _isOutsideZone,
//                 ),
//
//                 // Coords + radius
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//                   child: Row(children: [
//                     Expanded(child: _EditField(
//                       controller: _latCtrl, label: 'Latitude',
//                       icon: Icons.my_location_rounded,
//                       keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true, signed: true),
//                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
//                       onChanged: (_) => _syncCoordsFromFields(),
//                       validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                     )),
//                     const SizedBox(width: 10),
//                     Expanded(child: _EditField(
//                       controller: _lngCtrl, label: 'Longitude',
//                       icon: Icons.explore_rounded,
//                       keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true, signed: true),
//                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))],
//                       onChanged: (_) => _syncCoordsFromFields(),
//                       validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                     )),
//                     const SizedBox(width: 10),
//                     Expanded(child: _EditField(
//                       controller: _radiusCtrl, label: 'Radius (km)',
//                       icon: Icons.radar_rounded,
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return 'Required';
//                         if (double.tryParse(v) == null) return 'Invalid';
//                         return null;
//                       },
//                     )),
//                   ]),
//                 ),
//
//                 // Zone details
//                 _mobileSection(Icons.hub_rounded, 'Zone Details',
//                     'Name, address and pincode'),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//                   child: Column(children: [
//                     _EditField(
//                       controller: _nameCtrl, label: 'Zone Name',
//                       icon: Icons.label_rounded,
//                       validator: (v) => v == null || v.trim().isEmpty
//                           ? 'Zone name is required' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     _EditField(
//                       controller: _addressCtrl, label: 'Address',
//                       icon: Icons.location_on_rounded, maxLines: 2,
//                       validator: (v) => v == null || v.trim().isEmpty
//                           ? 'Address is required' : null,
//                     ),
//                     const SizedBox(height: 12),
//                     _EditField(
//                       controller: _pincodeCtrl, label: 'Pincode',
//                       icon: Icons.pin_rounded,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(6),
//                       ],
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return 'Required';
//                         if (v.length != 6) return 'Must be 6 digits';
//                         return null;
//                       },
//                     ),
//                   ]),
//                 ),
//
//                 const SizedBox(height: 32),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(
//                       16, 0, 16, MediaQuery.of(context).padding.bottom + 24),
//                   child: _SaveButton(
//                     isLoading:  evm.editZoneLoading,
//                     isDisabled: _isOutsideZone,
//                     onTap:      _submit,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _mobileSection(IconData icon, String label, String subtitle) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//               color: _kAccentLight, borderRadius: BorderRadius.circular(10)),
//           child: Icon(icon, size: 16, color: _kAccent),
//         ),
//         const SizedBox(width: 10),
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label,
//               style: const TextStyle(
//                   fontSize: 14, fontWeight: FontWeight.w700, color: _kTextHead)),
//           Text(subtitle,
//               style: const TextStyle(fontSize: 11, color: _kTextMuted)),
//         ]),
//       ]),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Web Map Panel (full-height, with zoom controls + badges)
// // ─────────────────────────────────────────────────────────────────────────────
// class _WebMapPanel extends StatelessWidget {
//   final LatLng pickedLatLng;
//   final Set<Marker> markers;
//   final Set<Circle> circles;
//   final bool isOutsideZone;
//   final bool hasCityBoundary;
//   final void Function(GoogleMapController) onMapCreated;
//   final void Function(LatLng) onTap;
//   final VoidCallback onZoomIn;
//   final VoidCallback onZoomOut;
//   final VoidCallback onRecenter;
//
//   const _WebMapPanel({
//     required this.pickedLatLng,
//     required this.markers,
//     required this.circles,
//     required this.isOutsideZone,
//     required this.hasCityBoundary,
//     required this.onMapCreated,
//     required this.onTap,
//     required this.onZoomIn,
//     required this.onZoomOut,
//     required this.onRecenter,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(children: [
//       GoogleMap(
//         initialCameraPosition:
//         CameraPosition(target: pickedLatLng, zoom: 13),
//         markers:               markers,
//         circles:               circles,
//         onMapCreated:          onMapCreated,
//         onTap:                 onTap,
//         zoomControlsEnabled:   false,
//         myLocationButtonEnabled: false,
//         mapToolbarEnabled:     false,
//       ),
//
//       // Status chip — top left
//       Positioned(
//         top: 16, left: 16,
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           _MapChip(
//             label:     isOutsideZone ? '⚠ Outside city zone' : 'Tap or drag pin',
//             isWarning: isOutsideZone,
//           ),
//           if (hasCityBoundary) ...[
//             const SizedBox(height: 6),
//             _MapChip(
//               label:       '● City zone boundary',
//               isWarning:   false,
//               textColor:   const Color(0xFF2563EB),
//               borderColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
//             ),
//           ],
//         ]),
//       ),
//
//       // Zoom controls — bottom right
//       Positioned(
//         bottom: 24, right: 16,
//         child: Column(children: [
//           _MapIconBtn(icon: Icons.add_rounded,    onTap: onZoomIn),
//           const SizedBox(height: 6),
//           _MapIconBtn(icon: Icons.remove_rounded, onTap: onZoomOut),
//           const SizedBox(height: 6),
//           _MapIconBtn(icon: Icons.my_location_rounded, onTap: onRecenter),
//         ]),
//       ),
//
//       // Coordinate badge — bottom left
//       Positioned(
//         bottom: 24, left: 16,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.93),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: _kBorder),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.06), blurRadius: 8),
//             ],
//           ),
//           child: Text(
//             '${pickedLatLng.latitude.toStringAsFixed(5)}, '
//                 '${pickedLatLng.longitude.toStringAsFixed(5)}',
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: _kTextHead,
//               fontFamily: 'monospace',
//             ),
//           ),
//         ),
//       ),
//     ]);
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Mobile Map Card
// // ─────────────────────────────────────────────────────────────────────────────
// class _MobileMapCard extends StatelessWidget {
//   final LatLng initialPosition;
//   final Set<Marker> markers;
//   final Set<Circle> circles;
//   final void Function(GoogleMapController) onMapCreated;
//   final void Function(LatLng) onTap;
//   final bool hasCityBoundary;
//   final bool isOutside;
//
//   const _MobileMapCard({
//     required this.initialPosition,
//     required this.markers,
//     required this.circles,
//     required this.onMapCreated,
//     required this.onTap,
//     required this.hasCityBoundary,
//     required this.isOutside,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       height: 220,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 16, offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(18),
//         child: Stack(children: [
//           GoogleMap(
//             initialCameraPosition:
//             CameraPosition(target: initialPosition, zoom: 13),
//             markers:               markers,
//             circles:               circles,
//             onMapCreated:          onMapCreated,
//             onTap:                 onTap,
//             zoomControlsEnabled:   false,
//             myLocationButtonEnabled: false,
//             mapToolbarEnabled:     false,
//           ),
//           Positioned(
//             top: 10, right: 10,
//             child: _MapChip(
//               label:     isOutside ? '⚠ Outside zone' : 'Tap or drag pin',
//               isWarning: isOutside,
//             ),
//           ),
//           if (hasCityBoundary)
//             Positioned(
//               top: 10, left: 10,
//               child: _MapChip(
//                 label:       '● City zone',
//                 isWarning:   false,
//                 textColor:   const Color(0xFF2563EB),
//                 borderColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
//               ),
//             ),
//         ]),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Small shared widgets
// // ─────────────────────────────────────────────────────────────────────────────
// class _MapChip extends StatelessWidget {
//   final String label;
//   final bool isWarning;
//   final Color? textColor;
//   final Color? borderColor;
//   const _MapChip({
//     required this.label, required this.isWarning,
//     this.textColor, this.borderColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = textColor ??
//         (isWarning ? const Color(0xFFEF4444) : _kAccent);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.93),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: borderColor ?? color.withValues(alpha: 0.3)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
//         ],
//       ),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 11, fontWeight: FontWeight.w600, color: color)),
//     );
//   }
// }
//
// class _MapIconBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _MapIconBtn({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36, height: 36,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.08),
//               blurRadius: 8, offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, size: 18, color: _kTextHead),
//       ),
//     );
//   }
// }
//
// class _SearchBarWidget extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final bool isLoading;
//   final ValueChanged<String> onChanged;
//   final VoidCallback onClear;
//
//   const _SearchBarWidget({
//     required this.controller, required this.focusNode,
//     required this.isLoading,  required this.onChanged,
//     required this.onClear,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10, offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(children: [
//         const SizedBox(width: 14),
//         AnimatedSwitcher(
//           duration: const Duration(milliseconds: 200),
//           child: isLoading
//               ? const SizedBox(
//               key: ValueKey('l'), width: 18, height: 18,
//               child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent))
//               : const Icon(Icons.search_rounded,
//               key: ValueKey('s'), size: 20, color: _kAccent),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: TextField(
//             controller: controller, focusNode: focusNode,
//             onChanged: onChanged,
//             style: const TextStyle(
//                 fontSize: 14, fontWeight: FontWeight.w500, color: _kTextHead),
//             decoration: const InputDecoration(
//               hintText: 'Search for a place or address…',
//               hintStyle: TextStyle(fontSize: 13, color: _kTextMuted),
//               border: InputBorder.none, isDense: true,
//             ),
//           ),
//         ),
//         AnimatedOpacity(
//           opacity: controller.text.isNotEmpty ? 1 : 0,
//           duration: const Duration(milliseconds: 150),
//           child: GestureDetector(
//             onTap: onClear,
//             child: Container(
//               width: 28, height: 28,
//               margin: const EdgeInsets.only(right: 10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F5F9),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.close_rounded, size: 15, color: _kTextMuted),
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _SearchTipBanner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0FDF4),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFBBF7D0)),
//       ),
//       child: const Row(children: [
//         Icon(Icons.tips_and_updates_rounded, size: 16, color: Color(0xFF059669)),
//         SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             'Search a location inside the city zone. '
//                 'Selecting fills the map, coordinates and address.',
//             style: TextStyle(fontSize: 11, color: Color(0xFF065F46), height: 1.5),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _OutsideBoundaryBanner extends StatelessWidget {
//   final VoidCallback onReset;
//   const _OutsideBoundaryBanner({required this.onReset});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             colors: [Colors.red.shade50, Colors.orange.shade50]),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Container(
//           padding: const EdgeInsets.all(5),
//           decoration: BoxDecoration(
//               color: Colors.red.shade100, shape: BoxShape.circle),
//           child: Icon(Icons.location_off_rounded,
//               size: 14, color: Colors.red.shade700),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Outside City Zone',
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.red.shade800)),
//             const SizedBox(height: 2),
//             Text('Move the pin inside the blue circle to save.',
//                 style: TextStyle(
//                     fontSize: 11, color: Colors.red.shade700, height: 1.4)),
//           ]),
//         ),
//         const SizedBox(width: 8),
//         GestureDetector(
//           onTap: onReset,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.red.shade600,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Text('Reset',
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white)),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _EditField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final TextInputType? keyboardType;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final int maxLines;
//
//   const _EditField({
//     required this.controller, required this.label, required this.icon,
//     this.keyboardType, this.inputFormatters, this.validator,
//     this.onChanged, this.maxLines = 1,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       onChanged: onChanged,
//       maxLines: maxLines,
//       style: const TextStyle(
//           fontSize: 14, fontWeight: FontWeight.w600, color: _kTextHead),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(
//             fontSize: 13, color: _kTextMuted, fontWeight: FontWeight.w500),
//         prefixIcon: Icon(icon, size: 18, color: _kAccent),
//         filled: true, fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: _kBorder)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: _kBorder)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: _kAccent, width: 1.5)),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: _kError, width: 1.5)),
//         focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: _kError, width: 1.5)),
//       ),
//     );
//   }
// }
//
// class _SaveButton extends StatelessWidget {
//   final bool isLoading;
//   final bool isDisabled;
//   final VoidCallback onTap;
//   const _SaveButton({
//     required this.isLoading, required this.onTap, this.isDisabled = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity, height: 52,
//       child: ElevatedButton(
//         onPressed: (isLoading || isDisabled) ? null : onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor:         isDisabled ? Colors.red.shade400 : _kAccent,
//           disabledBackgroundColor: isDisabled ? Colors.red.shade400 : _kAccent.withValues(alpha: 0.6),
//           disabledForegroundColor: Colors.white,
//           foregroundColor:         Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//         child: isLoading
//             ? const SizedBox(
//             width: 22, height: 22,
//             child: CircularProgressIndicator(
//                 strokeWidth: 2.5, color: Colors.white))
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(isDisabled ? Icons.block_rounded : Icons.save_rounded,
//                 size: 20),
//             const SizedBox(width: 8),
//             Text(isDisabled ? 'Outside City Zone' : 'Save Changes',
//                 style: const TextStyle(
//                     fontSize: 15, fontWeight: FontWeight.w700)),
//           ],
//         ),
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
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_edit_view_model.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kAccent      = ColorConst.primaryGreen;
const _kAccentLight = Color(0xFFEEF2FF);
const _kBg          = Color(0xFFF8FAFC);
const _kBorder      = Color(0xFFE2E8F0);
const _kTextHead    = Color(0xFF1E293B);
const _kTextMuted   = Color(0xFF94A3B8);
const _kSuccess     = Color(0xFF10B981);
const _kError       = Color(0xFFEF4444);

const double _kWebBreakpoint = 860;

// ── Place suggestion model ────────────────────────────────────────────────────
class _PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  const _PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HubZoneEditScreen
// ─────────────────────────────────────────────────────────────────────────────
class HubZoneEditScreen extends StatefulWidget {
  final HubZoneListData zone;
  final LatLng? cityZoneCenter;
  final double? cityZoneRadiusKm;

  const HubZoneEditScreen({
    super.key,
    required this.zone,
    this.cityZoneCenter,
    this.cityZoneRadiusKm,
  });

  @override
  State<HubZoneEditScreen> createState() => _HubZoneEditScreenState();
}

class _HubZoneEditScreenState extends State<HubZoneEditScreen>
    with SingleTickerProviderStateMixin {

  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey  = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _radiusCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;

  // ── Search ────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl  = TextEditingController();
  final FocusNode             _searchFocus = FocusNode();
  final GlobalKey             _searchBarKey = GlobalKey();   // ✅ FIX: web overlay positioning
  OverlayEntry? _overlayEntry;
  List<_PlaceSuggestion> _suggestions  = [];
  bool  _searchLoading = false;
  Timer? _debounce;

  // ── Map ───────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  late LatLng _pickedLatLng;
  bool _isOutsideZone = false;

  // ✅ FIX: Track outside attempt to show persistent banner
  bool _showOutsideBanner = false;
  String _outsideBannerMsg = '';

  // ── City zone ─────────────────────────────────────────────────────────────
  late LatLng  _cityCenter;
  late double  _cityRadiusKm;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  // ── Scroll (mobile) ───────────────────────────────────────────────────────
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final z = widget.zone;
    _nameCtrl    = TextEditingController(text: z.name?.toString()    ?? '');
    _addressCtrl = TextEditingController(text: z.address?.toString() ?? '');
    _pincodeCtrl = TextEditingController(text: z.pincode?.toString() ?? '');
    _radiusCtrl  = TextEditingController(text: z.radiusInKm.toStringAsFixed(2));
    _latCtrl     = TextEditingController(text: z.latitude.toString());
    _lngCtrl     = TextEditingController(text: z.longitude.toString());

    _pickedLatLng = LatLng(z.latitude, z.longitude);
    _cityCenter   = widget.cityZoneCenter ?? _pickedLatLng;
    _cityRadiusKm = widget.cityZoneRadiusKm ?? 5;

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _radiusCtrl.addListener(() => setState(() {}));

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), _removeOverlay);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();   _addressCtrl.dispose();
    _pincodeCtrl.dispose(); _radiusCtrl.dispose();
    _latCtrl.dispose();    _lngCtrl.dispose();
    _searchCtrl.dispose(); _searchFocus.dispose();
    _mapController?.dispose();
    _fadeCtrl.dispose();   _scrollCtrl.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  // ── Boundary helpers ──────────────────────────────────────────────────────
  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude  - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final s = sin(dLat / 2), t = sin(dLon / 2);
    final x = s * s +
        cos(_deg2rad(a.latitude)) * cos(_deg2rad(b.latitude)) * t * t;
    return r * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  double _deg2rad(double d) => d * pi / 180;

  bool _isInsideCity(LatLng p) =>
      _cityRadiusKm == double.infinity ||
          _distanceKm(p, _cityCenter) <= _cityRadiusKm;

  // ── Map overlays ──────────────────────────────────────────────────────────
  Set<Marker> get _markers => {
    Marker(
      markerId: const MarkerId('edit_pin'),
      position: _pickedLatLng,
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _isOutsideZone
            ? BitmapDescriptor.hueRed      // ✅ Red when outside
            : BitmapDescriptor.hueViolet,
      ),
      onDrag: (pos) {
        // ✅ FIX: Show real-time feedback while dragging
        final outside = !_isInsideCity(pos);
        if (outside != _isOutsideZone) {
          setState(() => _isOutsideZone = outside);
        }
      },
      onDragEnd: _onLocationPicked,
    ),
  };

  Set<Circle> get _circles {
    final hubM =
        (double.tryParse(_radiusCtrl.text) ?? widget.zone.radiusInKm) * 1000;
    return {
      if (_cityRadiusKm > 0)
        Circle(
          circleId: const CircleId('city_boundary'),
          center:      _cityCenter,
          radius:      _cityRadiusKm * 1000,
          // ✅ FIX: Stroke turns red when outside to visually indicate boundary
          fillColor:   _isOutsideZone
              ? Colors.red.withValues(alpha: 0.04)
              : const Color(0xFF2563EB).withValues(alpha: 0.05),
          strokeColor: _isOutsideZone
              ? Colors.red.withValues(alpha: 0.8)
              : const Color(0xFF2563EB).withValues(alpha: 0.45),
          strokeWidth: _isOutsideZone ? 3 : 2,
        ),
      Circle(
        circleId: const CircleId('hub_coverage'),
        center:      _pickedLatLng,
        radius:      hubM,
        fillColor:   _isOutsideZone
            ? Colors.red.withValues(alpha: 0.12)
            : _kAccent.withValues(alpha: 0.13),
        strokeColor: _isOutsideZone
            ? Colors.red.withValues(alpha: 0.65)
            : _kAccent.withValues(alpha: 0.7),
        strokeWidth: 2,
      ),
    };
  }

  // ── Location pick ─────────────────────────────────────────────────────────
  void _onLocationPicked(LatLng pos) {
    final outside = !_isInsideCity(pos);
    setState(() {
      _pickedLatLng = pos;
      _isOutsideZone = outside;
      // ✅ FIX: Show persistent banner when outside
      _showOutsideBanner = outside;
      _outsideBannerMsg = outside
          ? 'Pin is outside the city zone boundary. Move it inside the blue circle to save.'
          : '';
    });
    _latCtrl.text = pos.latitude.toStringAsFixed(6);
    _lngCtrl.text = pos.longitude.toStringAsFixed(6);
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));

    // ✅ FIX: Show snackbar with clear message
    if (outside) {
      _showSnack('❌ Location is outside the city zone! Move pin inside the blue circle.', isError: true);
    }
  }

  void _resetToZoneCenter() {
    setState(() {
      _pickedLatLng = _cityCenter;
      _isOutsideZone = false;
      _showOutsideBanner = false;
      _outsideBannerMsg = '';
    });
    _latCtrl.text = _cityCenter.latitude.toStringAsFixed(6);
    _lngCtrl.text = _cityCenter.longitude.toStringAsFixed(6);
    _mapController?.animateCamera(CameraUpdate.newLatLng(_cityCenter));
    _showSnack('✅ Location reset to city zone center.');
  }

  void _syncCoordsFromFields() {
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (lat != null && lng != null) _onLocationPicked(LatLng(lat, lng));
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
          () => _fetchSuggestions(query.trim()),
    );
  }

  Future<void> _fetchSuggestions(String input) async {
    setState(() => _searchLoading = true);
    try {
      final res = await http.get(
        Uri.parse(ApiUrl.mapPlaceAutoCompleteUrl(Uri.encodeComponent(input))),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final preds = (json['data'] as List).map((p) {
          final sf = p['structured_formatting'];
          return _PlaceSuggestion(
            placeId:       p['place_id'],
            mainText:      sf != null
                ? (sf['main_text']      ?? p['description'] ?? '')
                : (p['description']     ?? ''),
            secondaryText: sf != null ? (sf['secondary_text'] ?? '') : '',
          );
        }).toList();
        setState(() => _suggestions = preds);
        if (preds.isNotEmpty) _showOverlay();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  Future<void> _fetchPlaceDetails(String placeId) async {
    print("dewugdi");
    _removeOverlay();
    setState(() { _suggestions = []; _searchLoading = true; });
    _searchFocus.unfocus();

    try {
      final res = await http.get(Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId)));
      if (!mounted) return;
      if (res.statusCode != 200) {
        _showSnack('Could not fetch location details.', isError: true);
        return;
      }

      final json    = jsonDecode(res.body);
      double lat    = 0, lng = 0;
      String address = '', pincode = '';

      if (json['data'] != null && json['data'] is Map) {
        final data = json['data'] as Map<String, dynamic>;
        if (data['lat'] != null && data['lng'] != null) {
          lat     = double.parse(data['lat'].toString());
          lng     = double.parse(data['lng'].toString());
          address = data['address']?.toString() ?? '';
          pincode = data['pincode']?.toString() ?? '';
        } else if (data['geometry'] != null) {
          final loc = data['geometry']['location'];
          lat     = (loc['lat'] as num).toDouble();
          lng     = (loc['lng'] as num).toDouble();
          address = data['formatted_address']?.toString() ?? '';
          for (final c in (data['address_components'] ?? [])) {
            if ((c['types'] as List).contains('postal_code')) {
              pincode = c['long_name']; break;
            }
          }
        }
      } else if (json['results'] is List &&
          (json['results'] as List).isNotEmpty) {
        final r   = json['results'][0];
        final loc = r['geometry']['location'];
        lat     = (loc['lat'] as num).toDouble();
        lng     = (loc['lng'] as num).toDouble();
        address = r['formatted_address']?.toString() ?? '';
        for (final c in (r['address_components'] ?? [])) {
          if ((c['types'] as List).contains('postal_code')) {
            pincode = c['long_name']; break;
          }
        }
      }

      if (lat == 0 && lng == 0) {
        _showSnack('Invalid location data.', isError: true);
        return;
      }

      final newPos  = LatLng(lat, lng);
      final outside = !_isInsideCity(newPos);

      _searchCtrl.text  = address.isNotEmpty
          ? address
          : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      _addressCtrl.text = address;
      if (pincode.isNotEmpty) _pincodeCtrl.text = pincode;

      setState(() {
        _pickedLatLng      = newPos;
        _isOutsideZone     = outside;
        // ✅ FIX: Show/hide banner based on result
        _showOutsideBanner = outside;
        _outsideBannerMsg  = outside
            ? 'Searched location is outside the city zone boundary "${widget.zone?.name ?? ""}".'
            ' Only locations inside the blue circle are allowed.'
            : '';
      });
      _latCtrl.text = lat.toStringAsFixed(6);
      _lngCtrl.text = lng.toStringAsFixed(6);

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: newPos, zoom: 14)),
      );

      if (outside) {
        _showSnack(
          '❌ This location is outside the city zone! '
              'Move the pin inside the blue circle.',
          isError: true,
        );
      } else {
        _showSnack('✅ Location updated successfully!');
      }
    } catch (e) {
      debugPrint('_fetchPlaceDetails ERROR: $e');
      if (mounted) _showSnack('Could not load place details.', isError: true);
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  // ── Overlay (web-safe using GlobalKey + RenderBox) ────────────────────────
  void _showOverlay() {
    _removeOverlay();

    if (kIsWeb) {
      // ✅ FIX: Web pe RenderBox se exact position lo — HtmlElementView conflict avoid
      final renderBox =
      _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        _showOverlayWithLayerLink(); // fallback
        return;
      }
      final offset = renderBox.localToGlobal(Offset.zero);
      final size   = renderBox.size;

      _overlayEntry = OverlayEntry(
        builder: (_) => Positioned(
          left:  offset.dx,
          top:   offset.dy + size.height + 4,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: _DropdownList(
              suggestions: _suggestions,
              onSelect:    _fetchPlaceDetails,
            ),
          ),
        ),
      );
    } else {
      _showOverlayWithLayerLink();
      return;
    }

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Mobile: CompositedTransformFollower approach (reliable without HtmlElementView)
  void _showOverlayWithLayerLink() {
    _overlayEntry = OverlayEntry(builder: (_) => _buildLegacyDropdown());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Legacy dropdown (mobile / fallback)
  Widget _buildLegacyDropdown() {
    final sw    = MediaQuery.of(context).size.width;
    final isWeb = sw >= _kWebBreakpoint;
    final w     = isWeb ? (sw / 2) - 48.0 : sw - 32.0;

    return Positioned(
      width: w,
      child: CompositedTransformFollower(
        link:             LayerLink(), // mobile uses its own LayerLink
        showWhenUnlinked: false,
        offset:           const Offset(0, 58),
        child: Material(
          color: Colors.transparent,
          child: _DropdownList(
            suggestions: _suggestions,
            onSelect:    _fetchPlaceDetails,
          ),
        ),
      ),
    );
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_rounded,
            color: Colors.white, size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ]),
        backgroundColor: isError ? _kError : _kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submit() {
    if (_isOutsideZone) {
      _showSnack(
        '❌ Cannot save — location is outside the city zone. '
            'Move the pin inside the blue circle.',
        isError: true,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Provider.of<HubZoneEditViewModel>(context, listen: false).editZoneApi(
      context,
      widget.zone.id.toString(),
      widget.zone.cityzoneid.toString(),
      _nameCtrl.text.trim(),
      _radiusCtrl.text.trim(),
      _latCtrl.text.trim(),
      _lngCtrl.text.trim(),
      _pincodeCtrl.text.trim(),
      _addressCtrl.text.trim(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HubZoneEditViewModel(),
      child: Scaffold(
        backgroundColor: _kBg,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Consumer<HubZoneEditViewModel>(
            builder: (context, evm, _) => LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= _kWebBreakpoint;
                return isWeb
                    ? _buildWebLayout(evm)
                    : _buildMobileLayout(evm);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WEB layout
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWebLayout(HubZoneEditViewModel evm) {
    return Column(
      children: [
        // ── Top bar ───────────────────────────────────────────────────────
        Container(
          height: 60,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios_new_rounded,
                                size: 14, color: _kTextHead),
                            SizedBox(width: 6),
                            Text('Back',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextHead)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: _kAccentLight,
                          borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.edit_location_alt_rounded,
                          size: 16, color: _kAccent),
                    ),
                    const SizedBox(width: 10),
                    const Text('Edit Hub Zone',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _kTextHead)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kAccentLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _kAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.tag_rounded,
                            size: 13, color: _kAccent),
                        const SizedBox(width: 4),
                        Text('Zone ID ${widget.zone.id}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kAccent)),
                      ]),
                    ),
                  ]),
                ),
              ),
              Divider(height: 1, color: _kBorder),
            ],
          ),
        ),

        // ── Body row ──────────────────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT — full-height map
              Expanded(
                flex: 55,
                child: _WebMapPanel(
                  pickedLatLng:    _pickedLatLng,
                  markers:         _markers,
                  circles:         _circles,
                  isOutsideZone:   _isOutsideZone,
                  hasCityBoundary: _cityRadiusKm != double.infinity,
                  onMapCreated:    (c) => _mapController = c,
                  onTap:           _onLocationPicked,
                  onZoomIn: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  onZoomOut: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  onRecenter: () => _mapController?.animateCamera(
                      CameraUpdate.newLatLng(_pickedLatLng)),
                ),
              ),

              Container(width: 1, color: _kBorder),

              // RIGHT — scrollable form
              Expanded(
                flex: 45,
                child: Container(
                  color: _kBg,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _webSection(Icons.search_rounded,
                            'Search Location',
                            'Find a place inside the city zone'),
                        const SizedBox(height: 12),

                        // ✅ FIX: Use GlobalKey on search bar for web overlay
                        _SearchBarWidget(
                          key:        _searchBarKey,
                          controller: _searchCtrl,
                          focusNode:  _searchFocus,
                          isLoading:  _searchLoading,
                          onChanged:  _onSearchChanged,
                          onClear: () {
                            _searchCtrl.clear();
                            _removeOverlay();
                            setState(() => _suggestions = []);
                          },
                        ),

                        // ✅ FIX: Persistent outside banner in form panel
                        if (_showOutsideBanner &&
                            _cityRadiusKm != double.infinity) ...[
                          const SizedBox(height: 10),
                          _OutsideBoundaryBanner(
                            message: _outsideBannerMsg,
                            onReset: _resetToZoneCenter,
                          ),
                        ],

                        const SizedBox(height: 24),
                        _webSection(Icons.my_location_rounded,
                            'Coordinates & Radius',
                            'Edit or drag the pin on the map'),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _EditField(
                            controller: _latCtrl,
                            label: 'Latitude',
                            icon: Icons.my_location_rounded,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.\-]'))
                            ],
                            onChanged: (_) => _syncCoordsFromFields(),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Required'
                                : null,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _EditField(
                            controller: _lngCtrl,
                            label: 'Longitude',
                            icon: Icons.explore_rounded,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.\-]'))
                            ],
                            onChanged: (_) => _syncCoordsFromFields(),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Required'
                                : null,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _EditField(
                            controller: _radiusCtrl,
                            label: 'Radius (km)',
                            icon: Icons.radar_rounded,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]'))
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) return 'Invalid';
                              return null;
                            },
                          )),
                        ]),

                        const SizedBox(height: 24),
                        _webSection(Icons.hub_rounded,
                            'Zone Details',
                            'Name, address and pincode'),
                        const SizedBox(height: 12),
                        _EditField(
                          controller: _nameCtrl,
                          label: 'Zone Name',
                          icon: Icons.label_rounded,
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Zone name is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _EditField(
                          controller: _addressCtrl,
                          label: 'Address',
                          icon: Icons.location_on_rounded,
                          maxLines: 2,
                          validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Address is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _EditField(
                          controller: _pincodeCtrl,
                          label: 'Pincode',
                          icon: Icons.pin_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length != 6) return 'Must be 6 digits';
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),
                        _SaveButton(
                          isLoading:  evm.editZoneLoading,
                          isDisabled: _isOutsideZone,
                          onTap:      _submit,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _webSection(IconData icon, String label, String subtitle) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: _kAccentLight,
            borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 15, color: _kAccent),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kTextHead)),
        Text(subtitle,
            style: const TextStyle(fontSize: 11, color: _kTextMuted)),
      ]),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE layout
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(HubZoneEditViewModel evm) {
    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        SliverAppBar(
          expandedHeight: 56,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: _kTextHead),
            ),
          ),
          title: const Text('Edit Hub Zone',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextHead)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: _kAccentLight,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('ID #${widget.zone.id}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kAccent)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: _kBorder),
          ),
        ),

        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search
                _mobileSection(Icons.search_rounded, 'Search Location',
                    'Search inside the city zone'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SearchBarWidget(
                    key:        _searchBarKey,
                    controller: _searchCtrl,
                    focusNode:  _searchFocus,
                    isLoading:  _searchLoading,
                    onChanged:  _onSearchChanged,
                    onClear: () {
                      _searchCtrl.clear();
                      _removeOverlay();
                      setState(() => _suggestions = []);
                    },
                  ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: (_suggestions.isEmpty && _searchCtrl.text.isEmpty)
                      ? _SearchTipBanner()
                      : const SizedBox.shrink(),
                ),

                // ✅ FIX: Persistent outside banner on mobile too
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: (_showOutsideBanner &&
                      _cityRadiusKm != double.infinity)
                      ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _OutsideBoundaryBanner(
                      message: _outsideBannerMsg,
                      onReset: _resetToZoneCenter,
                    ),
                  )
                      : const SizedBox.shrink(),
                ),

                // Map
                _mobileSection(Icons.map_rounded, 'Location & Coverage',
                    'Tap map or drag pin — must stay inside blue circle'),
                _MobileMapCard(
                  initialPosition: _pickedLatLng,
                  markers:         _markers,
                  circles:         _circles,
                  onMapCreated:    (c) => _mapController = c,
                  onTap:           _onLocationPicked,
                  hasCityBoundary: _cityRadiusKm != double.infinity,
                  isOutside:       _isOutsideZone,
                ),

                // Coords + radius
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(children: [
                    Expanded(child: _EditField(
                      controller: _latCtrl,
                      label: 'Latitude',
                      icon: Icons.my_location_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.\-]'))
                      ],
                      onChanged: (_) => _syncCoordsFromFields(),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _EditField(
                      controller: _lngCtrl,
                      label: 'Longitude',
                      icon: Icons.explore_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.\-]'))
                      ],
                      onChanged: (_) => _syncCoordsFromFields(),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _EditField(
                      controller: _radiusCtrl,
                      label: 'Radius (km)',
                      icon: Icons.radar_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    )),
                  ]),
                ),

                // Zone details
                _mobileSection(Icons.hub_rounded, 'Zone Details',
                    'Name, address and pincode'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 15),
                  child: Column(children: [
                    _EditField(
                      controller: _nameCtrl,
                      label: 'Zone Name',
                      icon: Icons.label_rounded,
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Zone name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _EditField(
                      controller: _addressCtrl,
                      label: 'Address',
                      icon: Icons.location_on_rounded,
                      maxLines: 2,
                      validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Address is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _EditField(
                      controller: _pincodeCtrl,
                      label: 'Pincode',
                      icon: Icons.pin_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length != 6) return 'Must be 6 digits';
                        return null;
                      },
                    ),
                  ]),
                ),

                const SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 0, 16,
                      MediaQuery.of(context).padding.bottom + 24),
                  child: _SaveButton(
                    isLoading:  evm.editZoneLoading,
                    isDisabled: _isOutsideZone,
                    onTap:      _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileSection(IconData icon, String label, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: _kAccentLight,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: _kAccent),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kTextHead)),
          Text(subtitle,
              style:
              const TextStyle(fontSize: 11, color: _kTextMuted)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dropdown List (shared between web overlay & mobile)
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownList extends StatelessWidget {
  final List<_PlaceSuggestion> suggestions;
  final void Function(String placeId) onSelect;

  const _DropdownList({
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding:    const EdgeInsets.symmetric(vertical: 6),
          shrinkWrap: true,
          itemCount:  suggestions.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: _kBorder),
          itemBuilder: (_, i) {
            final s = suggestions[i];
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child:  GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(s.placeId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: _kAccentLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          size: 17, color: _kAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.mainText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kTextHead)),
                          if (s.secondaryText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(s.secondaryText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _kTextMuted)),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.north_west_rounded,
                        size: 14, color: _kTextMuted),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Web Map Panel
// ─────────────────────────────────────────────────────────────────────────────
class _WebMapPanel extends StatelessWidget {
  final LatLng pickedLatLng;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final bool isOutsideZone;
  final bool hasCityBoundary;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng) onTap;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  const _WebMapPanel({
    required this.pickedLatLng,
    required this.markers,
    required this.circles,
    required this.isOutsideZone,
    required this.hasCityBoundary,
    required this.onMapCreated,
    required this.onTap,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        initialCameraPosition:
        CameraPosition(target: pickedLatLng, zoom: 13),
        markers:               markers,
        circles:               circles,
        onMapCreated:          onMapCreated,
        onTap:                 onTap,
        zoomControlsEnabled:   false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled:     false,
        // ✅ FIX: Web pe EagerGestureRecognizer
        gestureRecognizers: kIsWeb
            ? <Factory<OneSequenceGestureRecognizer>>{
          Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
        }
            : <Factory<OneSequenceGestureRecognizer>>{},
      ),

      // ✅ FIX: Prominent outside warning overlay on map itself
      if (isOutsideZone)
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            color: Colors.red.withValues(alpha: 0.88),
            child: const Row(children: [
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠ Pin is OUTSIDE the city zone boundary! '
                      'Move it inside the blue circle.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ),

      // Status chip — top left
      Positioned(
        top: isOutsideZone ? 48 : 16,
        left: 16,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          _MapChip(
            label:     isOutsideZone
                ? '🔴 Outside city zone'
                : '✅ Tap or drag pin',
            isWarning: isOutsideZone,
          ),
          if (hasCityBoundary) ...[
            const SizedBox(height: 6),
            _MapChip(
              label:       '● City zone boundary',
              isWarning:   false,
              textColor:   const Color(0xFF2563EB),
              borderColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
            ),
          ],
        ]),
      ),

      // Zoom controls — bottom right
      Positioned(
        bottom: 24, right: 16,
        child: Column(children: [
          _MapIconBtn(icon: Icons.add_rounded,    onTap: onZoomIn),
          const SizedBox(height: 6),
          _MapIconBtn(icon: Icons.remove_rounded, onTap: onZoomOut),
          const SizedBox(height: 6),
          _MapIconBtn(
              icon: Icons.my_location_rounded, onTap: onRecenter),
        ]),
      ),

      // Coordinate badge — bottom left
      Positioned(
        bottom: 24, left: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.93),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isOutsideZone
                    ? Colors.red.withValues(alpha: 0.4)
                    : _kBorder),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isOutsideZone
                  ? Icons.location_off_rounded
                  : Icons.gps_fixed_rounded,
              size: 12,
              color: isOutsideZone ? _kError : _kAccent,
            ),
            const SizedBox(width: 6),
            Text(
              '${pickedLatLng.latitude.toStringAsFixed(5)}, '
                  '${pickedLatLng.longitude.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isOutsideZone ? _kError : _kTextHead,
                fontFamily: 'monospace',
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile Map Card
// ─────────────────────────────────────────────────────────────────────────────
class _MobileMapCard extends StatelessWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng) onTap;
  final bool hasCityBoundary;
  final bool isOutside;

  const _MobileMapCard({
    required this.initialPosition,
    required this.markers,
    required this.circles,
    required this.onMapCreated,
    required this.onTap,
    required this.hasCityBoundary,
    required this.isOutside,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      // ✅ FIX: Taller when outside so warning banner fits
      height: isOutside ? 256 : 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        // ✅ FIX: Red border when outside
        border: isOutside
            ? Border.all(color: Colors.red.shade400, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isOutside
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isOutside ? 16 : 18),
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: initialPosition, zoom: 13),
            markers:               markers,
            circles:               circles,
            onMapCreated:          onMapCreated,
            onTap:                 onTap,
            zoomControlsEnabled:   false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled:     false,
          ),

          // ✅ FIX: Red banner at top of map when outside
          if (isOutside)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                color: Colors.red.withValues(alpha: 0.90),
                child: const Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pin is OUTSIDE the city zone!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]),
              ),
            ),

          Positioned(
            top: isOutside ? 42 : 10,
            right: 10,
            child: _MapChip(
              label:     isOutside ? '🔴 Outside zone' : '✅ Tap or drag pin',
              isWarning: isOutside,
            ),
          ),
          if (hasCityBoundary)
            Positioned(
              top: isOutside ? 42 : 10,
              left: 10,
              child: _MapChip(
                label:       '● City zone',
                isWarning:   false,
                textColor:   const Color(0xFF2563EB),
                borderColor:
                const Color(0xFF2563EB).withValues(alpha: 0.3),
              ),
            ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _MapChip extends StatelessWidget {
  final String label;
  final bool isWarning;
  final Color? textColor;
  final Color? borderColor;
  const _MapChip({
    required this.label, required this.isWarning,
    this.textColor, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ??
        (isWarning ? const Color(0xFFEF4444) : _kAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: borderColor ?? color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8),
        ],
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}

class _MapIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: _kTextHead),
      ),
    );
  }
}

class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBarWidget({
    super.key,   // ✅ key forward kiya (GlobalKey support)
    required this.controller, required this.focusNode,
    required this.isLoading,  required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
              key: ValueKey('l'), width: 18, height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _kAccent))
              : const Icon(Icons.search_rounded,
              key: ValueKey('s'), size: 20, color: _kAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller, focusNode: focusNode,
            onChanged: onChanged,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _kTextHead),
            decoration: const InputDecoration(
              hintText: 'Search for a place or address…',
              hintStyle:
              TextStyle(fontSize: 13, color: _kTextMuted),
              border: InputBorder.none, isDense: true,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: controller.text.isNotEmpty ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 15, color: _kTextMuted),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SearchTipBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(children: [
        Icon(Icons.tips_and_updates_rounded,
            size: 16, color: Color(0xFF059669)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Search a location inside the city zone. '
                'Selecting fills the map, coordinates and address.',
            style: TextStyle(
                fontSize: 11,
                color: Color(0xFF065F46),
                height: 1.5),
          ),
        ),
      ]),
    );
  }
}

// ✅ FIX: _OutsideBoundaryBanner now accepts a custom message
class _OutsideBoundaryBanner extends StatelessWidget {
  final VoidCallback onReset;
  final String message;
  const _OutsideBoundaryBanner({
    required this.onReset,
    this.message = 'Move the pin inside the blue circle to save.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.red.shade50, Colors.orange.shade50]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.red.shade100, shape: BoxShape.circle),
          child: Icon(Icons.location_off_rounded,
              size: 14, color: Colors.red.shade700),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Outside City Zone',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade800)),
            const SizedBox(height: 2),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Move the pin inside the blue circle to save.',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade700,
                  height: 1.4),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onReset,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
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
      ]),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _kTextHead),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13,
            color: _kTextMuted,
            fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 18, color: _kAccent),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: _kAccent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: _kError, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: _kError, width: 1.5)),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;
  const _SaveButton({
    required this.isLoading,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isDisabled ? Colors.red.shade400 : _kAccent,
          disabledBackgroundColor: isDisabled
              ? Colors.red.shade400
              : _kAccent.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDisabled
                  ? Icons.block_rounded
                  : Icons.save_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isDisabled
                  ? '⚠ Outside City Zone — Cannot Save'
                  : 'Save Changes',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}