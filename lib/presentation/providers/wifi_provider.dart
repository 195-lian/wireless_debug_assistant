import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/socket_connection.dart';
import '../../services/wifi_service.dart';
import '../../services/wifi_service_impl.dart';

final wifiServiceProvider = Provider<WifiService>((ref) {
  return WifiServiceImpl();
});

final wifiConnectionsProvider = StateNotifierProvider<WifiConnectionsNotifier, List<SocketConnection>>((ref) {
  final service = ref.watch(wifiServiceProvider);
  return WifiConnectionsNotifier(service);
});

class WifiConnectionsNotifier extends StateNotifier<List<SocketConnection>> {
  final WifiService _service;

  WifiConnectionsNotifier(this._service) : super([]);

  Future<void> connectTcp(String host, int port) async {
    final conn = await _service.tcpConnect(host, port);
    state = [...state, conn];
  }

  Future<void> startServer(int port) async {
    final conn = await _service.tcpListen(port);
    state = [...state, conn];
  }

  Future<void> bindUdp(int port) async {
    final conn = await _service.udpBind(port);
    state = [...state, conn];
  }

  Future<void> disconnect(String id) async {
    await _service.close(id);
    state = state.where((c) => c.id != id).toList();
  }

  Future<void> send(String id, List<int> data) async {
    await _service.send(id, data);
  }

  Stream<List<int>> receive(String id) {
    return _service.receive(id);
  }

  Future<String?> getLocalIp() async {
    return _service.getLocalIp();
  }
}
