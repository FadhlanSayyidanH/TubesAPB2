// Part of: Attendance - Domain

import 'package:equatable/equatable.dart';

/// Hasil pengecekan posisi user terhadap kantor pada satu titik waktu.
/// Dipakai widget indikator (Dalam/Luar Area) dan gerbang clock-in.
class LocationStatus extends Equatable {
  final double userLatitude;
  final double userLongitude;
  final double distanceMeters;
  final bool isWithinOfficeRadius;

  const LocationStatus({
    required this.userLatitude,
    required this.userLongitude,
    required this.distanceMeters,
    required this.isWithinOfficeRadius,
  });

  /// Jarak yang enak dibaca: "120 m" atau "1,4 km".
  String get readableDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  @override
  List<Object?> get props => [
    userLatitude,
    userLongitude,
    distanceMeters,
    isWithinOfficeRadius,
  ];
}
