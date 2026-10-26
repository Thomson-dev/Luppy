import 'package:luppy/chat/Model/Mesaage.dart';
import 'package:luppy/home/model/Event.dart';

class Chat {
  final String id;
  final Member user; // the person you are chatting with
  final List<Message> messages;

  const Chat({required this.id, required this.user, this.messages = const []});

  Chat copyWith({List<Message>? messages}) =>
      Chat(id: id, user: user, messages: messages ?? this.messages);

  /// Shown under the name in the Chats list ("OK! sounds good.").
  Message? get lastMessage => messages.isEmpty ? null : messages.last;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'] as String,
    user: Member.fromJson(json['user'] as Map<String, dynamic>),
    messages: (json['messages'] as List? ?? const [])
        .map((m) => Message.fromJson(m as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}

/// Sample chat data matching the Chats screens.
/// Avatar paths are placeholders, same as the other mock data.

const currentUserId = 'u_loki';

DateTime _today(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}

final dummyChats = <Chat>[
  Chat(
    id: 'c1',
    user: const Member(
      id: 'u_luna',
      name: 'Luna Cutipie',
      avatarUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
      isOnline: true,
    ),
    messages: [
      Message(
        id: 'm1',
        senderId: 'u_luna',
        text: 'Hi, Loki',
        sentAt: _today(10, 5),
      ),
      Message(
        id: 'm2',
        senderId: 'u_luna',
        text: 'Are you free today?',
        sentAt: _today(10, 5),
      ),
      Message(
        id: 'm3',
        senderId: currentUserId,
        text: 'Hi, Luna',
        sentAt: _today(10, 7),
      ),
      Message(
        id: 'm4',
        senderId: 'u_luna',
        text: 'OK! sounds good.',
        sentAt: _today(10, 8),
      ),
    ],
  ),
  Chat(
    id: 'c2',
    user: const Member(
      id: 'u_levay',
      name: 'Levay',
      avatarUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
      isOnline: true,
    ),
    messages: [
      Message(
        id: 'm5',
        senderId: 'u_levay',
        text: 'HI Loki \u{1F436}',
        sentAt: _today(10, 5),
      ),
    ],
  ),
  Chat(
    id: 'c3',
    user: const Member(
      id: 'u_bjorn',
      name: 'Bj\u00F6rn the king',
      avatarUrl: 'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2',
    ),
    messages: [
      Message(
        id: 'm6',
        senderId: 'u_bjorn',
        text: 'How are you? I think I saw you at the park yesterday.',
        sentAt: _today(10, 5),
      ),
    ],
  ),
  Chat(
    id: 'c4',
    user: const Member(
      id: 'u_kratus',
      name: 'Kratus \u{1F440}',
      avatarUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a',
    ),
    messages: [
      Message(
        id: 'm7',
        senderId: 'u_kratus',
        text: 'Bye! see you.',
        sentAt: _today(10, 5),
      ),
    ],
  ),
  Chat(
    id: 'c5',
    user: const Member(
      id: 'u_boo',
      name: 'Sleepy Boo \u{1F634}',
      avatarUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d',
    ),
    messages: [
      Message(
        id: 'm8',
        senderId: 'u_boo',
        text: 'Goodnight! \u{1F60A}',
        sentAt: _today(10, 5),
      ),
    ],
  ),
];

// Kept as an alias for existing callers that use the original mock-data name.
final chats = dummyChats;
