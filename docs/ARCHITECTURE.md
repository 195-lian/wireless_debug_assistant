# 架构设计

## 概述

本项目采用 **Clean Architecture（整洁架构）** 分层设计，结合 **Flutter Riverpod** 进行状态管理，确保代码的可测试性、可维护性和平台无关性。

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │  ← UI / Pages / Providers / Router
│         (lib/presentation/)             │
├─────────────────────────────────────────┤
│           Service Layer                 │  ← 平台具体实现（BLE / Wi-Fi）
│           (lib/services/)               │
├─────────────────────────────────────────┤
│           Domain Layer                  │  ← 实体定义（纯 Dart 类）
│           (lib/domain/)                 │
├─────────────────────────────────────────┤
│            Core Layer                   │  ← 主题、常量、工具函数
│            (lib/core/)                  │
└─────────────────────────────────────────┘
```

## 各层职责

### 1. Core Layer (`lib/core/`)

基础设施层，不依赖任何业务逻辑。

| 目录 | 职责 |
|------|------|
| `constants/` | 全局常量（超时时间、默认 UUID、显示模式等） |
| `theme/` | Material 3 主题系统（深色/浅色 GitHub Dark 风格） |
| `utils/` | 通用工具函数（HEX 编解码等） |

### 2. Domain Layer (`lib/domain/`)

领域层，定义核心业务实体。全部为纯 Dart 类，**不依赖任何 Flutter 包**。

| 实体 | 说明 |
|------|------|
| `BluetoothDevice` | 蓝牙设备（ID、名称、类型、RSSI、服务列表） |
| `BluetoothMessage` | 蓝牙消息（设备ID、特征UUID、数据、方向、类型、时间戳） |
| `SocketConnection` | Socket 连接（类型、地址、端口、状态） |
| `BtConnectionState` | 连接状态枚举（disconnected / connecting / connected / disconnecting） |
| `BtService` | GATT 服务（UUID + 特征值列表） |

### 3. Service Layer (`lib/services/`)

服务层，实现平台相关的业务逻辑。通过抽象接口与上层解耦。

| 文件 | 说明 |
|------|------|
| `bluetooth_service.dart` | 蓝牙服务抽象接口（BLE + SPP） |
| `ble_service_impl.dart` | BLE 实现，基于 `flutter_blue_plus` |
| `wifi_service.dart` | Wi-Fi 服务抽象接口 |
| `wifi_service_impl.dart` | Wi-Fi 实现，基于 `dart:io` Socket |

**设计原则**：
- 抽象接口定义在 `services/` 中，便于单元测试时 Mock
- 实现类通过 `import '...' as fbp` 等方式隔离第三方库命名冲突

### 4. Presentation Layer (`lib/presentation/`)

表现层，负责 UI 渲染和用户交互。

| 目录 | 职责 |
|------|------|
| `pages/` | 各功能页面（Splash、Home、BLE Scan、BLE Device、Wi-Fi、Settings） |
| `providers/` | Riverpod Provider 定义（状态管理） |
| `router/` | `go_router` 路由配置 |

## 数据流向

```
User Action → Page Widget → Provider → Service Implementation
                                           ↓
                                    Platform Plugin (flutter_blue_plus / dart:io)
                                           ↓
                                    OS (Android Bluetooth / Socket APIs)
```

## Provider 设计

### 蓝牙相关 Provider

```dart
// 服务实例（单例）
final bluetoothServiceProvider = Provider<BluetoothService>((ref) => BleServiceImpl());

// 扫描状态
final bleScanProvider = StateNotifierProvider<BleScanNotifier, AsyncValue<List<BluetoothDevice>>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return BleScanNotifier(service);
});

// 连接状态（按设备ID区分）
final bleConnectionProvider = StreamProvider.family<BtConnectionState, String>((ref, deviceId) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.connectionState(deviceId);
});

// 消息流（按设备ID区分）
final bleMessagesProvider = StreamProvider.family<BluetoothMessage, String>((ref, deviceId) {
  final service = ref.watch(bluetoothServiceProvider);
  return service.messageStream(deviceId);
});
```

### Wi-Fi 相关 Provider

```dart
// 服务实例
final wifiServiceProvider = Provider<WifiService>((ref) => WifiServiceImpl());

// 连接列表
final wifiConnectionsProvider = StateNotifierProvider<WifiConnectionsNotifier, List<SocketConnection>>((ref) {
  final service = ref.watch(wifiServiceProvider);
  return WifiConnectionsNotifier(service);
});
```

## 横竖屏适配策略

在 `app.dart` 中根据屏幕最短边判断设备类型：

```dart
final shortestSide = MediaQuery.of(context).size.shortestSide;
if (shortestSide < 600) {
  // 手机：锁定竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, portraitDown]);
} else {
  // 平板：允许横竖屏
  SystemChrome.setPreferredOrientations([...allOrientations]);
}
```
