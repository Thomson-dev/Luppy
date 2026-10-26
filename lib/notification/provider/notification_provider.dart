import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/Notification.dart';
import '../repository/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (items) => items.where((item) => item.isUnread).length,
    orElse: () => 0,
  );
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  Future<List<AppNotification>> build() {
    return ref.watch(notificationRepositoryProvider).fetchNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    final current = state.value;
    if (current == null) return;

    AppNotification? target;
    for (final notification in current) {
      if (notification.id == notificationId) {
        target = notification;
        break;
      }
    }
    if (target == null || !target.isUnread) return;

    state = AsyncData([
      for (final notification in current)
        if (notification.id == notificationId)
          notification.markAsRead()
        else
          notification,
    ]);

    try {
      await _repository.markAsRead(notificationId);
    } catch (error, stackTrace) {
      state = AsyncData(current);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
