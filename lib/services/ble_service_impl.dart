import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import '../core/constants/app_constants.dart';
import '../domain/entities/bluetooth_device.dart';
import '../domain/entities/bluetooth_message.dart';
import 'bluetooth_service.dart' as svc;

class BleServiceImpl implements svc.BluetoothService {
  final _scanController = StreamController<List<BluetoothDevice>>.broadcast();
  final _messageControllers = <String, StreamController<BluetoothMessage>>{};
  final _connectionStates = <String, StreamController<BtConnectionState>>{};
  final _devices = <String, BluetoothDevice>{};

  StreamSubscription? _scanSubscription;

  @override
  Stream<List<BluetoothDevice>> scanBle({Duration? timeout, List<String>? withServices}) {
    final services = withServices?.map((s) => fbp.Guid(s)).toList();

    _scanSubscription?.cancel();
    _devices.clear();

    _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final device = BluetoothDevice(
          id: result.device.remoteId.str,
          name: result.device.advName.isNotEmpty ? result.device.advName : result.device.platformName,
          type: BluetoothType.ble,
          rssi: result.rssi,
          lastSeen: DateTime.now(),
        );
        _devices[device.id] = device;
      }
      _scanController.add(List.unmodifiable(_devices.values));
    });

    fbp.FlutterBluePlus.startScan(
      timeout: timeout ?? AppConstants.bleScanTimeout,
      withServices: services ?? [],
    );

    return _scanController.stream;
  }

  @override
  Stream<List<BluetoothDevice>> scanClassic() {
    throw UnsupportedError('Classic Bluetooth SPP is not supported on BLE service');
  }

  @override
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await fbp.FlutterBluePlus.stopScan();
  }

  @override
  Future<void> connectBle(String deviceId, {Duration? timeout}) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    await device.connect(timeout: timeout ?? AppConstants.bleConnectionTimeout);
  }

  @override
  Future<void> connectClassic(String address, {String? uuid}) async {
    throw UnsupportedError('Classic Bluetooth SPP is not supported on BLE service');
  }

  @override
  Future<void> disconnect(String deviceId) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    await device.disconnect();
  }

  @override
  Stream<BtConnectionState> connectionState(String deviceId) {
    final controller = StreamController<BtConnectionState>.broadcast();
    _connectionStates[deviceId] = controller;

    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    device.connectionState.listen((state) {
      final mapped = switch (state) {
        fbp.BluetoothConnectionState.connected => BtConnectionState.connected,
        fbp.BluetoothConnectionState.disconnected => BtConnectionState.disconnected,
        _ => BtConnectionState.connecting,
      };
      controller.add(mapped);
    });

    return controller.stream;
  }

  @override
  Future<List<BtService>> discoverServices(String deviceId) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    final services = await device.discoverServices();
    return services.map((s) => BtService(
      uuid: s.uuid.str,
      characteristics: s.characteristics.map((c) => BluetoothCharacteristic(
        uuid: c.uuid.str,
        serviceUuid: s.uuid.str,
        properties: c.properties.toString().split(', '),
      )).toList(),
    )).toList();
  }

  @override
  Future<List<int>> read(String deviceId, String characteristicUuid) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    final services = await device.discoverServices();
    for (final service in services) {
      for (final char in service.characteristics) {
        if (char.uuid.str == characteristicUuid) {
          final data = await char.read();
          return data;
        }
      }
    }
    throw Exception('Characteristic not found');
  }

  @override
  Future<void> write(String deviceId, String characteristicUuid, List<int> data, {bool withoutResponse = false}) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    final services = await device.discoverServices();
    for (final service in services) {
      for (final char in service.characteristics) {
        if (char.uuid.str == characteristicUuid) {
          await char.write(Uint8List.fromList(data), withoutResponse: withoutResponse);
          return;
        }
      }
    }
    throw Exception('Characteristic not found');
  }

  @override
  Stream<List<int>> subscribe(String deviceId, String characteristicUuid) {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    final controller = StreamController<List<int>>.broadcast();

    device.discoverServices().then((services) {
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.uuid.str == characteristicUuid && char.properties.notify) {
            char.setNotifyValue(true);
            char.onValueReceived.listen((data) {
              controller.add(data);
              _emitMessage(deviceId, characteristicUuid, data, MessageDirection.rx, MessageType.notify);
            });
            return;
          }
        }
      }
    });

    return controller.stream;
  }

  @override
  Future<void> unsubscribe(String deviceId, String characteristicUuid) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    final services = await device.discoverServices();
    for (final service in services) {
      for (final char in service.characteristics) {
        if (char.uuid.str == characteristicUuid) {
          await char.setNotifyValue(false);
          return;
        }
      }
    }
  }

  @override
  Future<int> requestMtu(String deviceId, int mtu) async {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    return await device.requestMtu(mtu);
  }

  @override
  Stream<int> rssiStream(String deviceId) async* {
    final device = fbp.BluetoothDevice(remoteId: fbp.DeviceIdentifier(deviceId));
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final rssi = await device.readRssi();
        yield rssi;
      } catch (_) {
        break;
      }
    }
  }

  @override
  Stream<BluetoothMessage> messageStream(String deviceId) {
    final controller = StreamController<BluetoothMessage>.broadcast();
    _messageControllers[deviceId] = controller;
    return controller.stream;
  }

  @override
  Future<void> send(String deviceId, List<int> data) async {
    // For BLE, send is typically a write operation
    // The caller should use write() with specific characteristic
    _emitMessage(deviceId, null, data, MessageDirection.tx, MessageType.write);
  }

  void _emitMessage(String deviceId, String? characteristicUuid, List<int> data, MessageDirection direction, MessageType type) {
    final controller = _messageControllers[deviceId];
    if (controller != null && !controller.isClosed) {
      controller.add(BluetoothMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        deviceId: deviceId,
        characteristicUuid: characteristicUuid,
        data: data,
        direction: direction,
        type: type,
        timestamp: DateTime.now(),
      ));
    }
  }

  void dispose() {
    _scanController.close();
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    for (final controller in _connectionStates.values) {
      controller.close();
    }
    _scanSubscription?.cancel();
  }
}
