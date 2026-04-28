# 常见问题

## 编译问题

### Q: `flutter build apk` 报错 `CMAKE_C_COMPILER not set`

**原因**：NDK 安装不完整，缺少 `clang` 编译器或 CMake toolchain。

**解决**：
```bash
# 删除不完整的 NDK
rm -rf ~/Library/Android/sdk/ndk/25.1.8937393

# 重新安装完整版
sdkmanager "ndk;25.1.8937393"
sdkmanager "ndk;26.1.10909125"
```

### Q: `ConnectionState.connected` 成员未找到

**原因**：Flutter 框架自带 `ConnectionState` 枚举（值为 `none/waiting/active/done`），与项目自定义的 `ConnectionState` 冲突。

**解决**：本项目已将自定义枚举重命名为 `BtConnectionState`，所有引用处统一使用 `BtConnectionState.connected` / `BtConnectionState.connecting` 等。

### Q: `BluetoothService` 返回类型不匹配

**原因**：`lib/services/bluetooth_service.dart` 中的抽象接口类与 `lib/domain/entities/bluetooth_device.dart` 中的数据实体类同名。

**解决**：
- 数据实体已重命名为 `BtService`
- 抽象接口导入实体时使用 `as domain` 别名

### Q: AGP 8.1.1 + Java 21 报错 `JdkImageTransform`

**原因**：AGP 8.1.1 与 Java 21 存在已知兼容性问题。

**解决**：升级 AGP 到 8.6.0+，Kotlin 到 2.1.0+。详见 `android/settings.gradle`。

## 运行时问题

### Q: Android 12+ 无法扫描 BLE 设备

**原因**：Android 12+ 需要运行时申请 `BLUETOOTH_SCAN` 和 `BLUETOOTH_CONNECT` 权限。

**解决**：确保 `AndroidManifest.xml` 已配置权限，并在代码中使用 `permission_handler` 申请：

```dart
import 'package:permission_handler/permission_handler.dart';

await Permission.bluetoothScan.request();
await Permission.bluetoothConnect.request();
```

### Q: iOS 无法使用经典蓝牙 SPP

**原因**：Apple 限制 iOS 应用使用经典蓝牙 RFCOMM/SPP 协议，仅开放 BLE。

**解决**：SPP 功能仅限 Android。iOS 端仅支持 BLE。

### Q: 平板横屏后布局错乱

**原因**：当前 UI 主要适配手机竖屏，平板横屏布局尚未完成。

**解决**：在 `lib/app.dart` 中已预留横屏支持逻辑（`shortestSide >= 600` 时允许横屏），具体页面适配正在开发中。

## 开发问题

### Q: 如何添加新的显示格式？

在 `lib/core/constants/app_constants.dart` 中的 `DisplayMode` 类添加新格式，然后在数据解析处实现转换逻辑。

### Q: 如何 Mock 蓝牙服务进行单元测试？

```dart
class MockBluetoothService implements BluetoothService {
  @override
  Stream<List<BluetoothDevice>> scanBle({Duration? timeout, List<String>? withServices}) {
    return Stream.value([
      BluetoothDevice(id: 'test', name: 'Mock Device', type: BluetoothType.ble, rssi: -50, lastSeen: DateTime.now()),
    ]);
  }
  // ... 实现其他方法
}
```

### Q: 为什么放弃 freezed？

Dart 3.11.5 环境下 `build_runner` + `freezed` + `hive_generator` + `json_serializable` 存在版本解析冲突（`_macros` 包缺失），因此全部改为纯 Dart 手写类。
