
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_edit.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_zone_list_view_model.dart';
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

  LatLng? _cityCenter;
  double? _cityRadiusKm;
  void _setCityZone(double lat, double lng, double radiusKm) {
    _cityCenter = LatLng(lat, lng);
    _cityRadiusKm = radiusKm;

    setState(() {});
  }

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
      final cityVM = Provider.of<CityZoneListViewModel>(context, listen: false);
      if (hvm.hubZones.isEmpty) {
        hvm.getHubZoneListDataApi(context).then((_) async {
          await cityVM.getCityZoneDataApi(context);
          final city = cityVM.cityZoneDataModel?.data?.first;
          if (city != null && city.lat != null && city.long != null && city.radiuskm != null) {
            _setCityZone(double.parse(city.lat!), double.parse(city.long!), double.parse(city.radiuskm!));
          }
          _buildMapOverlays(hvm.hubZones);

          if (hvm.hubZones.isNotEmpty && hvm.hubZones.first.hasValidCoordinates) {
            _onZoneTap(hvm.hubZones.first);
          }
          _fabController.forward();
        });
      } else {
        Future.wait([
          hvm.getHubZoneListDataApi(context),
          cityVM.getCityZoneDataApi(context),
        ]).then((_) {
          final city = cityVM.cityZoneDataModel?.data?.first;
          if (city != null && city.lat != null && city.long != null && city.radiuskm != null) {
            _setCityZone(double.parse(city.lat!), double.parse(city.long!), double.parse(city.radiuskm!));
          }
          _buildMapOverlays(hvm.hubZones);
          if (hvm.hubZones.isNotEmpty && hvm.hubZones.first.hasValidCoordinates) {
            _onZoneTap(hvm.hubZones.first);
          }
          _fabController.forward();
        });
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

    /// ✅ CITY ZONE (from separate API)
    if (_cityCenter != null && _cityRadiusKm != null) {
      _circles.add(
        Circle(
          circleId: const CircleId('city_zone'),
          center: _cityCenter!,
          radius: _cityRadiusKm! * 1000,
          fillColor: Colors.blue.withValues(alpha: 0.08),
          strokeColor: Colors.blue.withValues(alpha: 0.6),
          strokeWidth: 2,
        ),
      );
    }

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


  LatLng _cityZoneCenter(HubZoneListData zone) {
    try {
      final lat = double.tryParse(zone.lat?.toString() ?? '');
      final lng = double.tryParse(zone.long?.toString() ?? '');
      if (lat != null && lng != null) return LatLng(lat, lng);
    } catch (_) {}
    return LatLng(zone.latitude, zone.longitude);

  }

  double _cityZoneRadius(HubZoneListData zone) {
    final cityRadius = zone.radiusInKm;
    if (cityRadius > 0) {
      return cityRadius;
    }
    return 5;
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
                      hvm.hubZones.indexOf(_selectedZone!) % _zoneColors.length],
                      onClose: _closeBottomSheet,
                      onEdit: () {
                        final zoneToEdit = _selectedZone!;
                        _closeBottomSheet();
                        Future.delayed(
                          const Duration(milliseconds: 300),
                              () {
                            if (!context.mounted) return;

                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => HubZoneEditScreen(
                                  zone: zoneToEdit,
                                  cityZoneCenter: _cityZoneCenter(zoneToEdit),
                                  cityZoneRadiusKm: _cityZoneRadius(zoneToEdit),
                                ),
                              ),
                            ).then((_) {
                              if (!context.mounted) return;
                              final hubZoneData = Provider.of<HubZoneViewModel>(context, listen: false);
                              hubZoneData.getHubZoneListDataApi(context).then((_) {_buildMapOverlays(hubZoneData.hubZones);
                              });
                            });
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// 🔹 drag handle
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔹 Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: zoneColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.hub_rounded,
                    color: zoneColor, size: 18),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF64748B)),
              )
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 Info Cards (clean grid)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _miniCard(
                  icon: Icons.radar_rounded,
                  label: "Coverage",
                  value:
                  "${zone.radiusInKm.toStringAsFixed(1)} km",
                  color: zoneColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _miniCard(
                  icon: Icons.pin_drop,
                  label: "Pincode",
                  value: zone.pincode?.toString() ?? "N/A",
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// 🔹 Address (full width)
          _miniCard(
            icon: Icons.location_on,
            label: "Address",
            value: zone.address ?? "N/A",
            color: const Color(0xFFEF4444),
            isFull: true,
          ),

          const SizedBox(height: 14),

          AppBtn(
            height: 42,
            borderRadius: 10,
            onTap: onEdit,
            title: "Edit Zone",
            color: zoneColor,
          )
        ],
      ),
    );
  }

  /// 🔥 Mini Card Widget (clean + compact)
  Widget _miniCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFull = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment:
        isFull ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: isFull ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
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

