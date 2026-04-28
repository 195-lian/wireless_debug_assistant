import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../../domain/entities/bluetooth_device.dart' show BtConnectionState;
import '../../domain/entities/bluetooth_device.dart';
import '../../domain/entities/bluetooth_message.dart';
import '../../services/ble_service_impl.dart';
import '../../services/bluetooth_service.dart' as svc;

final bluetoothServiceProvider = Provider<svc.BluetoothService>((ref) {
  return BleServiceImpl();
});

final bleScanProvider = StateNotifierProvider<BleScanNotifier, AsyncValue<List<BluetoothDevice>>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return BleScanNotifier(service);
});

final bleConnectionProvider = StreamProvider.family<BtConnectionState, String>((ref, deviceId) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.connectionState(deviceId);
});

final bleMessagesProvider = StreamProvider.family<BluetoothMessage, String>((ref, deviceId) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.messageStream(deviceId);
});

class BleScanNotifier extends StateNotifier<AsyncValue<List<BluetoothDevice>>> {
  final svc.BluetoothService _service;
  StreamSubscription? _subscription;

  BleScanNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> startScan() async {
    state = const AsyncValue.loading();
    try {
      _subscription?.cancel();
      _subscription = _service.scanBle().listen(
        (devices) => state = AsyncValue.data(devices),
        onError: (e, s) => state = AsyncValue.error(e, s),
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
    await _service.stopScan();
  }

  Future<void> connect(String deviceId) async {
    try {
      await _service.connectBle(deviceId);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> disconnect(String deviceId) async {
    await _service.disconnect(deviceId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
