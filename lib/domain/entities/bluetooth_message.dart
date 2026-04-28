enum MessageDirection { tx, rx }

enum MessageType { read, write, notify, indicate }

class BluetoothMessage {
  final String id;
  final String deviceId;
  final String? characteristicUuid;
  final List<int> data;
  final MessageDirection direction;
  final MessageType type;
  final DateTime timestamp;

  BluetoothMessage({
    required this.id,
    required this.deviceId,
    this.characteristicUuid,
    required this.data,
    required this.direction,
    required this.type,
    required this.timestamp,
  });
}
