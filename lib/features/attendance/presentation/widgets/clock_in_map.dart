// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/location_status.dart';
import '../../domain/entities/office_entity.dart';

/// Peta clock-in: marker kantor (oranye) + lingkaran radius semi-transparan,
/// dan marker posisi user (biru) yang ikut bergerak saat lokasi diperbarui.
/// Tile dari OpenStreetMap — tidak memerlukan API key atau billing.
class ClockInMap extends StatefulWidget {
  final OfficeEntity office;
  final LocationStatus? location;

  const ClockInMap({super.key, required this.office, this.location});

  @override
  State<ClockInMap> createState() => _ClockInMapState();
}

class _ClockInMapState extends State<ClockInMap> {
  late final MapController _controller;

  LatLng get _officeLatLng =>
      LatLng(widget.office.latitude, widget.office.longitude);

  LatLng? get _userLatLng => widget.location == null
      ? null
      : LatLng(widget.location!.userLatitude, widget.location!.userLongitude);

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  @override
  void didUpdateWidget(covariant ClockInMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Geser kamera mengikuti posisi user setiap kali lokasi diperbarui.
    final user = _userLatLng;
    if (user != null && widget.location != oldWidget.location) {
      _controller.move(user, _controller.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inside = widget.location?.isWithinOfficeRadius ?? true;
    final radiusColor =
        inside ? AppColors.insideRadius : AppColors.outsideRadius;
    final userLatLng = _userLatLng;

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: _officeLatLng,
        initialZoom: 15.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // Wajib untuk OSM usage policy.
          userAgentPackageName: 'com.smartattendance.smart_attendance',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: _officeLatLng,
              radius: widget.office.radiusMeters.toDouble(),
              useRadiusInMeter: true,
              color: radiusColor.withValues(alpha: 0.15),
              borderColor: radiusColor.withValues(alpha: 0.7),
              borderStrokeWidth: 2,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _officeLatLng,
              width: 48,
              height: 48,
              child: Tooltip(
                message:
                    '${widget.office.name} • radius ${widget.office.radiusMeters} m',
                child: const Icon(
                  Icons.location_pin,
                  color: AppColors.safetyOrange,
                  size: 40,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                ),
              ),
            ),
            if (userLatLng != null)
              Marker(
                point: userLatLng,
                width: 40,
                height: 40,
                child: Tooltip(
                  message: AppStrings.mapYourPosition,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 32,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
