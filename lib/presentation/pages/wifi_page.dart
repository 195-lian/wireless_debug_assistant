import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/socket_connection.dart';
import '../providers/wifi_provider.dart';

class WifiPage extends ConsumerStatefulWidget {
  const WifiPage({super.key});

  @override
  ConsumerState<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends ConsumerState<WifiPage> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '8080');
  int _selectedTab = 0;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(wifiConnectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi 调试'),
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(text: 'TCP 客户端', icon: Icon(Icons.device_hub)),
            Tab(text: 'TCP 服务端', icon: Icon(Icons.dns)),
            Tab(text: 'UDP', icon: Icon(Icons.send)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildConnectionForm(),
          const Divider(),
          Expanded(
            child: connections.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_tethering, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text('无活跃连接', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final conn = connections[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            conn.type == SocketType.tcpClient
                                ? Icons.device_hub
                                : conn.type == SocketType.tcpServer
                                    ? Icons.dns
                                    : Icons.send,
                            color: AppColors.accent,
                          ),
                          title: Text(
                            '${conn.localAddress}:${conn.localPort}',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            conn.remoteAddress != null
                                ? 'Remote: ${conn.remoteAddress}:${conn.remotePort}'
                                : 'Status: ${conn.status.name}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: AppColors.error),
                            onPressed: () {
                              ref.read(wifiConnectionsProvider.notifier).disconnect(conn.id);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedTab == 0) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: '主机地址',
                      hintText: '192.168.1.100',
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: '端口',
                      hintText: '8080',
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final host = _hostController.text.trim();
                  final port = int.tryParse(_portController.text.trim()) ?? 8080;
                  if (host.isNotEmpty) {
                    ref.read(wifiConnectionsProvider.notifier).connectTcp(host, port);
                  }
                },
                icon: const Icon(Icons.connect_without_contact),
                label: const Text('连接'),
              ),
            ),
          ] else if (_selectedTab == 1) ...[
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: '监听端口',
                hintText: '8080',
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final port = int.tryParse(_portController.text.trim()) ?? 8080;
                  ref.read(wifiConnectionsProvider.notifier).startServer(port);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始监听'),
              ),
            ),
          ] else ...[
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: '本地端口',
                hintText: '8081',
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final port = int.tryParse(_portController.text.trim()) ?? 8081;
                  ref.read(wifiConnectionsProvider.notifier).bindUdp(port);
                },
                icon: const Icon(Icons.radio_button_checked),
                label: const Text('绑定 UDP'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
