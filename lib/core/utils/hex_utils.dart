class HexUtils {
  static String bytesToHex(List<int> bytes, {String separator = ' '}) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(separator);
  }

  static List<int> hexToBytes(String hex) {
    final cleaned = hex.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length % 2 != 0) throw FormatException('Invalid hex string length');
    return List.generate(cleaned.length ~/ 2, (i) {
      return int.parse(cleaned.substring(i * 2, i * 2 + 2), radix: 16);
    });
  }

  static String bytesToAscii(List<int> bytes) {
    return String.fromCharCodes(bytes.where((b) => b >= 32 && b <= 126));
  }

  static String bytesToBinary(List<int> bytes, {String separator = ' '}) {
    return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join(separator);
  }

  static String bytesToBase64(List<int> bytes) {
    // Simple base64 implementation placeholder
    // In production, use dart:convert's base64Encode
    return 'Base64: ${bytes.length} bytes';
  }

  static String formatBytes(List<int> bytes, String mode) {
    return switch (mode) {
      'hex' => bytesToHex(bytes),
      'ascii' => bytesToAscii(bytes),
      'binary' => bytesToBinary(bytes),
      'base64' => bytesToBase64(bytes),
      _ => bytesToHex(bytes),
    };
  }
}

class CrcUtils {
  static int crc8(List<int> data) {
    int crc = 0xFF;
    for (final byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 0x80) != 0 ? ((crc << 1) ^ 0x31) & 0xFF : (crc << 1) & 0xFF;
      }
    }
    return crc;
  }

  static int crc16(List<int> data, {int poly = 0x8005, int init = 0x0000}) {
    int crc = init;
    for (final byte in data) {
      crc ^= byte << 8;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ poly) & 0xFFFF : (crc << 1) & 0xFFFF;
      }
    }
    return crc;
  }
}
