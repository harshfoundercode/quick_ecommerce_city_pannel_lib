import 'dart:async';
import 'dart:convert';
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
const _kCard        = Colors.white;
const _kBorder      = Color(0xFFE2E8F0);
const _kTextHead    = Color(0xFF1E293B);
const _kTextMuted   = Color(0xFF94A3B8);
const _kSuccess     = Color(0xFF10B981);
const _kError       = Color(0xFFEF4444);

// ─── Model for a Places suggestion ───────────────────────────────────────────
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

// ─── Screen ───────────────────────────────────────────────────────────────────
class HubZoneEditScreen extends StatefulWidget {
  final HubZoneListData zone;
  const HubZoneEditScreen({super.key, required this.zone});

  @override
  State<HubZoneEditScreen> createState() => _HubZoneEditScreenState();
}

class _HubZoneEditScreenState extends State<HubZoneEditScreen>
    with SingleTickerProviderStateMixin {

  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _radiusCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;

  // ── Search ────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final LayerLink _layerLink  = LayerLink();
  OverlayEntry? _overlayEntry;

  List<_PlaceSuggestion> _suggestions  = [];
  bool _searchLoading = false;
  Timer? _debounce;

  // ── Map ───────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  late LatLng _pickedLatLng;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  // ── Scroll ────────────────────────────────────────────────────────────────
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
    _updateMapOverlays();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _radiusCtrl.addListener(_updateMapOverlays);

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) _removeOverlay();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    _radiusCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _mapController?.dispose();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  // ─── Map ──────────────────────────────────────────────────────────────────

  void _updateMapOverlays() {
    final radius =
        (double.tryParse(_radiusCtrl.text) ?? widget.zone.radiusInKm) * 1000;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('edit_pin'),
          position: _pickedLatLng,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet),
          onDragEnd: _onLocationPicked,
        ),
      };
      _circles = {
        Circle(
          circleId: const CircleId('edit_circle'),
          center:      _pickedLatLng,
          radius:      radius,
          fillColor:   _kAccent.withValues(alpha: 0.15),
          strokeColor: _kAccent.withValues(alpha: 0.7),
          strokeWidth: 2,
        ),
      };
    });
  }

  void _onLocationPicked(LatLng pos) {
    _pickedLatLng    = pos;
    _latCtrl.text    = pos.latitude.toStringAsFixed(6);
    _lngCtrl.text    = pos.longitude.toStringAsFixed(6);
    _updateMapOverlays();
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
  }

  // ─── Places Autocomplete ──────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query.trim());
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    setState(() => _searchLoading = true);
    try {
      final uri = Uri.parse(ApiUrl.mapPlaceAutoCompleteUrl(Uri.encodeComponent(input)));
      final res = await http.get(uri);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final preds = (json['data'] as List).map((p) => _PlaceSuggestion(
          placeId:       p['place_id'],
          mainText:      p['structured_formatting']['main_text'],
          secondaryText: p['structured_formatting']
          ['secondary_text'] ??
              '',
        ))
            .toList();
        setState(() => _suggestions = preds);
        if (preds.isNotEmpty) _showOverlay();
      }
    } catch (_) {
      // silently fail — user can still use manual coords / map tap
    } finally {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  Future<void> _fetchPlaceDetails(String placeId) async {
    _removeOverlay();
    FocusScope.of(context).unfocus();

    try {
      final uri = Uri.parse(ApiUrl.mapPlaceDetailsUrl(placeId));
      final res = await http.get(uri);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        double lat = 0;
        double lng = 0;
        String address = '';
        String pincode = '';

        /// ✅ CASE 1: Your backend structured response
        if (json['data'] != null && json['data'] is Map) {
          final data = json['data'];

          /// 🔹 Shape A: direct lat/lng
          if (data['lat'] != null && data['lng'] != null) {
            lat = (data['lat'] as num).toDouble();
            lng = (data['lng'] as num).toDouble();
            address = data['address']?.toString() ?? '';
          }

          /// 🔹 Shape B: Google-like nested
          else if (data['geometry'] != null) {
            final loc = data['geometry']['location'];
            lat = (loc['lat'] as num).toDouble();
            lng = (loc['lng'] as num).toDouble();
            address = data['formatted_address'] ?? '';

            /// Extract pincode
            if (data['address_components'] != null) {
              for (final comp in data['address_components']) {
                final types = List<String>.from(comp['types'] ?? []);
                if (types.contains('postal_code')) {
                  pincode = comp['long_name'];
                  break;
                }
              }
            }
          }
        }

        /// ✅ CASE 2: Raw Google API response
        else if (json['results'] != null &&
            json['results'] is List &&
            json['results'].isNotEmpty) {
          final result = json['results'][0];

          final loc = result['geometry']['location'];
          lat = (loc['lat'] as num).toDouble();
          lng = (loc['lng'] as num).toDouble();
          address = result['formatted_address'] ?? '';

          /// Extract pincode
          for (final comp in result['address_components']) {
            final types = List<String>.from(comp['types'] ?? []);
            if (types.contains('postal_code')) {
              pincode = comp['long_name'];
              break;
            }
          }
        }

        /// ❌ If still invalid
        if (lat == 0 && lng == 0) {
          throw Exception("Invalid location data");
        }

        /// ✅ APPLY DATA
        _onLocationPicked(LatLng(lat, lng));
        _addressCtrl.text = address;

        if (pincode.isNotEmpty) {
          _pincodeCtrl.text = pincode;
        }

        _searchCtrl.text = address;

        _showLocationAppliedSnack(address);
      }
    } catch (e) {
      debugPrint("PlaceDetails ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch location details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLocationAppliedSnack(String addr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Location updated',
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        backgroundColor: _kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Overlay dropdown ─────────────────────────────────────────────────────

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (_) => _buildDropdown());
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdown() {
    return Positioned(
      width: MediaQuery.of(context).size.width - 32,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 58),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: _kCard,
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
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: _kBorder),
                itemBuilder: (_, i) {
                  final s = _suggestions[i];
                  return InkWell(
                    onTap: () => _fetchPlaceDetails(s.placeId),
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
                                    color: _kTextHead,
                                  )),
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final hubZone = Provider.of<HubZoneEditViewModel>(context,listen: false);
    hubZone.editZoneApi(
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HubZoneEditViewModel(),
      child: Scaffold(
        backgroundColor: _kBg,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Consumer<HubZoneEditViewModel>(
            builder: (context, evm, _) {
              return CustomScrollView(
                controller: _scrollCtrl,
                slivers: [

                  // ── AppBar ──────────────────────────────────────────────
                  SliverAppBar(
                    expandedHeight: 56,
                    pinned: true,
                    backgroundColor: _kCard,
                    elevation: 0,
                    surfaceTintColor: _kCard,
                    leading: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: _kTextHead),
                      ),
                    ),
                    title: const Text('Edit Hub Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kTextHead,
                        )),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kAccentLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('ID #${widget.zone.id}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kAccent,
                            )),
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

                          // ── SECTION: Search location ──────────────────
                          _SectionLabel(
                            icon: Icons.search_rounded,
                            label: 'Search Location',
                            subtitle:
                            'Search a place to auto-fill map & address',
                          ),

                          // ── Search bar ────────────────────────────────
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: CompositedTransformTarget(
                              link: _layerLink,
                              child: _SearchBar(
                                controller: _searchCtrl,
                                focusNode: _searchFocus,
                                isLoading: _searchLoading,
                                onChanged: _onSearchChanged,
                                onClear: () {
                                  _searchCtrl.clear();
                                  _removeOverlay();
                                  setState(() => _suggestions = []);
                                },
                              ),
                            ),
                          ),

                          // ── Search tip banner (shown only when
                          //    suggestions empty & field focused) ─────────
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _suggestions.isEmpty &&
                                _searchCtrl.text.isEmpty
                                ? _SearchTipBanner()
                                : const SizedBox.shrink(),
                          ),

                          // ── SECTION: Map & coverage ───────────────────
                          _SectionLabel(
                            icon: Icons.map_rounded,
                            label: 'Location & Coverage',
                            subtitle:
                            'Tap map or drag the pin to fine-tune',
                          ),

                          // ── Map ───────────────────────────────────────
                          _MapPickerCard(
                            key: ValueKey(_pickedLatLng),
                            initialPosition: _pickedLatLng,
                            markers: _markers,
                            circles: _circles,
                            onMapCreated: (c) => _mapController = c,
                            onTap: _onLocationPicked,
                          ),

                          // ── Coords + radius ───────────────────────────
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Row(children: [
                              Expanded(
                                child: _EditField(
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
                                  onChanged: (_) {
                                    final lat =
                                    double.tryParse(_latCtrl.text);
                                    final lng =
                                    double.tryParse(_lngCtrl.text);
                                    if (lat != null && lng != null) {
                                      _onLocationPicked(LatLng(lat, lng));
                                    }
                                  },
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _EditField(
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
                                  onChanged: (_) {
                                    final lat =
                                    double.tryParse(_latCtrl.text);
                                    final lng =
                                    double.tryParse(_lngCtrl.text);
                                    if (lat != null && lng != null) {
                                      _onLocationPicked(LatLng(lat, lng));
                                    }
                                  },
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _EditField(
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
                                    if (v == null || v.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(v) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ]),
                          ),

                          // ── SECTION: Zone details ─────────────────────
                          _SectionLabel(
                            icon: Icons.hub_rounded,
                            label: 'Zone Details',
                            subtitle:
                            'Basic information about this hub zone',
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 15),
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
                                  if (v == null || v.isEmpty) {
                                    return 'Pincode is required';
                                  }
                                  if (v.length != 6) {
                                    return 'Must be 6 digits';
                                  }
                                  return null;
                                },
                              ),
                            ]),
                          ),

                          const SizedBox(height: 32),

                          // ── Save button ───────────────────────────────
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              MediaQuery.of(context).padding.bottom + 24,
                            ),
                            child: _SaveButton(
                              isLoading: evm.editZoneLoading,
                              onTap: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        // Animated search / loading icon
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
            key: ValueKey('loading'),
            width: 18, height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _kAccent),
          )
              : const Icon(Icons.search_rounded,
              key: ValueKey('search'), size: 20, color: _kAccent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kTextHead,
            ),
            decoration: const InputDecoration(
              hintText: 'Search for a place, landmark, or address…',
              hintStyle: TextStyle(
                  fontSize: 13, color: _kTextMuted),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        // Clear button
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

// ─── Search tip banner ────────────────────────────────────────────────────────

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
      child: Row(children: [
        const Icon(Icons.tips_and_updates_rounded,
            size: 16, color: Color(0xFF059669)),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Type a location name, landmark or full address. '
                'Selecting a suggestion will auto-fill the map pin, '
                'coordinates and address fields.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF065F46),
              height: 1.5,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Map Picker Card ──────────────────────────────────────────────────────────

class _MapPickerCard extends StatelessWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng) onTap;

  const _MapPickerCard({
    super.key,
    required this.initialPosition,
    required this.markers,
    required this.circles,
    required this.onMapCreated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: initialPosition, zoom: 13),
            markers: markers,
            circles: circles,
            onMapCreated: onMapCreated,
            onTap: onTap,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Hint chip
          Positioned(
            top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 13, color: _kAccent),
                  SizedBox(width: 4),
                  Text('Tap or drag pin',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _kAccent,
                      )),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kAccentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: _kAccent),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kTextHead,
              )),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: _kTextMuted)),
        ]),
      ]),
    );
  }
}

// ─── Edit Field ───────────────────────────────────────────────────────────────

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
        color: _kTextHead,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13, color: _kTextMuted, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 18, color: _kAccent),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kError, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Save Button ──────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SaveButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          disabledBackgroundColor: _kAccent.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22, height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, size: 20),
            SizedBox(width: 8),
            Text('Save Changes',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}