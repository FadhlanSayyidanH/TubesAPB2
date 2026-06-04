// Part of: Core - Services

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

/// Menulis baris-baris (`List<List<String>>`) jadi file CSV di direktori
/// temporer aplikasi lalu mengembalikan path-nya, siap dibagikan via share sheet.
class CsvExportService {
  Future<String> writeCsv(List<List<String>> rows, String fileName) async {
    // CRLF + field quoting default — kompatibel dibuka di Excel.
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);
    return file.path;
  }
}
