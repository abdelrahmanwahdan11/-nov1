class Message {
  const Message({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isBuyer,
  });

  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isBuyer;

  Message copyWith({
    String? sender,
    String? content,
    DateTime? timestamp,
    bool? isBuyer,
  }) {
    return Message(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isBuyer: isBuyer ?? this.isBuyer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isBuyer': isBuyer,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int? ?? 0),
      isBuyer: json['isBuyer'] as bool? ?? false,
    );
  }
}
