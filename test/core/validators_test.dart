// Part of: Core - Utils (test)

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance/core/utils/validators.dart';

void main() {
  group('identifier (email atau NIK)', () {
    test('menerima email valid', () {
      expect(Validators.identifier('budi@perusahaan.com'), isNull);
    });

    test('menerima NIK 16 digit', () {
      expect(Validators.identifier('3273012501900001'), isNull);
    });

    test('menolak input kosong', () {
      expect(Validators.identifier(''), isNotNull);
      expect(Validators.identifier('   '), isNotNull);
    });

    test('menolak NIK kurang dari 16 digit', () {
      expect(Validators.identifier('327301250190'), isNotNull);
    });

    test('menolak email tanpa domain', () {
      expect(Validators.identifier('budi@'), isNotNull);
    });
  });

  group('password', () {
    test('menolak kurang dari 6 karakter', () {
      expect(Validators.password('123'), isNotNull);
    });

    test('menerima 6 karakter atau lebih', () {
      expect(Validators.password('rahasia123'), isNull);
    });
  });
}
