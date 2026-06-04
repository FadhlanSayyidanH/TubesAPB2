// Part of: Core - Utils (test)

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/core/utils/haversine.dart';

void main() {
  group('calculateDistanceMeters', () {
    test('jarak titik ke dirinya sendiri = 0', () {
      expect(calculateDistanceMeters(-6.2088, 106.8456, -6.2088, 106.8456),
          closeTo(0, 0.01));
    });

    test('~111 km per derajat lintang di ekuator', () {
      // 1 derajat lintang ≈ 111,32 km di mana pun.
      final d = calculateDistanceMeters(0, 0, 1, 0);
      expect(d, closeTo(111195, 500));
    });

    test('jarak Monas ke Bundaran HI ~2.6 km', () {
      // Monas (-6.1754, 106.8272) → Bundaran HI (-6.1944, 106.8229)
      final d = calculateDistanceMeters(-6.1754, 106.8272, -6.1944, 106.8229);
      expect(d, closeTo(2150, 300));
    });

    test('titik 400 m dari kantor terhitung < radius 500 m', () {
      // Geser ~0.0036 derajat lon dari kantor Jakarta ≈ 400 m.
      final d = calculateDistanceMeters(-6.2088, 106.8456, -6.2088, 106.8492);
      expect(d, lessThan(500));
      expect(d, greaterThan(300));
    });
  });
}
