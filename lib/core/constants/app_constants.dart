class AppConstants {
  static const String appName = 'Wireless Debug Assistant';
  static const String appVersion = '1.0.0';

  // BLE
  static const Duration bleScanTimeout = Duration(seconds: 10);
  static const Duration bleConnectionTimeout = Duration(seconds: 10);
  static const int defaultMtu = 512;

  // Classic Bluetooth SPP
  static const String defaultSppUuid = '00001101-0000-1000-8000-00805F9B34FB';

  // Wi-Fi
  static const Duration wifiConnectionTimeout = Duration(seconds: 5);
  static const int defaultTcpPort = 8080;
  static const int defaultUdpPort = 8081;

  // Logs
  static const int maxLogLinesInMemory = 5000;
  static const int logRetentionDays = 30;

  // UI
  static const double compactBreakpoint = 600;
  static const double expandedBreakpoint = 1200;
  static const double sidebarWidth = 280;
}

class DisplayMode {
  static const String ascii = 'ascii';
  static const String hex = 'hex';
  static const String binary = 'binary';
  static const String base64 = 'base64';
  static const String utf8 = 'utf8';
}

