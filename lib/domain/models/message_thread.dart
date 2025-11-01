import 'message.dart';

class MessageThread {
  const MessageThread({
    required this.itemId,
    required this.itemName,
    required this.messages,
  });

  final String itemId;
  final String itemName;
  final List<Message> messages;

  MessageThread copyWith({
    String? itemId,
    String? itemName,
    List<Message>? messages,
  }) {
    return MessageThread(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      messages: messages ?? List<Message>.from(this.messages),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      itemId: json['itemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? '',
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((data) => Message.fromJson(data as Map<String, dynamic>))
          .toList(),
    );
  }
}
