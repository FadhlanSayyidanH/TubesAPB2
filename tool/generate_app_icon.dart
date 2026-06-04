// ============================================================================
// UNTUK APA FILE INI:
// Program "Smart Absen" adalah aplikasi absensi karyawan berbasis lokasi GPS +
// verifikasi wajah. File ini BUKAN bagian aplikasi yang jalan di HP — ini alat
// bantu sekali-pakai (tooling) untuk MEMBUAT GAMBAR IKON LAUNCHER aplikasi.
//
// Hasilnya dua file PNG di assets/icon/ yang lalu dipakai paket
// flutter_launcher_icons untuk menghasilkan ikon di semua ukuran layar.
// Cara jalankan: dart run tool/generate_app_icon.dart
// ============================================================================
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

// Tiga warna brand aplikasi (sama dengan AppColors): biru tua, oranye, putih.
final _navy = img.ColorRgba8(13, 27, 42, 255);
final _orange = img.ColorRgba8(244, 80, 14, 255);
final _white = img.ColorRgba8(255, 255, 255, 255);

// UNTUK APA: menggambar satu garis tebal (satu coretan centang) yang solid.
// Caranya garis dijadikan kotak panjang (poligon) + bulatan di kedua ujung
// supaya ujungnya membulat. Pakai cara manual karena garis tebal bawaan paket
// `image` meninggalkan corak garis-garis yang tidak rapi.
void _thickSegment(
  img.Image image,
  double x1,
  double y1,
  double x2,
  double y2,
  double halfWidth,
  img.Color color,
) {
  final dx = x2 - x1, dy = y2 - y1;
  final len = math.sqrt(dx * dx + dy * dy);
  final inv = len == 0 ? 0.0 : halfWidth / len;
  // Arah tegak lurus garis, dipakai untuk menebalkan ke kiri & kanan.
  final px = -dy * inv, py = dx * inv;
  img.fillPolygon(
    image,
    vertices: [
      img.Point(x1 + px, y1 + py),
      img.Point(x2 + px, y2 + py),
      img.Point(x2 - px, y2 - py),
      img.Point(x1 - px, y1 - py),
    ],
    color: color,
  );
  img.fillCircle(
    image,
    x: x1.round(),
    y: y1.round(),
    radius: halfWidth.round(),
    color: color,
  );
  img.fillCircle(
    image,
    x: x2.round(),
    y: y2.round(),
    radius: halfWidth.round(),
    color: color,
  );
}

// UNTUK APA: menggambar tanda centang (✓) — lambang "hadir" pada absensi —
// dari dua coretan: garis pendek turun lalu garis panjang naik.
void _drawCheck(
  img.Image image,
  int cx,
  int cy,
  double scale,
  img.Color color,
) {
  final hw = 30 * scale;
  final ax = cx + -150 * scale, ay = cy + 10 * scale;
  final bx = cx + -40 * scale, by = cy + 120 * scale;
  final dx = cx + 170 * scale, dy = cy + -110 * scale;
  _thickSegment(image, ax, ay, bx, by, hw, color);
  _thickSegment(image, bx, by, dx, dy, hw, color);
}

void main() {
  const size = 1024;
  const center = size ~/ 2;

  // GAMBAR 1 — ikon utuh untuk HP lama: latar biru tua penuh, lingkaran oranye
  // di tengah, lalu centang putih. Inilah ikon yang tampil apa adanya.
  final full = img.Image(width: size, height: size, numChannels: 4);
  img.fill(full, color: _navy);
  img.fillCircle(full, x: center, y: center, radius: 340, color: _orange);
  _drawCheck(full, center, center, 1.0, _white);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(full));

  // GAMBAR 2 — lapisan depan untuk ikon adaptif (HP baru): latar transparan,
  // isi dikecilkan ke tengah karena Android memotong ~25% tepi ikon adaptif.
  final fg = img.Image(width: size, height: size, numChannels: 4);
  img.fillCircle(fg, x: center, y: center, radius: 250, color: _orange);
  _drawCheck(fg, center, center, 0.72, _white);
  File(
    'assets/icon/app_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(fg));

  stdout.writeln(
    'Ikon dibuat: assets/icon/app_icon.png & app_icon_foreground.png',
  );
}
