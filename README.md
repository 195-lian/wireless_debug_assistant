# wireless_debug_assistant

手机版的蓝牙和Wi-Fi调试工具

## 功能

- **BLE 低功耗蓝牙**：扫描、连接、GATT 服务发现、特征读写、Notify/Indicate
- **经典蓝牙 SPP**：Android 串口通信
- **Wi-Fi 调试**：TCP/UDP Socket 通信
- **数据展示**：ASCII / HEX / Binary / Base64 / UTF-8

## 技术栈

- Flutter 3.41.7
- flutter_blue_plus (BLE)
- flutter_bluetooth_serial (SPP)
- flutter_riverpod + go_router

## Getting Started

```bash
flutter pub get
flutter build apk --debug
```
