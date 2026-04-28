import '../domain/entities/bluetooth_device.dart' as domain;
import '../domain/entities/bluetooth_message.dart';

abstract class BluetoothService {
  // Scan
  Stream<List<domain.BluetoothDevice>> scanBle({Duration? timeout, List<String>? withServices});
  Stream<List<domain.BluetoothDevice>> scanClassic();
  Future<void> stopScan();

  // Connect
  Future<void> connectBle(String deviceId, {Duration? timeout});
  Future<void> connectClassic(String address, {String? uuid});
  Future<void> disconnect(String deviceId);
  Stream<domain.BtConnectionState> connectionState(String deviceId);

  // BLE GATT
  Future<List<domain.BtService>> discoverServices(String deviceId);
  Future<List<int>> read(String deviceId, String characteristicUuid);
  Future<void> write(String deviceId, String characteristicUuid, List<int> data, {bool withoutResponse = false});
  Stream<List<int>> subscribe(String deviceId, String characteristicUuid);
  Future<void> unsubscribe(String deviceId, String characteristicUuid);
  Future<int> requestMtu(String deviceId, int mtu);
  Stream<int> rssiStream(String deviceId);

  // Unified messaging
  Stream<BluetoothMessage> messageStream(String deviceId);
  Future<void> send(String deviceId, List<int> data);
}
