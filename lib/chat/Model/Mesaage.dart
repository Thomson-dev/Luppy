class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  /// True for the right-aligned bubbles (sent by the logged-in user).
  bool isMine(String currentUserId) => senderId == currentUserId;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'].toString(),
    senderId: json['sender_id'] as String,
    text: json['text'] as String,
    sentAt: DateTime.parse(json['sent_at'] as String).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'text': text,
    'sent_at': sentAt.toIso8601String(),
  };
}
