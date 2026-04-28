enum BluetoothType { ble, classic }

enum BtConnectionState { disconnected, connecting, connected, disconnecting }

class BluetoothDevice {
  final String id;
  final String? name;
  final BluetoothType type;
  final int rssi;
  final bool isConnected;
  final List<BtService> services;
  final DateTime lastSeen;

  BluetoothDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.rssi,
    this.isConnected = false,
    this.services = const [],
    required this.lastSeen,
  });
}

class BtService {
  final String uuid;
  final List<BluetoothCharacteristic> characteristics;

  BtService({
    required this.uuid,
    this.characteristics = const [],
  });
}

class BluetoothCharacteristic {
  final String uuid;
  final String serviceUuid;
  final List<String> properties;
  final List<int>? lastValue;

  BluetoothCharacteristic({
    required this.uuid,
    required this.serviceUuid,
    this.properties = const [],
    this.lastValue,
  });
}
