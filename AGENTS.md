# AGENTS.md

> 本文件面向 AI 编程助手。如果你对本项目一无所知，请优先阅读本文档，再阅读 `README.md` 和各 `docs/` 文档。

---

## 项目概述

`wireless_debug_assistant` 是一款基于 **Flutter** 的移动端无线调试工具，支持：

- **BLE 低功耗蓝牙**：扫描、连接、GATT 服务发现、特征值读写、Notify/Indicate 订阅
- **经典蓝牙 SPP（Android 独占）**：基于 RFCOMM 的串口通信
- **Wi-Fi Socket 调试**：TCP Client/Server、UDP 通信、端口扫描
- **数据解析与日志**：ASCII / HEX / Binary / Base64 / UTF-8 多格式收发，本地持久化与导出

目标平台为 **Android（API 22+）** 与 **iPad（横屏适配中）**。iOS 因系统限制不支持经典蓝牙 SPP，BLE 与 Wi-Fi 待适配。

许可证：MIT

---

## 技术栈

| 类别 | 依赖包 |
|------|--------|
| 框架 | Flutter 3.41.7+ / Dart 3.11.5+ |
| 状态管理 | `flutter_riverpod` |
| 路由 | `go_router` |
| BLE | `flutter_blue_plus` |
| 经典蓝牙 SPP | `flutter_bluetooth_serial` |
| 网络信息 | `connectivity_plus` + `network_info_plus` |
| 权限 | `permission_handler` |
| 本地存储 | `hive` + `hive_flutter` |
| 图表 | `fl_chart` |
| 文件/分享 | `file_saver` + `share_plus` |
| 设备信息 | `device_info_plus` + `package_info_plus` |

> **注意**：`pubspec.yaml` 中虽然声明了 `freezed`、`json_serializable`、`hive_generator` 等代码生成工具，但由于 Dart 3.11.5 环境下 `_macros` 包存在版本冲突，**项目目前全部使用纯 Dart 手写类**，不运行 `build_runner`。

---

## 项目结构与代码组织

项目采用 **Clean Architecture** 分层设计，源码位于 `lib/`：

```
lib/
├── core/                        # 核心层（无业务依赖）
│   ├── constants/               # 全局常量、超时、默认端口、显示模式
│   ├── theme/                   # Material 3 主题（GitHub Dark 默认）
│   └── utils/                   # 通用工具（如 HEX 编解码）
├── domain/                      # 领域层（纯 Dart 实体，不依赖 Flutter）
│   └── entities/                # BluetoothDevice、BluetoothMessage、SocketConnection 等
├── services/                    # 服务层（平台相关实现）
│   ├── bluetooth_service.dart   # 蓝牙抽象接口
│   ├── ble_service_impl.dart    # BLE 实现（flutter_blue_plus）
│   ├── wifi_service.dart        # Wi-Fi 抽象接口
│   └── wifi_service_impl.dart   # Wi-Fi 实现（dart:io Socket）
├── presentation/                # 表现层
│   ├── pages/                   # Splash、Home、BLE Scan、BLE Device、Wi-Fi、Settings、Toolbox
│   ├── providers/               # Riverpod Provider / Notifier
│   └── router/                  # go_router 路由配置
├── app.dart                     # 应用根 Widget（主题、横竖屏策略）
└── main.dart                    # 入口（ProviderScope + WirelessDebugApp）
```

> `lib/data/` 目录在文件树中存在，但**当前为空**。业务数据直接由 `services/` 层对接平台插件，尚未引入 Repository/DataSource 中间层。

---

## 构建与运行

### 环境要求

| 工具 | 版本 |
|------|------|
| Flutter | 3.41.7+ |
| Dart | 3.11.5+ |
| Android SDK | API 36 |
| Android NDK | 26.1.10909125（或 25.1.8937393） |
| AGP | 8.6.0 |
| Kotlin | 2.1.0 |
| Gradle | 8.14 |
| Java | 17 |

### 常用命令

```bash
# 安装依赖
flutter pub get

# 开发热重载
flutter run --debug

# 构建 Debug APK
flutter build apk --debug
# 输出：build/app/outputs/flutter-apk/app-debug.apk

# 构建 Release APK
flutter build apk --release
# 输出：build/app/outputs/flutter-apk/app-release.apk

# 构建 App Bundle（Google Play 上架）
flutter build appbundle --release
# 输出：build/app/outputs/bundle/release/app-release.aab

# 安装到设备
flutter devices
flutter install

# 运行测试
flutter test
```

> Release 构建的签名当前指向 `signingConfigs.debug`。若需正式签名，请在 `android/app/build.gradle` 中配置 `signingConfigs.release`，并通过环境变量传入密钥信息。Release 构建已启用 `minifyEnabled` 与 `shrinkResources`。

---

## 代码风格与开发约定

### Lint 规则

`analysis_options.yaml` 基于 `package:flutter_lints/flutter.yaml`，额外启用：

- `prefer_const_constructors: true`
- `prefer_const_literals_to_create_immutables: true`
- `prefer_single_quotes: true`
- `avoid_print: false`（允许使用 `print`）

### 命名与冲突规避

1. **连接状态**：项目自定义枚举命名为 **`BtConnectionState`**（`disconnected / connecting / connected / disconnecting`），**禁止**使用 `ConnectionState`，以免与 Flutter 框架自带枚举冲突。
2. **蓝牙服务实体**：`domain` 层实体原名为 `BluetoothService`，为避免与 `services/bluetooth_service.dart` 中的抽象接口同名，已重命名为 **`BtService`**。在实现文件中导入实体时使用 `as domain` 别名，如：
   ```dart
   import '../domain/entities/bluetooth_device.dart' as domain;
   ```
3. **服务接口导入**：Provider 中导入服务接口时常使用 `as svc` 别名，如：
   ```dart
   import '../../services/bluetooth_service.dart' as svc;
   ```

### UI 与主题

- 默认主题为 **深色模式**（GitHub Dark 风格），由 `AppTheme.darkTheme` 提供。
- 配色常量集中定义在 `AppColors` 中，禁止在页面内硬编码色值。
- 横竖屏策略：在 `app.dart` 中根据 `MediaQuery.size.shortestSide` 判断：
  - `< 600`：手机，锁定竖屏
  - `>= 600`：平板，允许横竖屏（但**横屏页面适配尚未完成**）

### 数据流向

```
User Action → Page Widget → Provider (Riverpod) → Service Implementation
                                                   ↓
                                          Platform Plugin
                                                   ↓
                                          OS (Android APIs)
```

---

## 测试策略

- **当前状态**：`test/` 目录下仅存在默认生成的 `widget_test.dart`，且该文件引用了不存在的 `MyApp` 类（实际应为 `WirelessDebugApp`），**测试基线已损坏，无法直接通过**。
- **单元测试**：因服务层通过抽象接口定义，可方便地 Mock。Mock 示例参考 `docs/FAQ.md`。
- **建议**：在修改业务逻辑后，优先补充 `services/` 层的单元测试和 `presentation/providers/` 层的 Widget 测试。

---

## 安全与权限

### Android 权限配置

`android/app/src/main/AndroidManifest.xml` 已声明以下权限：

- **网络**：`INTERNET`、`ACCESS_NETWORK_STATE`、`ACCESS_WIFI_STATE`、`CHANGE_WIFI_MULTICAST_STATE`
- **BLE（Android 12+）**：`BLUETOOTH_SCAN`（`neverForLocation`）、`BLUETOOTH_CONNECT`、`BLUETOOTH_ADVERTISE`
- **经典蓝牙（Android 11 及以下）**：`BLUETOOTH`、`BLUETOOTH_ADMIN`、`ACCESS_FINE_LOCATION`

### 运行时权限

代码中需使用 `permission_handler` 在运行时申请蓝牙权限，否则 Android 12+ 设备无法扫描 BLE。

### 构建安全

- Release APK 启用 ProGuard（`proguard-android-optimize.txt` + `proguard-rules.pro`）。
- 密钥库密码建议通过环境变量注入，避免硬编码到 Gradle 文件。

---

## 已知问题与注意事项

1. **代码生成工具不可用**：`build_runner` + `freezed` + `hive_generator` + `json_serializable` 因 `_macros` 包冲突已弃用。所有实体类、JSON 序列化、Hive Adapter 均为手写。
2. **NDK 不完整会导致构建失败**：若报错 `CMAKE_C_COMPILER not set`，请通过 `sdkmanager` 重新安装完整 NDK（`ndk;26.1.10909125` 或 `ndk;25.1.8937393`）。
3. **iOS 支持不完整**：SPP 功能在 iOS 上不可用；BLE 与 Wi-Fi 尚未完成 iOS 适配。
4. **平板横屏**：`app.dart` 中已放开横屏限制，但各页面布局仍主要按手机竖屏设计，横屏可能出现布局异常。
5. **测试基线损坏**：`test/widget_test.dart` 需要修复后才能作为持续集成的入口。

---

## 文档索引

| 文件 | 内容 |
|------|------|
| `README.md` | 项目简介、快速开始、功能概览 |
| `docs/ARCHITECTURE.md` | Clean Architecture 分层详解、Provider 设计、数据流向 |
| `docs/BLUETOOTH.md` | BLE / SPP 接口说明、连接状态机、GATT 通信示例 |
| `docs/WIFI.md` | TCP/UDP 使用方式、Socket 通信示例、端口扫描 |
| `docs/THEME.md` | 配色方案、组件主题配置、消息方向颜色 |
| `docs/BUILD.md` | 环境要求、构建命令、签名配置、问题排查 |
| `docs/FAQ.md` | 编译报错、运行时问题、Mock 示例 |
