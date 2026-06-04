// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/location_status.dart';
import '../../domain/entities/office_entity.dart';

/// Peta clock-in: marker kantor (oranye) + lingkaran radius semi-transparan,
/// dan marker posisi user (biru) yang ikut bergerak saat lokasi diperbarui.
class ClockInMap extends StatefulWidget {
  final OfficeEntity office;
  final LocationStatus? location;

  const ClockInMap({super.key, required this.office, this.location});

  @override
  State<ClockInMap> createState() => _ClockInMapState();
}

class _ClockInMapState extends State<ClockInMap> {
  GoogleMapController? _controller;

  LatLng get _officeLatLng =>
      LatLng(widget.office.latitude, widget.office.longitude);

  LatLng? get _userLatLng => widget.location == null
      ? null
      : LatLng(widget.location!.userLatitude, widget.location!.userLongitude);

  @override
  void didUpdateWidget(covariant ClockInMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Geser kamera mengikuti posisi user setiap kali lokasi diperbarui.
    final user = _userLatLng;
    if (user != null && widget.location != oldWidget.location) {
      _controller?.animateCamera(CameraUpdate.newLatLng(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final inside = widget.location?.isWithinOfficeRadius ?? true;
    final radiusColor = inside
        ? AppColors.insideRadius
        : AppColors.outsideRadius;

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _officeLatLng, zoom: 15.5),
      onMapCreated: (controller) => _controller = controller,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('office'),
          position: _officeLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: widget.office.name,
            snippet: 'Radius ${widget.office.radiusMeters} m',
          ),
        ),
        if (_userLatLng != null)
          Marker(
            markerId: const MarkerId('user'),
            position: _userLatLng!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(title: AppStrings.mapYourPosition),
          ),
      },
      circles: {
        Circle(
          circleId: const CircleId('office_radius'),
          center: _officeLatLng,
          radius: widget.office.radiusMeters.toDouble(),
          fillColor: radiusColor.withValues(alpha: 0.12),
          strokeColor: radiusColor.withValues(alpha: 0.6),
          strokeWidth: 2,
        ),
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
