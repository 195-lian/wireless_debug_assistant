enum SocketType { tcpClient, tcpServer, udp }

enum SocketStatus { disconnected, connecting, connected, listening, error }

class SocketConnection {
  final String id;
  final SocketType type;
  final String localAddress;
  final int localPort;
  final String? remoteAddress;
  final int? remotePort;
  final SocketStatus status;
  final DateTime createdAt;

  SocketConnection({
    required this.id,
    required this.type,
    required this.localAddress,
    required this.localPort,
    this.remoteAddress,
    this.remotePort,
    this.status = SocketStatus.disconnected,
    required this.createdAt,
  });
}
