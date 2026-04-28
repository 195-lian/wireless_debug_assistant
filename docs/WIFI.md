# Wi-Fi 模块开发文档

## 概述

Wi-Fi 模块基于 `dart:io` 的 `Socket` 和 `RawDatagramSocket` 实现，支持三种通信模式：
- **TCP Client**：主动连接到远程服务器
- **TCP Server**：监听端口，接受客户端连接
- **UDP**：无连接的数据报通信

## 抽象接口

```dart
abstract class WifiService {
  // TCP Client
  Future<SocketConnection> tcpConnect(String host, int port);

  // TCP Server
  Future<SocketConnection> tcpListen(int port);
  Stream<SocketConnection> onClientConnected(String serverId);

  // UDP
  Future<SocketConnection> udpBind(int port);
  Future<void> udpSend(String connectionId, String address, int port, List<int> data);

  // Common
  Stream<List<int>> receive(String connectionId);
  Future<void> send(String connectionId, List<int> data);
  Future<void> close(String connectionId);
  Stream<SocketStatus> statusStream(String connectionId);

  // Utilities
  Future<String?> getLocalIp();
  Future<List<Map<String, dynamic>>> portScan(String subnet, int startPort, int endPort);
}
```

## 连接实体

```dart
class SocketConnection {
  final String id;               // UUID
  final String type;             // 'tcpClient' | 'tcpServer' | 'udp'
  final String localAddress;
  final int localPort;
  final String? remoteAddress;   // 仅 tcpClient
  final int? remotePort;         // 仅 tcpClient
  final String status;           // 'connected' | 'listening' | 'closed'
}
```

## TCP Client

```dart
final service = ref.read(wifiServiceProvider);

// 连接远程服务器
final conn = await service.tcpConnect('192.168.1.100', 8080);
print('Connected: ${conn.id}');

// 发送数据
await service.send(conn.id, utf8.encode('Hello'));

// 接收数据
service.receive(conn.id).listen((data) {
  print('Received: ${utf8.decode(data)}');
});

// 关闭连接
await service.close(conn.id);
```

## TCP Server

```dart
// 启动监听
final server = await service.tcpListen(8080);
print('Listening on ${server.localPort}');

// 接受客户端连接
service.onClientConnected(server.id).listen((client) {
  print('Client connected: ${client.remoteAddress}:${client.remotePort}');
});
```

## UDP

```dart
// 绑定本地端口
final conn = await service.udpBind(9090);

// 发送数据到指定地址
await service.udpSend(conn.id, '192.168.1.100', 9090, utf8.encode('Hello UDP'));

// 接收数据
service.receive(conn.id).listen((data) {
  print('Received: ${utf8.decode(data)}');
});
```

## Provider 使用

```dart
// 监听连接列表
final connections = ref.watch(wifiConnectionsProvider);

// 发起 TCP 连接
final notifier = ref.read(wifiConnectionsProvider.notifier);
await notifier.connectTcp('192.168.1.100', 8080);

// 断开连接
await notifier.disconnect(connectionId);

// 发送数据
await notifier.send(connectionId, utf8.encode('data'));
```

## 端口扫描

```dart
final results = await service.portScan('192.168.1', 1, 1000);
// results: [{'ip': '192.168.1.100', 'port': 8080, 'open': true}, ...]
```
