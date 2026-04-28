import '../domain/entities/socket_connection.dart';

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
