// Part of: Attendance - Domain

import 'package:equatable/equatable.dart';

/// Lokasi kantor sebagai acuan validasi radius clock-in.
class OfficeEntity extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String address;

  const OfficeEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.address,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    latitude,
    longitude,
    radiusMeters,
    address,
  ];
}
