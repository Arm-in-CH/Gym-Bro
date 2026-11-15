import '../core/storage/safe_cast.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isError': isError,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: SafeCast.toStringVal(json['id']),
        text: SafeCast.toStringVal(json['text']),
        isUser: SafeCast.toBool(json['isUser'], false),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            SafeCast.toInt(json['timestamp'], 0)),
        isError: SafeCast.toBool(json['isError'], false),
      );
}
