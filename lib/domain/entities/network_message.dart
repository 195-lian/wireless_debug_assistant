import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_message.freezed.dart';

enum NetworkMessageDirection { tx, rx }

@freezed
class NetworkMessage with _$NetworkMessage {
  const factory NetworkMessage({
    required String id,
    required String connectionId,
    required List<int> data,
    required NetworkMessageDirection direction,
    required DateTime timestamp,
    String? remoteAddress,
    int? remotePort,
  }) = _NetworkMessage;
}
