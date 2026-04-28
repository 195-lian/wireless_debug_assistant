# Wireless Debug Assistant

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41.7-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-API%2022%2B-green?logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-Unavailable-lightgrey?logo=apple" alt="iOS" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License" />
</p>

<p align="center">
  <b>手机端的蓝牙与 Wi-Fi 无线调试工具</b><br/>
  支持 BLE 低功耗蓝牙、经典蓝牙 SPP 和 Wi-Fi Socket 通信，是嵌入式开发、IoT 调试的随身利器。
</p>

---

## 📸 功能概览

| 模块 | 功能 |
|------|------|
| **BLE 低功耗蓝牙** | 扫描设备、连接管理、GATT 服务发现、特征值读写、Notify / Indicate 订阅 |
| **经典蓝牙 SPP** | Android 串口通信（RFCOMM），支持 UUID 自定义 |
| **Wi-Fi 调试** | TCP Client / Server、UDP 通信，Socket 状态实时监控 |
| **数据解析** | ASCII / HEX / Binary / Base64 / UTF-8 多格式展示与发送 |
| **日志管理** | 消息收发时序记录、本地持久化、导出分享 |

## 🏗️ 项目架构

采用 **Clean Architecture** 分层设计：

```
lib/
├── core/                    # 核心层
│   ├── constants/           # 全局常量
│   ├── theme/               # 主题与配色
│   └── utils/               # 工具函数
├── domain/                  # 领域层
│   └── entities/            # 实体类（设备、消息、连接）
├── services/                # 服务层
│   ├── bluetooth_service.dart    # 蓝牙服务抽象接口
│   ├── ble_service_impl.dart     # BLE 实现（flutter_blue_plus）
│   ├── wifi_service.dart         # Wi-Fi 服务抽象接口
│   └── wifi_service_impl.dart    # Wi-Fi 实现
└── presentation/            # 表现层
    ├── pages/               # 页面（首页、BLE、Wi-Fi、设置等）
    ├── providers/           # Riverpod 状态管理
    └── router/              # go_router 路由配置
```

## 📱 平台支持

| 平台 | 支持状态 | 说明 |
|------|---------|------|
| Android | ✅ | 完整支持 BLE + SPP + Wi-Fi |
| iOS | ❌ | SPP 不可用（系统限制），BLE 与 Wi-Fi 待适配 |
| iPad | 🚧 | 横屏适配规划中 |

## 🚀 快速开始

### 环境要求

- Flutter 3.41.7+
- Dart 3.11.5+
- Android SDK API 36
- Android NDK 26.1.10909125（或 25.1.8937393）

### 构建

```bash
# 获取依赖
flutter pub get

# 构建 Debug APK
flutter build apk --debug

# 安装到设备
flutter install
```

### Android 权限

应用已配置以下权限：

- `BLUETOOTH_SCAN` / `BLUETOOTH_CONNECT` / `BLUETOOTH_ADVERTISE`（Android 12+）
- `BLUETOOTH` / `BLUETOOTH_ADMIN` / `ACCESS_FINE_LOCATION`（Android 11 及以下）
- `INTERNET` / `ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE`

## 🛠️ 技术栈

| 类别 | 依赖 |
|------|------|
| **状态管理** | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| **路由** | [go_router](https://pub.dev/packages/go_router) |
| **BLE** | [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) |
| **SPP** | [flutter_bluetooth_serial](https://pub.dev/packages/flutter_bluetooth_serial) |
| **Wi-Fi** | [connectivity_plus](https://pub.dev/packages/connectivity_plus) + [network_info_plus](https://pub.dev/packages/network_info_plus) |
| **权限** | [permission_handler](https://pub.dev/packages/permission_handler) |
| **图表** | [fl_chart](https://pub.dev/packages/fl_chart) |
| **存储** | [hive](https://pub.dev/packages/hive) + [hive_flutter](https://pub.dev/packages/hive_flutter) |
| **分享** | [share_plus](https://pub.dev/packages/share_plus) |

## 📂 目录结构

```
wireless_debug_assistant/
├── android/                 # Android 原生工程
│   └── app/
│       └── src/main/AndroidManifest.xml   # 权限配置
├── lib/                     # Dart 源码
├── test/                    # 单元测试
├── pubspec.yaml             # 依赖配置
└── README.md                # 本文件
```

## 🤝 贡献

欢迎提交 Issue 和 PR！

## 📄 许可证

MIT License
