import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/bluetooth_provider.dart';

class BleDevicePage extends ConsumerStatefulWidget {
  final String deviceId;
  final String deviceName;

  const BleDevicePage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  ConsumerState<BleDevicePage> createState() => _BleDevicePageState();
}

class _BleDevicePageState extends ConsumerState<BleDevicePage> {
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(bleConnectionProvider(widget.deviceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        actions: [
          if (!_isConnected)
            TextButton.icon(
              onPressed: _isConnecting
                  ? null
                  : () async {
                      setState(() => _isConnecting = true);
                      await ref.read(bleScanProvider.notifier).connect(widget.deviceId);
                      setState(() {
                        _isConnecting = false;
                        _isConnected = true;
                      });
                    },
              icon: _isConnecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link),
              label: Text(_isConnecting ? '连接中' : '连接'),
            )
          else
            TextButton.icon(
              onPressed: () async {
                await ref.read(bleScanProvider.notifier).disconnect(widget.deviceId);
                setState(() => _isConnected = false);
              },
              icon: const Icon(Icons.link_off, color: AppColors.error),
              label: const Text('断开', style: TextStyle(color: AppColors.error)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: connectionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('连接错误: $err', style: const TextStyle(color: AppColors.error)),
        ),
        data: (state) {
          if (state == BtConnectionState.connected) {
            return _buildConnectedView();
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state == BtConnectionState.connecting ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  state == BtConnectionState.connecting ? '正在连接设备...' : '设备未连接',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectedView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '服务', icon: Icon(Icons.list)),
              Tab(text: '通信', icon: Icon(Icons.chat)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildServicesTab(),
                _buildCommunicationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return const Center(
      child: Text(
        'GATT 服务列表（开发中）',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildCommunicationTab() {
    return const Center(
      child: Text(
        '数据通信（开发中）',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
