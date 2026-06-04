// Part of: Core - Network

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Memantau status koneksi perangkat secara real-time untuk banner offline
/// global. State `true` = online, `false` = offline.
///
/// Catatan: ini hanya cek ada-tidaknya interface jaringan, bukan apakah server
/// Firestore benar-benar terjangkau (lihat kasus ECONNREFUSED IPv6 di CLAUDE.md
/// §6) — itu tetap ditangani per-repository lewat Failure berpesan jelas.
class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Awali optimis `true` agar banner tidak berkedip saat startup sebelum cek
  // pertama selesai.
  ConnectivityCubit(this._connectivity) : super(true) {
    _init();
  }

  Future<void> _init() async {
    try {
      emit(_isOnline(await _connectivity.checkConnectivity()));
    } catch (_) {
      // Gagal cek awal — anggap online; perubahan nyata akan datang dari stream.
    }
    _subscription =
        _connectivity.onConnectivityChanged.listen((r) => emit(_isOnline(r)));
  }

  // connectivity_plus mengembalikan list (bisa multi-interface). Hanya 'none'
  // yang berarti benar-benar offline.
  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
