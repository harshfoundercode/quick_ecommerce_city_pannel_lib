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

  // Guard: prevents map tap while a search-selection is in progress
  bool _isSelectingFromSearch = false;

  // ── City boundary ─────────────────────────────────────────────────────────
  late LatLng _cityCenter;
  late double _cityRadiusKm;

  // ── Selected pin ──────────────────────────────────────────────────────────
  late LatLng _selectedLocation;
  bool _isOutsideBoundary = false;

  // ── Hub radius ────────────────────────────────────────────────────────────
  double _hubRadius = 1.0;
  late TextEditingController _radiusCtrl;

  // ── Address ───────────────────────────────────────────────────────────────
  String _street = '';
  String _city = '';
  String _state = '';
  String _pincode = '';
  bool _addressLoading = false;

  // ── Search ────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<dynamic> _searchResults = [];
  bool _searchLoading = false;
  Timer? _debounce;
  bool _searchResultOutside = false;
  String _searchOutsideMsg = '';

  // ── Overlay dropdown (web) ────────────────────────────────────────────────
  OverlayEntry? _dropdownOverlay;
  final GlobalKey _searchBarKey = GlobalKey();

  // Controls the transparent map blocker
  bool _isDropdownOpen = false;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

  // ─────────────────────────────────────────────────────────────────────────
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
      Future.delayed(const Duration(milliseconds: 800), _fitCityBoundary);
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
          if (mounted) _closeDropdown();
        });
      }
    });
  }

  @override
  void dispose() {
    _removeDropdownOverlay();
    // _mapController?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _radiusCtrl.dispose();
    _slideCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }



  // ── Dropdown open / close ─────────────────────────────────────────────────

  void _openDropdown() {
    if (_searchResults.isEmpty) return;
    if (mounted) setState(() => _isDropdownOpen = true);
    if (kIsWeb) _showDropdownOverlay();
  }

  void _closeDropdown() {
    _removeDropdownOverlay();
    if (mounted) {
      setState(() {
        _searchResults = [];
        _isDropdownOpen = false;
      });
    }
  }

  // ── OverlayEntry helpers (web only) ──────────────────────────────────────

  void _showDropdownOverlay() {
    if (!kIsWeb) return;
    _removeDropdownOverlay();

    final renderBox =
    _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _dropdownOverlay = OverlayEntry(
      builder: (_) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: _WebSearchDropdownList(
            results: List.from(_searchResults),
            onSelect: (placeId, description) {
              _closeDropdown();
              _selectPlace(placeId, description: description);
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

  // ── Camera ────────────────────────────────────────────────────────────────

  // void _fitCityBoundary() {
  //   _mapController?.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //           target: _cityCenter, zoom: _radiusToZoom(_cityRadiusKm)),
  //     ),
  //   );
  // }
  //
  // void _fitHubCoverage() {
  //   _mapController?.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //         target: _selectedLocation,
  //         zoom: _radiusToZoom(_hubRadius),
  //       ),
  //     ),
  //   );
  // }
  void _fitCityBoundary() {
    if (_mapController == null) {
      _ensureMapControllerReady().then((_) {
        if (mounted && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _cityCenter,
                zoom: _radiusToZoom(_cityRadiusKm),
              ),
            ),
          );
        }
      });
      return;
    }

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _cityCenter,
          zoom: _radiusToZoom(_cityRadiusKm),
        ),
      ),
    );
  }

  void _fitHubCoverage() {
    if (_mapController == null) {
      _ensureMapControllerReady().then((_) {
        if (mounted && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _selectedLocation,
                zoom: _radiusToZoom(_hubRadius),
              ),
            ),
          );
        }
      });
      return;
    }

    _mapController!.animateCamera(
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

  // ── Geo helpers ───────────────────────────────────────────────────────────

  Set<Marker> _buildExistingHubMarkers() {
    final hubVM = Provider.of<HubZoneViewModel>(context, listen: false);
    final Set<Marker> markers = {};
    for (final z in hubVM.hubZones) {
      markers.add(
        Marker(
          markerId: MarkerId('existing_label_${z.id}'),
          position: LatLng(
            double.parse(z.latitude.toString()),
            double.parse(z.longitude.toString()),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
          alpha: 0.8,
          infoWindow: InfoWindow(
            title: z.name?.toString() ?? 'Hub Zone',
            snippet: 'Radius: ${z.radiuskm} km | ${z.address ?? ""}',
          ),
          consumeTapEvents: true,
          onTap: () {},
        ),
      );
    }
    return markers;
  }

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
      final c = LatLng(
        double.parse(z.latitude.toString()),
        double.parse(z.longitude.toString()),
      );
      final r = double.parse(z.radiuskm.toString());
      if (_distanceKm(loc, c) < (rad + r)) return true;
    }
    return false;
  }

  // ── Map circles ───────────────────────────────────────────────────────────

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
    final lng = _cityCenter.longitude +
        (point.longitude - _cityCenter.longitude) * ratio;
    return LatLng(lat, lng);
  }

  // ── Markers ───────────────────────────────────────────────────────────────

  Set<Marker> get _markers => {
    Marker(
      markerId: const MarkerId('city_center'),
      position: _cityCenter,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: widget.cityZone?.name?.toString() ?? 'City Zone',
        snippet:
        'City boundary center - Radius: ${_cityRadiusKm.toStringAsFixed(1)} km',
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
      infoWindow: InfoWindow(
        title: 'New Hub Location',
        snippet: _isOutsideBoundary
            ? '⚠️ Outside city boundary'
            : '✓ Valid location\nRadius: ${_hubRadius.toStringAsFixed(1)} km',
      ),
      onDragStart: (_) => debugPrint('Dragging started'),
      onDrag: (pos) {
        if (_isInsideCity(pos)) setState(() => _selectedLocation = pos);
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
    ..._buildExistingHubMarkers(),
  };

  // ── Map tap ───────────────────────────────────────────────────────────────

  Future<void> _onMapTap(LatLng latLng) async {
    // Ignore map taps while a search selection is being processed
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
          orElse: () => results.firstWhere(
                (r) => (r['types'] as List)
                .contains('administrative_area_level_2'),
            orElse: () => results.first,
          ),
        );

        if (best!['address_components'] != null) {
          _parseComponents(best['address_components']);
        }

        for (final r in results) {
          for (final c in (r['address_components'] ?? [])) {
            if ((c['types'] as List).contains('postal_code')) {
              if (mounted) setState(() => _pincode = c['long_name'] ?? '');
              break;
            }
          }
          if (_pincode.isNotEmpty) break;
        }

        if (_street.isEmpty && _city.isEmpty) {
          if (mounted) {
            setState(() => _street = best!['formatted_address'] ?? '');
          }
        }
      }
    } catch (e) {
      debugPrint('_fetchAddress error: $e');
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
          types.contains('sublocality_level_1')) sublocality = long;
      if (types.contains('locality')) locality = long;
      if (types.contains('administrative_area_level_1')) adminArea = long;
      if (types.contains('postal_code')) pincode = long;
    }
    if (mounted) {
      setState(() {
        _street = [streetNumber, route].where((e) => e.isNotEmpty).join(' ');
        _city = [sublocality, locality].where((e) => e.isNotEmpty).join(', ');
        _state = adminArea;
        if (pincode.isNotEmpty) _pincode = pincode;
      });
    }
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
    if (mounted) {
      setState(() {
        _searchResultOutside = false;
        _searchOutsideMsg = '';
      });
    }
    if (q.trim().isEmpty) {
      _closeDropdown();
      return;
    }
    if (mounted) setState(() => _searchLoading = true);
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
        setState(() {
          _searchResults = results;
          _isDropdownOpen = results.isNotEmpty;
        });
        if (results.isNotEmpty) {
          _openDropdown();
        }
      }
    } catch (e) {
      debugPrint('_searchPlaces error: $e');
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIXED _selectPlace:
  //  1. Sets _isSelectingFromSearch = true at the very start
  //  2. Closes dropdown and updates search bar text BEFORE the async call
  //  3. Uses mounted guard after every await
  //  4. Calls setState to update _selectedLocation so map rebuilds marker/circle
  //  5. Awaits a microtask so setState flushes before animateCamera
  //  6. Null-checks _mapController before animating
  //  7. Resets _isSelectingFromSearch in finally after a short delay
  // ─────────────────────────────────────────────────────────────────────────
  // Future<void> _selectPlace(String placeId, {String description = ''}) async {
  //   // Step 1: Lock map taps immediately
  //   _isSelectingFromSearch = true;
  //
  //   // Step 2: Update search bar text and close dropdown synchronously
  //   _closeDropdown();
  //   if (description.isNotEmpty) {
  //     _searchCtrl.text = description;
  //     _searchCtrl.selection = TextSelection.fromPosition(
  //       TextPosition(offset: description.length),
  //     );
  //   }
  //   _searchFocus.unfocus();
  //
  //   try {
  //     // Step 3: Fetch place details
  //     final uri = Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId));
  //     debugPrint('Fetching place details: $uri');
  //
  //     final res = await http.get(uri).timeout(const Duration(seconds: 10));
  //
  //     if (!mounted) return;
  //
  //     debugPrint('Place details status: ${res.statusCode}');
  //     debugPrint('Place details body: ${res.body}');
  //
  //     if (res.statusCode != 200) {
  //       CustomSnackBar.show(
  //         context,
  //         message: 'Failed to load place details (HTTP ${res.statusCode}).',
  //         type: SnackBarType.error,
  //       );
  //       return;
  //     }
  //
  //     final data = jsonDecode(res.body);
  //
  //     // Support both { data: { lat, lng } } and { lat, lng } response shapes
  //     final loc = data['data'] ?? data;
  //     if (loc == null ||
  //         loc['lat'] == null ||
  //         loc['lng'] == null) {
  //       if (mounted) {
  //         CustomSnackBar.show(
  //           context,
  //           message: 'Could not fetch location coordinates.',
  //           type: SnackBarType.error,
  //         );
  //       }
  //       return;
  //     }
  //
  //     final double? parsedLat = double.tryParse(loc['lat'].toString());
  //     final double? parsedLng = double.tryParse(loc['lng'].toString());
  //
  //     if (parsedLat == null || parsedLng == null) {
  //       if (mounted) {
  //         CustomSnackBar.show(
  //           context,
  //           message: 'Invalid coordinates in response.',
  //           type: SnackBarType.error,
  //         );
  //       }
  //       return;
  //     }
  //
  //     final latLng = LatLng(parsedLat, parsedLng);
  //     final bool outside = !_isInsideCity(latLng);
  //
  //     if (outside) {
  //       // Place is outside city boundary
  //       if (mounted) {
  //         setState(() {
  //           _selectedLocation = latLng;
  //           _isOutsideBoundary = true;
  //           _searchResultOutside = true;
  //           _searchOutsideMsg =
  //           'This place is outside the city zone '
  //               '"${widget.cityZone?.name ?? 'boundary'}". '
  //               'Only locations inside the blue circle are allowed.';
  //         });
  //       }
  //       // Still animate camera to show user where the place is
  //       await Future.delayed(const Duration(milliseconds: 50));
  //       if (!mounted) return;
  //       _mapController?.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(target: latLng, zoom: 12.0),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // Check overlap with existing hub zones
  //     if (_checkOverlapWith(latLng, _hubRadius)) {
  //       if (mounted) {
  //         CustomSnackBar.show(
  //           context,
  //           message: 'This location overlaps an existing hub zone!',
  //           type: SnackBarType.error,
  //         );
  //       }
  //       return;
  //     }
  //
  //     // Step 4: Update state — this rebuilds marker + circle on the map
  //     if (mounted) {
  //       setState(() {
  //         _selectedLocation = latLng;
  //         _isOutsideBoundary = false;
  //         _searchResultOutside = false;
  //         _searchOutsideMsg = '';
  //       });
  //     }
  //
  //     // Step 5: Let the setState frame flush before animating camera
  //     await Future.delayed(const Duration(milliseconds: 80));
  //     if (!mounted) return;
  //
  //     // Step 6: Null-safe camera animation
  //     final controller = _mapController;
  //     if (controller == null) {
  //       debugPrint('⚠️ _mapController is null — cannot animate camera');
  //     } else {
  //       await controller.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(target: latLng, zoom: 14.0),
  //         ),
  //       );
  //     }
  //
  //     // Step 7: Fetch reverse-geocoded address for selected location
  //     await _fetchAddress(latLng);
  //   } catch (e, stack) {
  //     debugPrint('_selectPlace error: $e\n$stack');
  //     if (mounted) {
  //       CustomSnackBar.show(
  //         context,
  //         message: 'Failed to load place details. Please try again.',
  //         type: SnackBarType.error,
  //       );
  //     }
  //   } finally {
  //     // Step 8: Release the lock after a small buffer so spurious map taps
  //     //         fired during the animation don't sneak through
  //     Future.delayed(const Duration(milliseconds: 600), () {
  //       _isSelectingFromSearch = false;
  //     });
  //   }
  // }
// ─────────────────────────────────────────────────────────────────────────
// FIXED _selectPlace:
//  1. Sets _isSelectingFromSearch = true at the very start
//  2. Closes dropdown and updates search bar text BEFORE the async call
//  3. Uses mounted guard after every await
//  4. Calls setState to update _selectedLocation so map rebuilds marker/circle
//  5. Awaits a microtask so setState flushes before animateCamera
//  6. Null-checks _mapController before animating
//  7. Resets _isSelectingFromSearch in finally after a short delay
// ─────────────────────────────────────────────────────────────────────────
//   Future<void> _selectPlace(String placeId, {String description = ''}) async {
//     // Step 1: Lock map taps immediately
//     _isSelectingFromSearch = true;
//
//     // Step 2: Update search bar text and close dropdown synchronously
//     _closeDropdown();
//     if (description.isNotEmpty) {
//       _searchCtrl.text = description;
//       _searchCtrl.selection = TextSelection.fromPosition(
//         TextPosition(offset: description.length),
//       );
//     }
//     _searchFocus.unfocus();
//
//     try {
//       // Step 3: Fetch place details
//       final uri = Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId));
//       debugPrint('Fetching place details: $uri');
//
//       final res = await http.get(uri).timeout(const Duration(seconds: 10));
//
//       if (!mounted) return;
//
//       debugPrint('Place details status: ${res.statusCode}');
//       debugPrint('Place details body: ${res.body}');
//
//       if (res.statusCode != 200) {
//         CustomSnackBar.show(
//           context,
//           message: 'Failed to load place details (HTTP ${res.statusCode}).',
//           type: SnackBarType.error,
//         );
//         return;
//       }
//
//       final data = jsonDecode(res.body);
//
//       // Support both { data: { lat, lng } } and { lat, lng } response shapes
//       final loc = data['data'] ?? data;
//       if (loc == null ||
//           loc['lat'] == null ||
//           loc['lng'] == null) {
//         if (mounted) {
//           CustomSnackBar.show(
//             context,
//             message: 'Could not fetch location coordinates.',
//             type: SnackBarType.error,
//           );
//         }
//         return;
//       }
//
//       final double? parsedLat = double.tryParse(loc['lat'].toString());
//       final double? parsedLng = double.tryParse(loc['lng'].toString());
//
//       if (parsedLat == null || parsedLng == null) {
//         if (mounted) {
//           CustomSnackBar.show(
//             context,
//             message: 'Invalid coordinates in response.',
//             type: SnackBarType.error,
//           );
//         }
//         return;
//       }
//
//       final latLng = LatLng(parsedLat, parsedLng);
//       final bool outside = !_isInsideCity(latLng);
//
//       if (outside) {
//         // Place is outside city boundary
//         if (mounted) {
//           setState(() {
//             _selectedLocation = latLng;
//             _isOutsideBoundary = true;
//             _searchResultOutside = true;
//             _searchOutsideMsg =
//             'This place is outside the city zone '
//                 '"${widget.cityZone?.name ?? 'boundary'}". '
//                 'Only locations inside the blue circle are allowed.';
//           });
//         }
//         // Still animate camera to show user where the place is
//         await Future.delayed(const Duration(milliseconds: 50));
//         if (!mounted) return;
//         _mapController?.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(target: latLng, zoom: 12.0),
//           ),
//         );
//         return;
//       }
//
//       // Check overlap with existing hub zones
//       if (_checkOverlapWith(latLng, _hubRadius)) {
//         if (mounted) {
//           CustomSnackBar.show(
//             context,
//             message: 'This location overlaps an existing hub zone!',
//             type: SnackBarType.error,
//           );
//         }
//         return;
//       }
//
//       // Step 4: Update state — this rebuilds marker + circle on the map
//       if (mounted) {
//         setState(() {
//           _selectedLocation = latLng;
//           _isOutsideBoundary = false;
//           _searchResultOutside = false;
//           _searchOutsideMsg = '';
//         });
//       }
//
//       // Step 5: Let the setState frame flush before animating camera
//       await Future.delayed(const Duration(milliseconds: 80));
//       if (!mounted) return;
//
//       // Step 6: Null-safe camera animation
//       final controller = _mapController;
//       if (controller == null) {
//         debugPrint('⚠️ _mapController is null — cannot animate camera');
//       } else {
//         await controller.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(target: latLng, zoom: 14.0),
//           ),
//         );
//       }
//
//       // Step 7: Fetch reverse-geocoded address for selected location
//       await _fetchAddress(latLng);
//     } catch (e, stack) {
//       debugPrint('_selectPlace error: $e\n$stack');
//       if (mounted) {
//         CustomSnackBar.show(
//           context,
//           message: 'Failed to load place details. Please try again.',
//           type: SnackBarType.error,
//         );
//       }
//     } finally {
//       // Step 8: Release the lock after a small buffer so spurious map taps
//       //         fired during the animation don't sneak through
//       Future.delayed(const Duration(milliseconds: 600), () {
//         if (mounted) {
//           _isSelectingFromSearch = false;
//         }
//       });
//     }
//   }
  Future<void> _selectPlace(String placeId, {String description = ''}) async {
    _isSelectingFromSearch = true;

    _closeDropdown();
    if (description.isNotEmpty) {
      _searchCtrl.text = description;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: description.length),
      );
    }
    _searchFocus.unfocus();

    try {
      final uri = Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId));
      debugPrint('Fetching place details: $uri');

      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      debugPrint('Place details status: ${res.statusCode}');
      debugPrint('Place details body: ${res.body}');

      if (res.statusCode != 200) {
        CustomSnackBar.show(
          context,
          message: 'Failed to load place details (HTTP ${res.statusCode}).',
          type: SnackBarType.error,
        );
        return;
      }

      final data = jsonDecode(res.body);
      final loc = data['data'] ?? data;

      if (loc == null || loc['lat'] == null || loc['lng'] == null) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Could not fetch location coordinates.',
            type: SnackBarType.error,
          );
        }
        return;
      }

      final double? parsedLat = double.tryParse(loc['lat'].toString());
      final double? parsedLng = double.tryParse(loc['lng'].toString());

      if (parsedLat == null || parsedLng == null) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Invalid coordinates in response.',
            type: SnackBarType.error,
          );
        }
        return;
      }

      final latLng = LatLng(parsedLat, parsedLng);
      final bool outside = !_isInsideCity(latLng);

      if (outside) {
        if (mounted) {
          setState(() {
            _selectedLocation = latLng;
            _isOutsideBoundary = true;
            _searchResultOutside = true;
            _searchOutsideMsg = 'This place is outside the city zone '
                '"${widget.cityZone?.name ?? 'boundary'}". '
                'Only locations inside the blue circle are allowed.';
          });
        }

        // Wait for map controller to be ready
        await _ensureMapControllerReady();

        if (!mounted) return;

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 12.0),
          ),
        );
        return;
      }

      if (_checkOverlapWith(latLng, _hubRadius)) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'This location overlaps an existing hub zone!',
            type: SnackBarType.error,
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _selectedLocation = latLng;
          _isOutsideBoundary = false;
          _searchResultOutside = false;
          _searchOutsideMsg = '';
        });
      }

      // Wait for map controller to be ready
      await _ensureMapControllerReady();

      if (!mounted) return;

      final controller = _mapController;
      if (controller == null) {
        debugPrint('⚠️ _mapController is null — cannot animate camera');
      } else {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 14.0),
          ),
        );
      }

      await _fetchAddress(latLng);
    } catch (e, stack) {
      debugPrint('_selectPlace error: $e\n$stack');
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to load place details. Please try again.',
          type: SnackBarType.error,
        );
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _isSelectingFromSearch = false;
        }
      });
    }
  }

// Add this helper method
  Future<void> _ensureMapControllerReady() async {
    if (_mapController != null) return;

    try {
      await _mapControllerCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Map controller initialization timeout');
          throw TimeoutException('Map controller not ready');
        },
      );
    } catch (e) {
      debugPrint('Error waiting for map controller: $e');
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

  // ── Build ──────────────────────────────────────────────────────────────────

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
                    child:
                    isWeb ? _buildWebLayout() : _buildMobileLayout(),
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
                const Text(
                  'Select Hub Location',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)),
                ),
                Text(
                  'City Zone: ${widget.cityZone?.name ?? "—"}  •  '
                      'Radius: ${_cityRadiusKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280)),
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
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Color(0xFF374151)),
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
              _buildMapWithBlocker(),
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
        const VerticalDivider(width: 1, color: Color(0xFFE8ECF0)),
        SizedBox(width: 320, child: _buildRightPanel()),
      ],
    );
  }

  // ── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: SizedBox(
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
                    _buildSearchDropdown(
                      onSelect: (placeId, description) {
                        _closeDropdown();
                        _selectPlace(placeId, description: description);
                      },
                    ),
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
                      child: _buildMapWithBlocker(),
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
            _buildMobileBottomPanel(),
          ],
        ),
      ),
    );
  }

  // ── Map + transparent blocker overlay ─────────────────────────────────────
  // GoogleMap is a platform view. AbsorbPointer/IgnorePointer have NO effect
  // on platform views. Solution: a transparent Flutter GestureDetector on top.
  // When _isDropdownOpen is true it intercepts every pointer before the native view.

  Widget _buildMapWithBlocker() {
    return Stack(
      children: [
        _buildGoogleMap(),
        if (_isDropdownOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _closeDropdown();
                _searchFocus.unfocus();
              },
              onPanDown: (_) {},
              onScaleStart: (_) {},
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
      ],
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
        // Ensure map is fully initialized before animating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _fitCityBoundary();
          }
        });
      },
      // Always wire up onTap; the guard inside _onMapTap handles the lock
      onTap: _onMapTap,
      onLongPress: _onMapTap,
      circles: _circles,
      markers: _markers,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      gestureRecognizers: kIsWeb
          ? <Factory<OneSequenceGestureRecognizer>>{
        Factory<PanGestureRecognizer>(
              () => PanGestureRecognizer(),
        ),
        Factory<ScaleGestureRecognizer>(
              () => ScaleGestureRecognizer(),
        ),
        Factory<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
        ),
        Factory<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(),
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
            Column(
              children: [
                _buildSearchBar(key: _searchBarKey),
                // Web dropdown is rendered via OverlayEntry (_showDropdownOverlay)
                // For non-web within the panel show inline dropdown
                if (!kIsWeb && _searchResults.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildSearchDropdown(
                    onSelect: (placeId, description) {
                      _closeDropdown();
                      _selectPlace(placeId, description: description);
                    },
                  ),
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
              letterSpacing: 0.2),
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
          const Icon(Icons.gps_fixed_rounded,
              size: 14, color: ColorConst.primaryGreen),
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
                      letterSpacing: 0.8),
                ),
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
                  strokeWidth: 2, color: ColorConst.primaryGreen),
            ),
            SizedBox(width: 10),
            Text('Fetching address…',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
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
            Icon(Icons.info_outline_rounded,
                size: 14, color: Color(0xFF9CA3AF)),
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
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
                  strokeWidth: 2, color: ColorConst.primaryGreen),
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
                _closeDropdown();
                setState(() {
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

  // ── Inline dropdown (mobile / non-overlay) ────────────────────────────────

  // Widget _buildSearchDropdown(
  //     {required Function(String placeId, String description) onSelect}) {
  //   return Container(
  //     constraints: const BoxConstraints(maxHeight: 200),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: const Color(0xFFE5E7EB)),
  //       boxShadow: [
  //         BoxShadow(
  //             color: Colors.black.withValues(alpha: 0.08),
  //             blurRadius: 16,
  //             offset: const Offset(0, 4)),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(14),
  //       child: ListView.separated(
  //         padding: const EdgeInsets.symmetric(vertical: 6),
  //         shrinkWrap: true,
  //         itemCount: _searchResults.length,
  //         separatorBuilder: (_, __) =>
  //         const Divider(height: 1, color: Color(0xFFE5E7EB)),
  //         itemBuilder: (_, i) {
  //           final place = _searchResults[i];
  //           final desc = place['description'] as String? ?? '';
  //           final parts = desc.split(',');
  //           final main = parts.first.trim();
  //           final sub =
  //           parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
  //           return _SearchResultTile(main: main, sub: sub,
  //             onTap: () => onSelect(place['place_id'], desc),);
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Replace the _SearchResultTile with ListTile in dropdown
  Widget _buildSearchDropdown(
      {required Function(String placeId, String description) onSelect}) {
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
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          itemBuilder: (_, i) {
            final place = _searchResults[i];
            final desc = place['description'] as String? ?? '';
            final parts = desc.split(',');
            final main = parts.first.trim();
            final sub =
            parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

            return ListTile(
              dense: true,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded,
                    size: 16, color: ColorConst.primaryGreen),
              ),
              title: Text(main,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              subtitle: sub.isNotEmpty ? Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF))) : null,
              trailing: const Icon(Icons.north_west_rounded,
                  size: 13, color: Color(0xFF9CA3AF)),
              onTap: () => onSelect(place['place_id'], desc),
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
                _searchCtrl.clear();
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

// ── Web overlay dropdown ──────────────────────────────────────────────────────

class _WebSearchDropdownList extends StatelessWidget {
  final List<dynamic> results;
  final Function(String placeId, String description) onSelect;

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
              offset: const Offset(0, 6)),
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
            return _SearchResultTile(main: main, sub: sub,
              onTap: () => onSelect(place['place_id'], desc),);
          },
        ),
      ),
    );
  }
}

// ── Shared tile ───────────────────────────────────────────────────────────────

class _SearchResultTile extends StatelessWidget {
  final String main;
  final String sub;
  final VoidCallback? onTap; // Add onTap callback

  const _SearchResultTile({
    required this.main,
    required this.sub,
    this.onTap, // Make it optional for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              const Icon(Icons.north_west_rounded,
                  size: 13, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

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
    final color = isWarning ? Colors.red.shade600 : ColorConst.primaryGreen;
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
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