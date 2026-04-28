# 蓝牙模块开发文档

## 概述

蓝牙模块支持两种协议：
- **BLE（低功耗蓝牙）**：基于 `flutter_blue_plus`，支持 Android + iOS
- **经典蓝牙 SPP**：基于 `flutter_bluetooth_serial`，仅支持 Android

## 抽象接口

`BluetoothService` 定义了统一的蓝牙操作接口：

```dart
abstract class BluetoothService {
  // 扫描
  Stream<List<BluetoothDevice>> scanBle({Duration? timeout, List<String>? withServices});
  Stream<List<BluetoothDevice>> scanClassic();
  Future<void> stopScan();

  // 连接
  Future<void> connectBle(String deviceId, {Duration? timeout});
  Future<void> connectClassic(String address, {String? uuid});
  Future<void> disconnect(String deviceId);
  Stream<BtConnectionState> connectionState(String deviceId);

  // GATT 操作
  Future<List<BtService>> discoverServices(String deviceId);
  Future<List<int>> read(String deviceId, String characteristicUuid);
  Future<void> write(String deviceId, String characteristicUuid, List<int> data, {bool withoutResponse = false});
  Stream<List<int>> subscribe(String deviceId, String characteristicUuid);
  Future<void> unsubscribe(String deviceId, String characteristicUuid);
  Future<int> requestMtu(String deviceId, int mtu);
  Stream<int> rssiStream(String deviceId);

  // 统一消息
  Stream<BluetoothMessage> messageStream(String deviceId);
  Future<void> send(String deviceId, List<int> data);
}
```

## BLE 连接状态机

```
┌─────────────┐    connect()    ┌─────────────┐    connected    ┌─────────────┐
│ disconnected│ ──────────────→ │  connecting │ ──────────────→ │  connected  │
└─────────────┘                 └─────────────┘                 └──────┬──────┘
      ↑                                                                │
      └──────────────── disconnect() ──────────────────────────────────┘
```

状态枚举定义：
```dart
enum BtConnectionState { disconnected, connecting, connected, disconnecting }
```

> ⚠️ **注意**：Flutter 框架自带 `ConnectionState` 枚举（值为 `none/waiting/active/done`），为避免命名冲突，本项目将自定义枚举命名为 `BtConnectionState`。

## BLE 扫描流程

```dart
// 1. 获取 Provider
final scanNotifier = ref.read(bleScanProvider.notifier);

// 2. 开始扫描
await scanNotifier.startScan();

// 3. 监听扫描结果
final devices = ref.watch(bleScanProvider);
devices.when(
  data: (list) => /* 显示设备列表 */,
  loading: () => /* 显示加载中 */,
  error: (err, stack) => /* 显示错误 */,
);

// 4. 停止扫描
await scanNotifier.stopScan();
```

## GATT 服务发现与通信

### 发现服务

```dart
final service = ref.read(bluetoothServiceProvider);
final services = await service.discoverServices(deviceId);
// services: List<BtService>，每个包含 uuid 和 characteristics 列表
```

### 读取特征值

```dart
final data = await service.read(deviceId, characteristicUuid);
// data: List<int>
```

### 写入特征值

```dart
// 有响应写入（等待设备确认）
await service.write(deviceId, characteristicUuid, [0x01, 0x02]);

// 无响应写入（更快，但不保证送达）
await service.write(deviceId, characteristicUuid, [0x01, 0x02], withoutResponse: true);
```

### 订阅 Notify

```dart
final subscription = service.subscribe(deviceId, characteristicUuid).listen((data) {
  // data: List<int>，设备主动上报的数据
});

// 取消订阅
await service.unsubscribe(deviceId, characteristicUuid);
subscription.cancel();
```

## 经典蓝牙 SPP（Android Only）

SPP（Serial Port Profile）基于 RFCOMM 协议，适用于需要串口通信的场景。

```dart
// 扫描经典蓝牙设备
final devices = service.scanClassic();

// 连接（使用默认 SPP UUID）
await service.connectClassic(deviceAddress);

// 或使用自定义 UUID
await service.connectClassic(deviceAddress, uuid: '00001101-0000-1000-8000-00805F9B34FB');
```

> ⚠️ **iOS 不支持**：Apple 限制第三方 App 使用经典蓝牙 SPP，该功能仅限 Android。

## 消息系统

所有蓝牙通信（读/写/通知）统一转换为 `BluetoothMessage`：

```dart
class BluetoothMessage {
  final String deviceId;
  final String? characteristicUuid;
  final List<int> data;
  final MessageDirection direction;  // tx / rx
  final MessageType type;            // read / write / notify / indicate
  final DateTime timestamp;
}
```

通过 `messageStream(deviceId)` 订阅消息流，实现统一的日志记录和展示。

## 实体类命名冲突处理

项目中存在两个 `BluetoothService`：
1. **抽象接口**：`lib/services/bluetooth_service.dart` 中的 `abstract class BluetoothService`
2. **数据实体**：`lib/domain/entities/bluetooth_device.dart` 中的 `class BtService`（原名 `BluetoothService`）

为避免冲突：
- 实体类已重命名为 `BtService`
- 抽象接口的导入使用 `as domain` 别名：`import '../domain/entities/bluetooth_device.dart' as domain;`
