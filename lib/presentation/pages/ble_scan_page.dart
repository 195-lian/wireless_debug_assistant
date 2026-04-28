import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/bluetooth_provider.dart';
import 'ble_device_page.dart';

class BleScanPage extends ConsumerStatefulWidget {
  const BleScanPage({super.key});

  @override
  ConsumerState<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends ConsumerState<BleScanPage> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(bleScanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙调试'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: () {
              if (_isScanning) {
                ref.read(bleScanProvider.notifier).stopScan();
                setState(() => _isScanning = false);
              } else {
                ref.read(bleScanProvider.notifier).startScan();
                setState(() => _isScanning = true);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: scanState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
        ),
        data: (devices) {
          if (devices.isEmpty && !_isScanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_disabled, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('点击右上角刷新开始扫描', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _DeviceCard(
                device: device,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BleDevicePage(deviceId: device.id, deviceName: device.name ?? 'Unknown'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final dynamic device;
  final VoidCallback onTap;

  const _DeviceCard({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rssi = device.rssi as int;
    final signalStrength = _getSignalStrength(rssi);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: signalStrength.color,
        ),
        title: Text(
          device.name ?? 'Unknown Device',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.id,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: signalStrength.factor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: signalStrength.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$rssi dBm',
                  style: TextStyle(fontSize: 11, color: signalStrength.color),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  ({Color color, double factor}) _getSignalStrength(int rssi) {
    if (rssi >= -50) return (color: AppColors.txColor, factor: 1.0);
    if (rssi >= -70) return (color: AppColors.accent, factor: 0.7);
    if (rssi >= -90) return (color: AppColors.warning, factor: 0.4);
    return (color: AppColors.error, factor: 0.2);
  }
}
