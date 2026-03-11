import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'dart:math';

import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_model_list.dart';


class HubZoneMapPopup extends StatefulWidget {
  final VoidCallback onEdit;
  final HubZoneListData zone;

  const HubZoneMapPopup({
    super.key,
    required this.onEdit, required this.zone,
  });

  @override
  State<HubZoneMapPopup> createState() => _HubZoneMapPopupState();
}

class _HubZoneMapPopupState extends State<HubZoneMapPopup> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {};

  bool _isMapReady = false;
  double _currentZoom = 12.0;
  bool _showGrid = false;
  bool _showHeatMap = false;

  // Colors for different radius indicators
  final List<Color> _radiusColors = [
    Colors.blue.withOpacity(0.1),
    Colors.green.withOpacity(0.1),
    Colors.orange.withOpacity(0.1),
    Colors.red.withOpacity(0.1),
    Colors.purple.withOpacity(0.1),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() {
    final center = LatLng(widget.zone.latitude, widget.zone.longitude);
    final radiusInMeters = double.parse(widget.zone.radiuskm.toString()) * 1000; // Convert km to meters

    // 1. Main Hub Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('hub_center'),
        position: center,
        infoWindow: InfoWindow(
          title: widget.zone.name,
          snippet: 'Coverage: ${widget.zone.radiuskm} km',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // 2. Main Coverage Radius Circle (Primary)
    _circles.add(
      Circle(
        circleId: const CircleId('coverage_radius_main'),
        center: center,
        radius: radiusInMeters.toDouble(),
        fillColor: ColorConst.primaryGreen.withOpacity(0.15),
        strokeColor: ColorConst.primaryGreen,
        strokeWidth: 3,
      ),
    );

    // 3. Inner Circle (50% radius)
    _circles.add(
      Circle(
        circleId: const CircleId('coverage_radius_inner'),
        center: center,
        radius: radiusInMeters * 0.5,
        fillColor: Colors.transparent,
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );

    // 4. Outer Circle (150% radius - buffer zone)
    _circles.add(
      Circle(
        circleId: const CircleId('coverage_radius_outer'),
        center: center,
        radius: radiusInMeters * 1.5,
        fillColor: Colors.transparent,
        strokeColor: Colors.orange,
        strokeWidth: 2,
      ),
    );

    // 5. Direction Markers (North, East, South, West points on radius)
    _addDirectionMarkers(center, radiusInMeters);

    // 6. Grid Lines for better visualization
    _addGridLines(center, radiusInMeters);

    // 7. Sample Points within radius (to show coverage)
    _addSamplePoints(center, radiusInMeters);

    // 8. Polygon for heat map effect (if enabled)
    _addHeatMapPolygon(center, radiusInMeters);
  }

  void _addDirectionMarkers(LatLng center, double radius) {
    const directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final point = _calculateOffset(center, radius, angles[i] * pi / 180);

      _markers.add(
        Marker(
          markerId: MarkerId('direction_${directions[i]}'),
          position: point,
          infoWindow: InfoWindow(
            title: '${directions[i]} Point',
            snippet: '${widget.zone.radiuskm} km from center',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          draggable: false,
        ),
      );
    }
  }

  void _addGridLines(LatLng center, double radius) {
    // Horizontal and vertical lines through center
    for (int i = -1; i <= 1; i += 2) {
      for (int j = -1; j <= 1; j += 2) {
        final point1 = _calculateOffset(center, radius * 0.7, atan2(i.toDouble(), j.toDouble()));
        final point2 = _calculateOffset(center, radius * 1.3, atan2(i.toDouble(), j.toDouble()));

        _polylines.add(
          Polyline(
            polylineId: PolylineId('grid_$i$j'),
            points: [point1, point2],
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        );
      }
    }
  }

  void _addSamplePoints(LatLng center, double radius) {
    final random = Random();

    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius;
      final point = _calculateOffset(center, distance, angle);

      // Determine if point is within radius
      final isWithinRadius = distance <= radius;

      _markers.add(
        Marker(
          markerId: MarkerId('sample_$i'),
          position: point,
          infoWindow: InfoWindow(
            title: isWithinRadius ? 'Within Coverage' : 'Outside Coverage',
            snippet: '${(distance / 1000).toStringAsFixed(2)} km from center',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isWithinRadius ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
  }

  void _addHeatMapPolygon(LatLng center, double radius) {
    final List<LatLng> polygonPoints = [];
    final steps = 36; // Number of points to create smooth circle

    for (int i = 0; i <= steps; i++) {
      final angle = (i * 2 * pi / steps);
      final point = _calculateOffset(center, radius, angle);
      polygonPoints.add(point);
    }

    _polygons.add(
      Polygon(
        polygonId: const PolygonId('heat_map'),
        points: polygonPoints,
        fillColor: Colors.red.withOpacity(0.05),
        strokeColor: Colors.transparent,
        strokeWidth: 0,
      ),
    );
  }

  LatLng _calculateOffset(LatLng center, double distanceInMeters, double angle) {
    const earthRadius = 6371000; // meters

    final lat1 = center.latitude * pi / 180;
    final lon1 = center.longitude * pi / 180;

    final lat2 = asin(sin(lat1) * cos(distanceInMeters / earthRadius) +
        cos(lat1) * sin(distanceInMeters / earthRadius) * cos(angle));

    final lon2 = lon1 + atan2(
        sin(angle) * sin(distanceInMeters / earthRadius) * cos(lat1),
        cos(distanceInMeters / earthRadius) - sin(lat1) * sin(lat2)
    );

    return LatLng(lat2 * 180 / pi, lon2 * 180 / pi);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: Sizes.screenWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with controls
            _buildHeader(),

            // Map View
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.zone.latitude, widget.zone.longitude),
                      zoom: 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      setState(() => _isMapReady = true);
                    },
                    onCameraMove: (position) {
                      _currentZoom = position.zoom;
                    },
                    markers: _markers,
                    circles: _circles,
                    polygons: _polygons,
                    polylines: _polylines,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    buildingsEnabled: true,
                    trafficEnabled: false,
                  ),

                  if (!_isMapReady)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                  // Zoom Controls Overlay
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      children: [
                        _buildZoomButton(
                          icon: Icons.add_rounded,
                          onPressed: () => _mapController.animateCamera(
                            CameraUpdate.zoomIn(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildZoomButton(
                          icon: Icons.remove_rounded,
                          onPressed: () => _mapController.animateCamera(
                            CameraUpdate.zoomOut(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Info Panel
            _buildInfoPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.map_rounded,
              color: ColorConst.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.zone.name.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat: ${widget.zone.latitude.toStringAsFixed(6)}, Lng: ${widget.zone.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(width: 12),

          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }


  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ColorConst.primaryGreen, size: 24),
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Radius Information
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Coverage Radius',
                  value: '${widget.zone.radiuskm} km',
                  icon: Icons.radio_button_unchecked,
                  color: ColorConst.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Total Area',
                  value: '${(pi * pow(widget.zone.radiusInKm, 2)).toStringAsFixed(2)} km²',
                  icon: Icons.square_foot_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Buffer Zone',
                  value: '${(double.parse(widget.zone.radiusInKm.toString()) * 1.5).toStringAsFixed(1)} km',
                  icon: Icons.security_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Legend
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Hub Center', ColorConst.primaryGreen, Icons.location_on_rounded),
                _buildLegendItem('Coverage Area', ColorConst.primaryGreen.withOpacity(0.15), Icons.circle_rounded),
                _buildLegendItem('Inner Zone', Colors.blue, Icons.circle_outlined),
                _buildLegendItem('Buffer Zone', Colors.orange, Icons.remove),
                _buildLegendItem('Direction Points', Colors.blue, Icons.navigation_rounded),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              // Fit to Bounds
              Expanded(
                child: _buildActionButton(
                  icon: Icons.fit_screen_rounded,
                  label: 'Fit to Bounds',
                  onPressed: _fitToBounds,
                ),
              ),
              const SizedBox(width: 12),

              // Center View
              Expanded(
                child: _buildActionButton(
                  icon: Icons.center_focus_strong_rounded,
                  label: 'Center View',
                  onPressed: _centerView,
                ),
              ),
              const SizedBox(width: 12),

              // Edit Button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit Zone',
                  color: ColorConst.primaryGreen,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onEdit();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: icon == Icons.circle_rounded ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: icon == Icons.circle_outlined ? Border.all(color: color, width: 2) : null,
          ),
          child: icon == Icons.remove
              ? Icon(Icons.circle_outlined, size: 14, color: color)
              : (icon == Icons.navigation_rounded
              ? Icon(icon, size: 12, color: color)
              : null),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: (color ?? Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (color ?? Colors.grey).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color ?? Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color ?? Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fitToBounds() {
    final center = LatLng(widget.zone.latitude, widget.zone.longitude);
    final radiusInMeters = widget.zone.radiusInKm * 1000;

    // Calculate bounds that include the entire radius
    final deltaLat = (radiusInMeters / 111000) * 1.5; // 1 degree lat ≈ 111 km
    final deltaLng = (radiusInMeters / (111000 * cos(center.latitude * pi / 180))) * 1.5;

    final bounds = LatLngBounds(
      southwest: LatLng(center.latitude - deltaLat, center.longitude - deltaLng),
      northeast: LatLng(center.latitude + deltaLat, center.longitude + deltaLng),
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _centerView() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.zone.latitude, widget.zone.longitude),
          zoom: 12,
        ),
      ),
    );
  }
}