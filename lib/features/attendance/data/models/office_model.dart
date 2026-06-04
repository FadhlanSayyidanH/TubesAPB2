// Part of: Attendance - Data

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/office_entity.dart';

class OfficeModel extends OfficeEntity {
  const OfficeModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.radiusMeters,
    required super.address,
  });

  factory OfficeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final point = data['location'] as GeoPoint?;
    return OfficeModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Kantor',
      latitude: point?.latitude ?? 0,
      longitude: point?.longitude ?? 0,
      radiusMeters: (data['radius'] as num?)?.toInt() ?? 500,
      address: data['address'] as String? ?? '',
    );
  }
}
