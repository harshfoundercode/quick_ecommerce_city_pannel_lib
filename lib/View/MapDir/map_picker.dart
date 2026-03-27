import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';



class MapPickerPopup extends StatefulWidget {
  final Data? cityZone;
  const MapPickerPopup({super.key, this.cityZone, });

  @override
  State<MapPickerPopup> createState() => _MapPickerPopupState();
}

class _MapPickerPopupState extends State<MapPickerPopup>
    with SingleTickerProviderStateMixin {

  // ── Map controller ─────────────────────────────────────────────────────────
  GoogleMapController? _mapController;

  // ── City boundary (from profile zone) ─────────────────────────────────────
  late LatLng  _cityCenter;
  late double  _cityRadiusKm;

  // ── Selected hub pin ────────────────────────────────────────────────────────
  late LatLng _selectedLocation;
  bool        _isOutsideBoundary = false;

  // ── Hub coverage radius ────────────────────────────────────────────────────
  double _hubRadius = 1.0; // km
  late TextEditingController _radiusCtrl;

  // ── Address ────────────────────────────────────────────────────────────────
  String _street  = '';
  String _city    = '';
  String _state   = '';
  String _pincode = '';
  bool   _addressLoading = false;

  // ── Search ─────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl  = TextEditingController();
  final FocusNode              _searchFocus = FocusNode();
  List<dynamic> _searchResults = [];
  bool          _searchLoading = false;
  Timer?        _debounce;

  final String _apiKey = ApiUrl.mapKey;

  // ── Entry animation ────────────────────────────────────────────────────────
  late AnimationController _slideCtrl;
  late Animation<double>   _slideAnim;

  // ── Init ───────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Parse city zone from profile API
    _cityCenter = LatLng(
      double.tryParse(widget.cityZone?.lat?.toString() ?? '26.8467') ?? 26.8467,
      double.tryParse(widget.cityZone?.long?.toString() ?? '80.9462') ?? 80.9462,
    );
    _cityRadiusKm =
        double.tryParse(widget.cityZone?.radiuskm?.toString() ?? '10') ?? 10.0;

    // Default hub pin = city center
    _selectedLocation = _cityCenter;

    _hubRadius = (_hubRadius).clamp(0.5, _cityRadiusKm);
    _radiusCtrl = TextEditingController(
        text: _hubRadius.toStringAsFixed(1));

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnim = CurvedAnimation(
        parent: _slideCtrl, curve: Curves.easeOutCubic);
    _slideCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAddress(_selectedLocation);
      // Fit camera to city boundary on first load
      Future.delayed(const Duration(milliseconds: 500), _fitCityBoundary);
      Future.microtask(() {
        Provider.of<HubZoneViewModel>(context, listen: false)
            .getHubZoneListDataApi(context);
      });
    });

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _searchResults = []);
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

  // ── Camera helpers ─────────────────────────────────────────────────────────

  /// Fits the camera so the entire city boundary circle is visible.
  void _fitCityBoundary() {
    if (_mapController == null) return;
    final zoom = _radiusToZoom(_cityRadiusKm);
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _cityCenter, zoom: zoom),
      ),
    );
  }

  /// Fits the camera so the hub coverage circle is fully visible.
  void _fitHubCoverage() {
    if (_mapController == null) return;
    final zoom = _radiusToZoom(_hubRadius);
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedLocation, zoom: zoom),
      ),
    );
  }

  /// Converts a radius in km to an approximate Google Maps zoom level.
  double _radiusToZoom(double radiusKm) {
    // At zoom 1 the whole world is visible (~20000 km radius equivalent).
    // Each zoom level halves the visible area.
    // zoom = log2(earthCircumference / (radiusKm * 2 * pi * scaleFactor))
    // Empirical: zoom ≈ 14 - log2(radiusKm / 0.5)
    const double base = 14.0;
    final double delta = log(radiusKm / 0.5) / log(2);
    return (base - delta).clamp(3.0, 18.0);
  }

  // ── Distance helper ────────────────────────────────────────────────────────

  /// Haversine distance in km between two LatLng points.
  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude  - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final sinDLat = sin(dLat / 2);
    final sinDLon = sin(dLon / 2);
    final x = sinDLat * sinDLat +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sinDLon * sinDLon;
    return r * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  double _deg2rad(double deg) => deg * pi / 180;

  bool _isInsideCity(LatLng point) =>
      _distanceKm(point, _cityCenter) <= _cityRadiusKm;

  bool _isOverlapping() {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);

    for (var zone in hubVM.hubZones) {
      final existingCenter = LatLng(
        double.parse(zone.latitude.toString()),
        double.parse(zone.longitude.toString()),
      );

      final existingRadius =
      double.parse(zone.radiuskm.toString());

      double distance = _distanceKm(_selectedLocation, existingCenter);

      if (distance < (_hubRadius + existingRadius)) {
        return true;
      }
    }

    return false;
  }
  // ── Overlays ───────────────────────────────────────────────────────────────

  // Set<Circle> get _circles {
  //   final outside = _isOutsideBoundary;
  //   return {
  //     // City boundary — always shown
  //     Circle(
  //       circleId: const CircleId('city_boundary'),
  //       center:      _cityCenter,
  //       radius:      _cityRadiusKm * 1000,
  //       fillColor:   const Color(0xFF2563EB).withOpacity(0.06),
  //       strokeColor: outside
  //           ? Colors.red.withOpacity(0.7)
  //           : const Color(0xFF2563EB).withOpacity(0.5),
  //       strokeWidth: outside ? 3 : 2,
  //     ),
  //     // Hub coverage circle
  //     Circle(
  //       circleId: const CircleId('hub_coverage'),
  //       center:      _selectedLocation,
  //       radius:      _hubRadius * 1000,
  //       fillColor:   outside
  //           ? Colors.red.withOpacity(0.10)
  //           : ColorConst.primaryGreen.withOpacity(0.12),
  //       strokeColor: outside
  //           ? Colors.red.withOpacity(0.6)
  //           : ColorConst.primaryGreen.withOpacity(0.7),
  //       strokeWidth: 2,
  //     ),
  //   };
  // }

  Set<Circle> get _circles {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);

    Set<Circle> allCircles = {

      /// 🔵 City boundary (existing)
      Circle(
        circleId: const CircleId('city_boundary'),
        center: _cityCenter,
        radius: _cityRadiusKm * 1000,
        fillColor: const Color(0xFF2563EB).withOpacity(0.06),
        strokeColor: _isOutsideBoundary
            ? Colors.red.withOpacity(0.7)
            : const Color(0xFF2563EB).withOpacity(0.5),
        strokeWidth: _isOutsideBoundary ? 3 : 2,
      ),

      /// 🟢 Current hub
      Circle(
        circleId: const CircleId('hub_coverage'),
        center: _selectedLocation,
        radius: _hubRadius * 1000,
        fillColor: _isOutsideBoundary
            ? Colors.red.withOpacity(0.10)
            : ColorConst.primaryGreen.withOpacity(0.12),
        strokeColor: _isOutsideBoundary
            ? Colors.red.withOpacity(0.6)
            : ColorConst.primaryGreen.withOpacity(0.7),
        strokeWidth: 2,
      ),
    };

    /// 🔴 ADD EXISTING HUB ZONES
    for (var zone in hubVM.hubZones) {
      allCircles.add(
        Circle(
          circleId: CircleId("existing_${zone.id}"),
          center: LatLng(
            double.parse(zone.latitude.toString()),
            double.parse(zone.longitude.toString()),
          ),
          radius: double.parse(zone.radiuskm.toString()) * 1000,
          fillColor: Colors.red.withOpacity(0.12),
          strokeColor: Colors.red.withOpacity(0.6),
          strokeWidth: 2,
        ),
      );
    }

    return allCircles;
  }

  Set<Marker> get _markers => {
    // City center marker (smaller, blue)
    Marker(
      markerId: const MarkerId('city_center'),
      position: _cityCenter,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: widget.cityZone?.name?.toString() ?? 'City Zone',
        snippet: 'City boundary center',
      ),
      alpha: 0.7,
    ),
    // Hub pin (main)
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

  // ── Map tap ────────────────────────────────────────────────────────────────

  // Future<void> _onMapTap(LatLng latLng) async {
  //   final outside = !_isInsideCity(latLng);
  //   setState(() {
  //     _selectedLocation    = latLng;
  //     _isOutsideBoundary   = outside;
  //   });
  //   _fetchAddress(latLng);
  //   _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  // }

  bool _checkOverlapWithNewLocation(LatLng newLocation) {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);

    for (var zone in hubVM.hubZones) {
      final existingCenter = LatLng(
        double.parse(zone.latitude.toString()),
        double.parse(zone.longitude.toString()),
      );

      final existingRadius =
      double.parse(zone.radiuskm.toString());

      double distance = _distanceKm(newLocation, existingCenter);

      if (distance < (_hubRadius + existingRadius)) {
        return true;
      }
    }

    return false;
  }
  Future<void> _onMapTap(LatLng latLng) async {
    final outside = !_isInsideCity(latLng);

    /// 🔥 CHECK OVERLAP ON LOCATION CHANGE
    final isOverlap = _checkOverlapWithNewLocation(latLng);

    if (isOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This location overlaps existing hub!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedLocation = latLng;
      _isOutsideBoundary = outside;
    });

    _fetchAddress(latLng);
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  // ── Address ────────────────────────────────────────────────────────────────

  Future<void> _fetchAddress(LatLng latLng) async {
    setState(() => _addressLoading = true);
    try {
      final marks = await placemarkFromCoordinates(
          latLng.latitude, latLng.longitude);
      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        setState(() {
          _street  = _joinParts([p.name, p.street]);
          _city    = _joinParts([p.subLocality, p.locality]);
          _state   = p.administrativeArea ?? '';
          _pincode = p.postalCode ?? '';
        });
      }
    } catch (_) {}
    finally {
      if (mounted) setState(() => _addressLoading = false);
    }
  }

  String _joinParts(List<String?> parts) =>
      parts.where((p) => p != null && p.isNotEmpty).join(', ');

  String get _fullAddress => [
    if (_street.isNotEmpty)  _street,
    if (_city.isNotEmpty)    _city,
    if (_state.isNotEmpty)   _state,
    if (_pincode.isNotEmpty) _pincode,
  ].join(', ');

  // ── Search ─────────────────────────────────────────────────────────────────

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) { setState(() => _searchResults = []); return; }
    setState(() => _searchLoading = true);
    _debounce = Timer(const Duration(milliseconds: 450),
            () => _searchPlaces(q));
  }

  Future<void> _searchPlaces(String q) async {
    try {
      final res = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeComponent(q)}&key=$_apiKey'
            '&language=en&components=country:IN',
      ));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _searchResults = data['predictions'] ?? []);
      }
    } catch (_) {}
    finally { if (mounted) setState(() => _searchLoading = false); }
  }

  Future<void> _selectPlace(String placeId) async {
    FocusScope.of(context).unfocus();
    setState(() { _searchResults = []; _searchCtrl.clear(); });
    try {
      final res  = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId&key=$_apiKey&fields=geometry',
      ));
      final data = jsonDecode(res.body);
      final loc  = data['result']['geometry']['location'];
      final latLng = LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble());

      final outside = !_isInsideCity(latLng);
      setState(() {
        _selectedLocation  = latLng;
        _isOutsideBoundary = outside;
      });
      await _fetchAddress(latLng);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 14)),
      );
    } catch (_) {}
  }

  // ── Radius slider ──────────────────────────────────────────────────────────

  // void _onRadiusSlider(double val) {
  //   setState(() {
  //     _hubRadius = val;
  //     _radiusCtrl.text = val.toStringAsFixed(1);
  //   });
  //   // Zoom map to fit the new hub radius
  //   _fitHubCoverage();
  // }


  void _onRadiusField(String val) {
    final parsed = double.tryParse(val);

    if (parsed != null && parsed >= 0.5 && parsed <= _cityRadiusKm) {

      final isOverlap = _checkOverlapWithRadius(parsed);

      if (isOverlap) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This radius overlaps existing hub!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _hubRadius = parsed;
      });

      _fitHubCoverage();
    }
  }

  void _onRadiusSlider(double val) {
    final newRadius = val;

    /// 🔥 CHECK OVERLAP BEFORE APPLY
    final isOverlap = _checkOverlapWithRadius(newRadius);

    if (isOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Radius increase will overlap another hub!"),
          backgroundColor: Colors.red,
        ),
      );
      return; // ❌ block change
    }

    setState(() {
      _hubRadius = newRadius;
      _radiusCtrl.text = newRadius.toStringAsFixed(1);
    });

    _fitHubCoverage();
  }

  // void _onRadiusField(String val) {
  //   final parsed = double.tryParse(val);
  //   if (parsed != null && parsed >= 0.5 && parsed <= _cityRadiusKm) {
  //     setState(() => _hubRadius = parsed);
  //     _fitHubCoverage();
  //   }
  // }

  bool _checkOverlapWithRadius(double testRadius) {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);

    for (var zone in hubVM.hubZones) {
      final existingCenter = LatLng(
        double.parse(zone.latitude.toString()),
        double.parse(zone.longitude.toString()),
      );

      final existingRadius =
      double.parse(zone.radiuskm.toString());

      double distance = _distanceKm(_selectedLocation, existingCenter);

      if (distance < (testRadius + existingRadius)) {
        return true;
      }
    }

    return false;
  }
  // ── Confirm ────────────────────────────────────────────────────────────────

  void _confirm() {
    if (_isOutsideBoundary) return; // blocked — button is disabled too

    if (_isOverlapping()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hub overlaps with existing zone!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pop(context, {
      'lat':     _selectedLocation.latitude,
      'lng':     _selectedLocation.longitude,
      'address': _fullAddress,
      'pincode': _pincode,
      'radius':  _hubRadius,
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: sw > 700 ? (sw - 680) / 2 : 12,
        vertical: 20,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(_slideAnim),
        child: FadeTransition(
          opacity: _slideAnim,
          child: Container(
            width: 680,
            height: sh * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(children: [

                // ── Header ─────────────────────────────────────────────
                _buildHeader(),

                // ── City zone info strip ───────────────────────────────
                _buildZoneStrip(),

                // ── Search ─────────────────────────────────────────────
                _buildSearchBar(),

                // ── Search results ─────────────────────────────────────
                if (_searchResults.isNotEmpty) _buildSearchDropdown(),

                // ── Map ────────────────────────────────────────────────
                Expanded(child: _buildMap()),

                // ── Bottom panel ───────────────────────────────────────
                _buildBottomPanel(),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.map_rounded,
              size: 18, color: ColorConst.primaryGreen),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Hub Location',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827))),
              Text('Hub must be inside the city boundary',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded,
                size: 18, color: Color(0xFF374151)),
          ),
        ),
      ]),
    );
  }

  // ── City zone strip ────────────────────────────────────────────────────────

  Widget _buildZoneStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF2563EB).withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_city_rounded,
              size: 14, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF374151)),
              children: [
                const TextSpan(
                    text: 'City Zone: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(
                    text: widget.cityZone?.name?.toString() ?? '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB))),
                TextSpan(
                    text:
                    '  •  Radius: ${_cityRadiusKm.toStringAsFixed(1)} km'),
              ],
            ),
          ),
        ),
        // Fit to boundary button
        GestureDetector(
          onTap: _fitCityBoundary,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fit_screen_rounded,
                    size: 12, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text('Fit Zone',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB))),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Out-of-boundary warning ────────────────────────────────────────────────

  Widget _buildOutsideWarning() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded,
            size: 16, color: Colors.red.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This location is outside the city boundary. '
                'Move the pin inside the blue circle to continue.',
            style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              _selectedLocation  = _cityCenter;
              _isOutsideBoundary = false;
            });
            _mapController?.animateCamera(
                CameraUpdate.newLatLng(_cityCenter));
            await _fetchAddress(_cityCenter);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
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
      ]),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _searchLoading
                ? const SizedBox(
                key: ValueKey('load'),
                width: 15, height: 15,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorConst.primaryGreen))
                : const Icon(Icons.search_rounded,
                key: ValueKey('icon'),
                size: 18,
                color: ColorConst.primaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode:  _searchFocus,
              onChanged:  _onSearchChanged,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Search a place or landmark…',
                hintStyle: TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _searchResults = []);
              },
              child: Container(
                width: 26, height: 26,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 13, color: Color(0xFF6B7280)),
              ),
            ),
        ]),
      ),

      // Out-of-boundary warning (only when needed)
      if (_isOutsideBoundary) _buildOutsideWarning(),
    ]);
  }

  // ── Search dropdown ────────────────────────────────────────────────────────

  Widget _buildSearchDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
          separatorBuilder: (_, __) => const Divider(
              height: 1, color: Color(0xFFE5E7EB)),
          itemBuilder: (_, i) {
            final place = _searchResults[i];
            final desc  = place['description'] as String? ?? '';
            final parts = desc.split(',');
            final main  = parts.first.trim();
            final sub   = parts.length > 1
                ? parts.sublist(1).join(',').trim()
                : '';
            return InkWell(
              onTap: () => _selectPlace(place['place_id']),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: ColorConst.primaryGreen
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: ColorConst.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                ]),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Map ────────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return Stack(children: [
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _cityCenter,
          zoom: _radiusToZoom(_cityRadiusKm),
        ),
        onMapCreated: (c) { _mapController = c; },
        onTap: _onMapTap,
        circles: _circles,
        markers: _markers,
        zoomControlsEnabled:     false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled:       false,
      ),

      // Hint chip
      Positioned(
        top: 12, left: 12,
        child: _HintChip(
          label: _isOutsideBoundary
              ? '⚠ Outside boundary'
              : 'Tap inside the blue circle',
          isWarning: _isOutsideBoundary,
        ),
      ),

      // Zoom controls
      Positioned(
        bottom: 16, right: 12,
        child: Column(children: [
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
        ]),
      ),
    ]);
  }

  // ── Bottom panel ───────────────────────────────────────────────────────────

  Widget _buildBottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
        Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // ── Radius row ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.radar_rounded,
                  size: 15, color: ColorConst.primaryGreen),
            ),
            const SizedBox(width: 8),
            const Text('Hub Coverage Radius',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            const Spacer(),
            // Editable radius input
            SizedBox(
              width: 78, height: 34,
              child: TextField(
                controller: _radiusCtrl,
                keyboardType: const TextInputType
                    .numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]')),
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
                      horizontal: 8, vertical: 8),
                  suffixText: 'km',
                  suffixStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: ColorConst.primaryGreen
                      .withOpacity(0.07),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ]),
        ),

        // Slider — zooms map as it moves
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor:   ColorConst.primaryGreen,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor:         ColorConst.primaryGreen,
            overlayColor:
            ColorConst.primaryGreen.withOpacity(0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 7),
          ),
          child: Slider(
            value:     _hubRadius.clamp(0.5, _cityRadiusKm),
            min:       0.5,
            max:       _cityRadiusKm,
            divisions: ((_cityRadiusKm - 0.5) * 2).round().clamp(1, 199),
            onChanged: _onRadiusSlider,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children:  [
              Text('0.5 km',
                  style: TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF))),
              Text('${_cityRadiusKm.toStringAsFixed(1)} km (max)',
                  style: TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // ── Address ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _addressLoading
              ? Row(children: const [
            SizedBox(
              width: 13, height: 13,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorConst.primaryGreen),
            ),
            SizedBox(width: 8),
            Text('Fetching address…',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF))),
          ])
              : _buildAddressRows(),
        ),

        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // ── Confirm row ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(children: [
            // Coordinates chip
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text('COORDINATES',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.6)),
                    const SizedBox(height: 3),
                    Text(
                      '${_selectedLocation.latitude.toStringAsFixed(5)}, '
                          '${_selectedLocation.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Confirm button — disabled + red tint when outside
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed:
                _isOutsideBoundary ? null : _confirm,
                icon: Icon(
                  _isOutsideBoundary
                      ? Icons.block_rounded
                      : Icons.check_rounded,
                  size: 18,
                ),
                label: Text(
                  _isOutsideBoundary
                      ? 'Outside Boundary'
                      : 'Confirm Location',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOutsideBoundary
                      ? Colors.red.shade400
                      : ColorConst.primaryGreen,
                  disabledBackgroundColor:
                  Colors.red.shade400,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAddressRows() {
    if (_street.isEmpty && _city.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded,
              size: 14, color: Color(0xFF9CA3AF)),
          SizedBox(width: 8),
          Text('Tap inside the blue circle to pick a location',
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF9CA3AF))),
        ]),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: street + city
        Expanded(
          child: Column(children: [
            if (_street.isNotEmpty)
              _AddrTile(
                icon: Icons.signpost_rounded,
                color: ColorConst.primaryGreen,
                label: 'Street',
                value: _street,
              ),
            if (_street.isNotEmpty) const SizedBox(height: 6),
            if (_city.isNotEmpty)
              _AddrTile(
                icon: Icons.location_city_rounded,
                color: const Color(0xFF2563EB),
                label: 'City',
                value: _city,
              ),
          ]),
        ),
        const SizedBox(width: 10),
        // Right: state + pincode
        Expanded(
          child: Column(children: [
            if (_state.isNotEmpty)
              _AddrTile(
                icon: Icons.map_outlined,
                color: const Color(0xFFD97706),
                label: 'State',
                value: _state,
              ),
            if (_state.isNotEmpty && _pincode.isNotEmpty)
              const SizedBox(height: 6),
            if (_pincode.isNotEmpty)
              _AddrTile(
                icon: Icons.pin_rounded,
                color: const Color(0xFFF472B6),
                label: 'Pincode',
                value: _pincode,
              ),
          ]),
        ),
      ],
    );
  }
}

// ─── Small widgets ────────────────────────────────────────────────────────────

class _HintChip extends StatelessWidget {
  final String label;
  final bool   isWarning;
  const _HintChip({required this.label, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final color =
    isWarning ? Colors.red.shade600 : ColorConst.primaryGreen;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
            isWarning
                ? Icons.warning_amber_rounded
                : Icons.touch_app_rounded,
            size: 12, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color)),
      ]),
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
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 18,
            color: const Color(0xFF374151)),
      ),
    );
  }
}

class _AddrTile extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;
  const _AddrTile({
    required this.icon, required this.color,
    required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: color.withOpacity(0.18)),
      ),
      child: Row(children: [
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
      ]),
    );
  }
}