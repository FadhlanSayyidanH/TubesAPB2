// Part of: Core - Network

import 'package:connectivity_plus/connectivity_plus.dart';

/// Pengecek konektivitas sederhana. Repository memanggil [isConnected] sebelum
/// operasi yang butuh jaringan, supaya bisa langsung balikin NetworkFailure
/// dengan pesan jelas alih-alih menunggu timeout Firebase yang lama.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    // connectivity_plus mengembalikan list (bisa multi-interface aktif).
    // Hanya 'none' yang berarti benar-benar offline.
    return results.any((result) => result != ConnectivityResult.none);
  }
}
