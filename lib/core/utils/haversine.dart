// Part of: Core - Utils

import 'dart:math' as math;

/// Jarak permukaan bumi antara dua koordinat (lat/lon dalam derajat),
/// dikembalikan dalam meter. Dipakai untuk memvalidasi apakah posisi user
/// berada dalam radius kantor saat clock-in.
///
/// Rumus Haversine:
///   a = sin²(Δlat/2) + cos(lat1)·cos(lat2)·sin²(Δlon/2)
///   d = 2R · arcsin(√a),  R = 6.371.000 m (radius rata-rata bumi)
double calculateDistanceMeters(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusMeters = 6371000.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final c = 2 * math.asin(math.min(1.0, math.sqrt(a)));
  return earthRadiusMeters * c;
}

double _toRadians(double degrees) => degrees * math.pi / 180.0;
