
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_edit.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';

class HubZoneMapScreen extends StatefulWidget {
  const HubZoneMapScreen({super.key});

  @override
  State<HubZoneMapScreen> createState() => _HubZoneMapScreenState();
}

class _HubZoneMapScreenState extends State<HubZoneMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  HubZoneListData? _selectedZone;
  late AnimationController _bottomSheetController;
  late Animation<double> _bottomSheetAnimation;
  late AnimationController _fabController;

  final List<Color> _zoneColors = [
    const Color(0xFF6366F1),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
  ];

  @override
  void initState() {
    super.initState();

    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bottomSheetAnimation = CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeOutCubic,
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hvm = Provider.of<HubZoneViewModel>(context, listen: false);
      if (hvm.hubZones.isEmpty) {
        hvm.getHubZoneListDataApi(context).then((_) {
          _buildMapOverlays(hvm.hubZones);
          if (hvm.hubZones.isNotEmpty && hvm.hubZones.first.hasValidCoordinates) {
            _onZoneTap(hvm.hubZones.first);
          }
          _fabController.forward();
        });
      } else {
        _buildMapOverlays(hvm.hubZones);
        if (hvm.hubZones.isNotEmpty && hvm.hubZones.first.hasValidCoordinates) {
          _onZoneTap(hvm.hubZones.first);
        }
        _fabController.forward();
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _bottomSheetController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _buildMapOverlays(List<HubZoneListData> zones) {
    _markers.clear();
    _circles.clear();

    for (int i = 0; i < zones.length; i++) {
      final zone = zones[i];
      if (!zone.hasValidCoordinates) continue;

      final color    = _zoneColors[i % _zoneColors.length];
      final position = LatLng(zone.latitude, zone.longitude);

      _circles.add(Circle(
        circleId: CircleId('circle_${zone.id}'),
        center:      position,
        radius:      zone.radiusInKm * 1000,
        fillColor:   color.withValues(alpha: 0.15),
        strokeColor: color.withValues(alpha: 0.7),
        strokeWidth: 2,
      ));

      _markers.add(Marker(
        markerId:    MarkerId('marker_${zone.id}'),
        position:    position,
        icon:        BitmapDescriptor.defaultMarkerWithHue(_colorToHue(color)),
        infoWindow:  InfoWindow(title: zone.name.toString()),
        onTap:       () => _onZoneTap(zone),
      ));
    }

    setState(() {});
  }

  double _colorToHue(Color color) => HSLColor.fromColor(color).hue;

  void _onZoneTap(HubZoneListData zone) {
    setState(() => _selectedZone = zone);
    _bottomSheetController.forward();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(zone.latitude, zone.longitude),
          zoom:   _radiusToZoom(zone.radiusInKm),
        ),
      ),
    );
  }

  double _radiusToZoom(double radiusKm) =>
      (14 - math.log(radiusKm) / math.log(2)).clamp(8.0, 16.0);

  void _closeBottomSheet() {
    _bottomSheetController.reverse().then((_) {
      setState(() => _selectedZone = null);
    });
  }

  void _fitAllZones(List<HubZoneListData> zones) {
    if (zones.isEmpty) return;
    final valid = zones.where((z) => z.hasValidCoordinates).toList();
    if (valid.isEmpty) return;

    double minLat = valid.first.latitude, maxLat = valid.first.latitude;
    double minLng = valid.first.longitude, maxLng = valid.first.longitude;
    for (final z in valid) {
      if (z.latitude  < minLat) minLat = z.latitude;
      if (z.latitude  > maxLat) maxLat = z.latitude;
      if (z.longitude < minLng) minLng = z.longitude;
      if (z.longitude > maxLng) maxLng = z.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.05, minLng - 0.05),
          northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
        ),
        80,
      ),
    );
  }

  // ── FIX: helper to safely parse city-zone boundary from the zone model ──────
  // Adjust the field names below to match your actual HubZoneListData model.
  // Common patterns: zone.cityZoneLat, zone.cityzone?.lat, zone.cityzonelat, etc.
  // LatLng _cityZoneCenter(HubZoneListData zone) {
  //   try {
  //     final lat = double.tryParse(zone.lat?.toString() ?? '');
  //     final lng = double.tryParse(zone.long?.toString() ?? '');
  //     if (lat != null && lng != null) return LatLng(lat, lng);
  //     print(zone.latitude);
  //     print(zone.longitude);
  //     print("sdguyvdu");
  //   } catch (_) {}
  //   // Fallback: use hub location itself (boundary check will be skipped gracefully)
  //   return LatLng(zone.latitude, zone.longitude);
  //
  // }

  LatLng _cityZoneCenter(HubZoneListData zone) {
    final lat = zone.latitude;
    final lng = zone.longitude;

    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return LatLng(zone.latitude, zone.longitude);
  }

  double _cityZoneRadius(HubZoneListData zone) {
    // ❌ NEVER use hub radius here
    // Instead use city radius from API (if available)

    final cityRadius = zone.radiusInKm; // <-- CHECK YOUR MODEL

    if (cityRadius != null && cityRadius > 0) {
      return cityRadius;
    }

    // TEMP FIX (so circle always shows)
    return 5; // 5 km default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Consumer<HubZoneViewModel>(
        builder: (context, hvm, _) {
          return Stack(
            children: [
              // ── Google Map ────────────────────────────────────────────────
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(26.8467, 80.9462),
                  zoom: 11,
                ),
                markers: _markers,
                circles: _circles,
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (hvm.hubZones.isNotEmpty) _buildMapOverlays(hvm.hubZones);
                },
                onTap: (_) => _closeBottomSheet(),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // ── Loading overlay ───────────────────────────────────────────
              if (hvm.isLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.6),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: ColorConst.primaryGreen),
                  ),
                ),

              // ── AppBar ────────────────────────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hub_rounded,
                            color: ColorConst.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Hub Zones Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorConst.primaryExtraLightGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${hvm.hubZones.length} zones',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorConst.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Legend chips ──────────────────────────────────────────────
              if (!hvm.isLoading && hvm.hubZones.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 75,
                  left: 16,
                  right: 16,
                  child: _buildLegendChips(hvm.hubZones),
                ),

              // ── Fit all FAB ───────────────────────────────────────────────
              Positioned(
                right: 16,
                bottom: _selectedZone != null ? 280 : 100,
                child: ScaleTransition(
                  scale: _fabController,
                  child: _MapButton(
                    icon: Icons.fit_screen_rounded,
                    onTap: () => _fitAllZones(hvm.hubZones),
                    tooltip: 'Fit all zones',
                  ),
                ),
              ),

              // ── Bottom Detail Sheet ───────────────────────────────────────
              if (_selectedZone != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _bottomSheetAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, (1 - _bottomSheetAnimation.value) * 260),
                      child: child,
                    ),
                    child: _ZoneDetailSheet(
                      zone: _selectedZone!,
                      zoneColor: _zoneColors[
                      hvm.hubZones.indexOf(_selectedZone!) %
                          _zoneColors.length],
                      onClose: _closeBottomSheet,

                      // ── FIX: Corrected Navigator call ─────────────────────
                      onEdit: () {
                        final zoneToEdit = _selectedZone!;
                        print(_selectedZone?.radiusInKm);
                        print(_selectedZone?.long);
                        print(_selectedZone?.lat);
                        print("evduwve");
                        _closeBottomSheet();
                        Future.delayed(
                          const Duration(milliseconds: 300),
                              () {
                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HubZoneEditScreen(
                                  zone: zoneToEdit,
                                  cityZoneCenter: _cityZoneCenter(zoneToEdit),
                                  cityZoneRadiusKm: _cityZoneRadius(zoneToEdit),
                                ),
                              ),
                            ).then((_) {
                              if (!context.mounted) return;
                              final hubZoneData = Provider.of<HubZoneViewModel>(
                                  context,
                                  listen: false);
                              hubZoneData
                                  .getHubZoneListDataApi(context)
                                  .then((_) {
                                _buildMapOverlays(hubZoneData.hubZones);
                              });
                            });
                            print("evduwve");
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendChips(List<HubZoneListData> zones) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(zones.length, (i) {
          final zone      = zones[i];
          final color     = _zoneColors[i % _zoneColors.length];
          final isSelected = _selectedZone?.id == zone.id;
          return GestureDetector(
            onTap: () => _onZoneTap(zone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: color, width: isSelected ? 0 : 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    zone.name.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Floating map button ───────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _MapButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1E293B)),
        ),
      ),
    );
  }
}

// ── Bottom Detail Sheet ───────────────────────────────────────────────────────

class _ZoneDetailSheet extends StatelessWidget {
  final HubZoneListData zone;
  final Color zoneColor;
  final VoidCallback onClose;
  final VoidCallback onEdit;

  const _ZoneDetailSheet({
    required this.zone,
    required this.zoneColor,
    required this.onClose,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = zone.status == 1 || zone.status == HubZoneStatus.active;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: zoneColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                  Icon(Icons.hub_rounded, color: zoneColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 16),

          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFEF4444),
                  label: 'Address',
                  value: zone.address?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.radar_rounded,
                        iconColor: zoneColor,
                        label: 'Coverage',
                        value: '${zone.radiusInKm.toStringAsFixed(1)} km',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.pin_drop_rounded,
                        iconColor: const Color(0xFF6366F1),
                        label: 'Pincode',
                        value: zone.pincode?.toString() ?? 'N/A',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.grid_view_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Zone ID',
                        value: '#${zone.cityzoneid}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Edit button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text(
                  'Edit Hub Zone',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: zoneColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info widgets ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B))),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}