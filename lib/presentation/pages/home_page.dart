import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'ble_scan_page.dart';
import 'settings_page.dart';
import 'toolbox_page.dart';
import 'wifi_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<_NavigationItem> _items = [
    _NavigationItem(
      icon: Icons.bluetooth,
      label: '蓝牙',
      page: const BleScanPage(),
    ),
    _NavigationItem(
      icon: Icons.wifi,
      label: 'Wi-Fi',
      page: const WifiPage(),
    ),
    _NavigationItem(
      icon: Icons.build,
      label: '工具箱',
      page: const ToolboxPage(),
    ),
    _NavigationItem(
      icon: Icons.settings,
      label: '设置',
      page: const SettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _items.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  _NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}
