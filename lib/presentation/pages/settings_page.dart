import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _buildSectionHeader('外观'),
        _buildSettingTile(
          icon: Icons.dark_mode,
          title: '主题模式',
          subtitle: '深色 / 浅色 / 跟随系统',
          trailing: DropdownButton<ThemeMode>(
            value: ThemeMode.dark,
            dropdownColor: AppColors.bgSecondary,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('浅色')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('深色')),
            ],
            onChanged: (mode) {
              // TODO: implement theme switching
            },
          ),
        ),
        _buildSectionHeader('蓝牙'),
        _buildSettingTile(
          icon: Icons.bluetooth,
          title: '默认显示格式',
          subtitle: 'HEX / ASCII / UTF-8',
          trailing: DropdownButton<String>(
            value: 'hex',
            dropdownColor: AppColors.bgSecondary,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'hex', child: Text('HEX')),
              DropdownMenuItem(value: 'ascii', child: Text('ASCII')),
              DropdownMenuItem(value: 'utf8', child: Text('UTF-8')),
            ],
            onChanged: (format) {
              // TODO: implement format switching
            },
          ),
        ),
        _buildSettingTile(
          icon: Icons.timer,
          title: '扫描超时',
          subtitle: '10 秒',
        ),
        _buildSectionHeader('Wi-Fi'),
        _buildSettingTile(
          icon: Icons.wifi,
          title: '默认 TCP 端口',
          subtitle: '8080',
        ),
        _buildSettingTile(
          icon: Icons.router,
          title: '默认 UDP 端口',
          subtitle: '8081',
        ),
        _buildSectionHeader('日志'),
        _buildSettingTile(
          icon: Icons.storage,
          title: '内存日志条数上限',
          subtitle: '5000 条',
        ),
        _buildSettingTile(
          icon: Icons.delete_outline,
          title: '自动清理历史日志',
          subtitle: '保留 30 天',
        ),
        _buildSectionHeader('关于'),
        _buildSettingTile(
          icon: Icons.info_outline,
          title: '版本',
          subtitle: '1.0.0',
        ),
        _buildSettingTile(
          icon: Icons.description,
          title: '开源协议',
          subtitle: 'MIT License',
          onTap: () {
            // TODO: show license
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
