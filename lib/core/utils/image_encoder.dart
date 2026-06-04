// Part of: Core - Utils

import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;

import '../errors/exceptions.dart';

/// Kompres sebuah gambar (foto selfie absensi maupun foto profil) lalu kodekan
/// jadi **data URI base64**, supaya bisa disimpan langsung di Firestore tanpa
/// Firebase Storage (project masih Spark/tanpa billing — lihat CLAUDE.md §6).
///
/// Sisi terpanjang dibatasi 800px, kualitas JPEG 70 → ±40KB, jauh di bawah
/// batas dokumen Firestore 1MB. Pindah ke Storage (Blaze) nanti cukup ganti
/// pemanggil agar menyimpan URL unduhan, bukan data URI ini.
class ImageEncoder {
  static const int _maxSide = 800;
  static const int _jpegQuality = 70;

  Future<String> encodeToDataUri(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const ServerException();

    // Hanya perkecil (jangan perbesar) supaya tidak menambah ukuran sia-sia.
    final needsResize = decoded.width > _maxSide || decoded.height > _maxSide;
    final prepared = !needsResize
        ? decoded
        : (decoded.width >= decoded.height
              ? img.copyResize(decoded, width: _maxSide)
              : img.copyResize(decoded, height: _maxSide));

    final jpg = img.encodeJpg(prepared, quality: _jpegQuality);
    return 'data:image/jpeg;base64,${base64Encode(jpg)}';
  }
}
