/// Models for the Notifications screen.

/// The six kinds of notification in the design. Each one has its own
/// button label ("Send A Message", "Attend", ...).
enum NotificationType {
  newMatch('Send A Message'),
  like("Check Bark's Profile"),
  message('Send A Message'),
  playdateInvite('Check The Invitation'),
  newEvent('Attend'),
  boosted('Check Details');

  final String actionLabel;
  const NotificationType(this.actionLabel);
}

/// (Named AppNotification because Flutter already has a `Notification` class.)
class AppNotification {
  final String id;
  final NotificationType type;

  /// Full sentence, e.g. "Björn Twain has liked your dog, Loki!"
  final String text;

  /// The part of [text] shown in bold, e.g. "Björn Twain". Null for none.
  final String? highlight;

  final String avatarUrl;
  final bool isOnline; // green dot on the avatar
  final bool isUnread; // unread cards get the pink border
  final DateTime createdAt;

  /// What the button opens: a dog, chat, or event id.
  final String? targetId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.text,
    this.highlight,
    required this.avatarUrl,
    this.isOnline = false,
    this.isUnread = true,
    required this.createdAt,
    this.targetId,
  });

  /// Same notification, but read.
  AppNotification markAsRead() => AppNotification(
    id: id,
    type: type,
    text: text,
    highlight: highlight,
    avatarUrl: avatarUrl,
    isOnline: isOnline,
    isUnread: false,
    createdAt: createdAt,
    targetId: targetId,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: NotificationType.values.byName(json['type'] as String),
        text: json['text'] as String,
        highlight: json['highlight'] as String?,
        avatarUrl: json['avatar_url'] as String,
        isOnline: json['is_online'] as bool? ?? false,
        isUnread: json['is_unread'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        targetId: json['target_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'text': text,
    'highlight': highlight,
    'avatar_url': avatarUrl,
    'is_online': isOnline,
    'is_unread': isUnread,
    'created_at': createdAt.toIso8601String(),
    'target_id': targetId,
  };
}
