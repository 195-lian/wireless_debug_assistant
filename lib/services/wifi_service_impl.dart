import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../domain/entities/socket_connection.dart';
import 'wifi_service.dart';

class WifiServiceImpl implements WifiService {
  final _connections = <String, SocketConnection>{};
  final _serverSockets = <String, ServerSocket>{};
  final _sockets = <String, Socket>{};
  final _udpSockets = <String, RawDatagramSocket>{};
  final _receiveControllers = <String, StreamController<List<int>>>{};
  final _statusControllers = <String, StreamController<SocketStatus>>{};
  final _clientControllers = <String, StreamController<SocketConnection>>{};

  @override
  Future<SocketConnection> tcpConnect(String host, int port) async {
    final socket = await Socket.connect(host, port);
    final id = _generateId();
    final connection = SocketConnection(
      id: id,
      type: SocketType.tcpClient,
      localAddress: socket.address.address,
      localPort: socket.port,
      remoteAddress: host,
      remotePort: port,
      status: SocketStatus.connected,
      createdAt: DateTime.now(),
    );

    _connections[id] = connection;
    _sockets[id] = socket;
    _receiveControllers[id] = StreamController<List<int>>.broadcast();
    _statusControllers[id] = StreamController<SocketStatus>.broadcast();

    socket.listen(
      (data) => _receiveControllers[id]?.add(data),
      onDone: () => _updateStatus(id, SocketStatus.disconnected),
      onError: (_) => _updateStatus(id, SocketStatus.error),
    );

    return connection;
  }

  @override
  Future<SocketConnection> tcpListen(int port) async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    final id = _generateId();
    final connection = SocketConnection(
      id: id,
      type: SocketType.tcpServer,
      localAddress: server.address.address,
      localPort: server.port,
      status: SocketStatus.listening,
      createdAt: DateTime.now(),
    );

    _connections[id] = connection;
    _serverSockets[id] = server;
    _clientControllers[id] = StreamController<SocketConnection>.broadcast();

    server.listen((socket) {
      final clientId = _generateId();
      final clientConn = SocketConnection(
        id: clientId,
        type: SocketType.tcpClient,
        localAddress: socket.address.address,
        localPort: socket.port,
        remoteAddress: socket.remoteAddress.address,
        remotePort: socket.remotePort,
        status: SocketStatus.connected,
        createdAt: DateTime.now(),
      );

      _connections[clientId] = clientConn;
      _sockets[clientId] = socket;
      _receiveControllers[clientId] = StreamController<List<int>>.broadcast();
      _statusControllers[clientId] = StreamController<SocketStatus>.broadcast();

      socket.listen(
        (data) => _receiveControllers[clientId]?.add(data),
        onDone: () => _updateStatus(clientId, SocketStatus.disconnected),
        onError: (_) => _updateStatus(clientId, SocketStatus.error),
      );

      _clientControllers[id]?.add(clientConn);
    });

    return connection;
  }

  @override
  Stream<SocketConnection> onClientConnected(String serverId) {
    return _clientControllers[serverId]?.stream ?? const Stream.empty();
  }

  @override
  Future<SocketConnection> udpBind(int port) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    socket.broadcastEnabled = true;

    final id = _generateId();
    final connection = SocketConnection(
      id: id,
      type: SocketType.udp,
      localAddress: socket.address.address,
      localPort: socket.port,
      status: SocketStatus.connected,
      createdAt: DateTime.now(),
    );

    _connections[id] = connection;
    _udpSockets[id] = socket;
    _receiveControllers[id] = StreamController<List<int>>.broadcast();
    _statusControllers[id] = StreamController<SocketStatus>.broadcast();

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          _receiveControllers[id]?.add(datagram.data);
        }
      }
    });

    return connection;
  }

  @override
  Future<void> udpSend(String connectionId, String address, int port, List<int> data) async {
    final socket = _udpSockets[connectionId];
    if (socket != null) {
      socket.send(Uint8List.fromList(data), InternetAddress(address), port);
    }
  }

  @override
  Stream<List<int>> receive(String connectionId) {
    return _receiveControllers[connectionId]?.stream ?? const Stream.empty();
  }

  @override
  Future<void> send(String connectionId, List<int> data) async {
    final socket = _sockets[connectionId];
    if (socket != null) {
      socket.add(Uint8List.fromList(data));
    }
  }

  @override
  Future<void> close(String connectionId) async {
    await _sockets[connectionId]?.close();
    await _serverSockets[connectionId]?.close();
    _udpSockets[connectionId]?.close();

    _connections.remove(connectionId);
    _sockets.remove(connectionId);
    _serverSockets.remove(connectionId);
    _udpSockets.remove(connectionId);

    await _receiveControllers[connectionId]?.close();
    await _statusControllers[connectionId]?.close();
    _receiveControllers.remove(connectionId);
    _statusControllers.remove(connectionId);
  }

  @override
  Stream<SocketStatus> statusStream(String connectionId) {
    return _statusControllers[connectionId]?.stream ?? const Stream.empty();
  }

  @override
  Future<String?> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
      return interfaces.firstOrNull?.addresses.firstOrNull?.address;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> portScan(String subnet, int startPort, int endPort) async {
    final results = <Map<String, dynamic>>[];
    final futures = <Future<void>>[];

    for (int port = startPort; port <= endPort; port++) {
      futures.add(
        Socket.connect(subnet, port, timeout: const Duration(milliseconds: 200))
            .then((socket) {
          results.add({'host': subnet, 'port': port, 'open': true});
          socket.close();
        }).catchError((_) {
          results.add({'host': subnet, 'port': port, 'open': false});
        }),
      );
    }

    await Future.wait(futures);
    return results.where((r) => r['open'] == true).toList();
  }

  void _updateStatus(String id, SocketStatus status) {
    _statusControllers[id]?.add(status);
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  void dispose() {
    for (final socket in _sockets.values) {
      socket.close();
    }
    for (final server in _serverSockets.values) {
      server.close();
    }
    for (final socket in _udpSockets.values) {
      socket.close();
    }
    for (final controller in _receiveControllers.values) {
      controller.close();
    }
    for (final controller in _statusControllers.values) {
      controller.close();
    }
    for (final controller in _clientControllers.values) {
      controller.close();
    }
  }
}
