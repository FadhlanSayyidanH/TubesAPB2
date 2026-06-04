// Part of: Attendance - Data

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/office_model.dart';

/// Mengambil titik kantor acuan. Untuk skenario satu kantor, kita pakai
/// dokumen pertama di koleksi /offices.
abstract class OfficeRemoteDataSource {
  Future<OfficeModel> getPrimaryOffice();
}

class OfficeRemoteDataSourceImpl implements OfficeRemoteDataSource {
  final FirebaseFirestore _firestore;

  OfficeRemoteDataSourceImpl(this._firestore);

  @override
  Future<OfficeModel> getPrimaryOffice() async {
    final snapshot = await _firestore.collection('offices').limit(1).get();
    if (snapshot.docs.isEmpty) {
      // Hasil kosong dari cache berarti server tak terjangkau (offline/IPv6
      // bermasalah), bukan kantor yang benar-benar belum diatur. Bedakan agar
      // pesan ke user akurat.
      if (snapshot.metadata.isFromCache) throw const ServerException();
      throw const OfficeNotConfiguredException();
    }
    return OfficeModel.fromFirestore(snapshot.docs.first);
  }
}
