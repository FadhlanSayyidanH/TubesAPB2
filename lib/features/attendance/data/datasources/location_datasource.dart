// Part of: Attendance - Data

import 'dart:async';

// geolocator mengekspor LocationServiceDisabledException-nya sendiri; kita
// sembunyikan agar tidak bentrok dengan versi domain di core/errors.
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;

import '../../../../core/errors/exceptions.dart';

/// Pembungkus tipis di atas geolocator: mengurus izin & status layanan,
/// lalu mengembalikan posisi. Melempar Exception spesifik agar repository bisa
/// memetakan ke pesan yang tepat (GPS mati / izin ditolak / timeout).
abstract class LocationDataSource {
  Future<Position> getCurrentPosition();
}

class LocationDataSourceImpl implements LocationDataSource {
  final GeolocatorPlatform _geolocator;

  LocationDataSourceImpl(this._geolocator);

  @override
  Future<Position> getCurrentPosition() async {
    if (!await _geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    await _ensurePermission();

    try {
      return await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw const LocationTimeoutException();
    }
  }

  Future<void> _ensurePermission() async {
    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }
  }
}
