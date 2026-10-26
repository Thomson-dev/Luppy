import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/Notification.dart';

class NotificationRepository {
  static const _fallbackAvatar =
      'https://images.unsplash.com/photo-1517849845537-4d257902454a';

  NotificationRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<AppNotification>> fetchNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before loading notifications.');
    }

    final rows = await _supabase
        .from('notifications')
        .select(
          'id, actor_id, type, text, highlight, target_id, is_unread, created_at',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (rows.isEmpty) return [];

    final actorIds = <String>{
      for (final row in rows)
        if (row['actor_id'] != null) row['actor_id'] as String,
    };
    final actors = actorIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await _supabase
              .from('profiles')
              .select('id, avatar_url')
              .inFilter('id', actorIds.toList());
    final avatarByActor = {
      for (final actor in actors)
        actor['id'] as String: actor['avatar_url'] as String? ?? '',
    };

    return rows.map((row) {
      final actorId = row['actor_id'] as String?;
      final avatarUrl = avatarByActor[actorId] ?? '';
      return AppNotification.fromJson({
        'id': row['id'] as String,
        'type': row['type'] as String,
        'text': row['text'] as String,
        'highlight': row['highlight'] as String?,
        'avatar_url': avatarUrl.isEmpty ? _fallbackAvatar : avatarUrl,
        'is_online': false,
        'is_unread': row['is_unread'] as bool? ?? true,
        'created_at': row['created_at'] as String,
        'target_id': row['target_id'] as String?,
      });
    }).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_unread': false})
        .eq('id', notificationId);
  }
}
