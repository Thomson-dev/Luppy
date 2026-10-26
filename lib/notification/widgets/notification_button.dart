import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/notification/View/NotificationScreen.dart';
import 'package:luppy/notification/provider/notification_provider.dart';

/// Bell icon that opens the notifications screen and shows a dot when there
/// are unread notifications.
class NotificationButton extends ConsumerWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(unreadNotificationsCountProvider) > 0;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
      icon: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Image.asset('assets/Notification 4.png', width: 28, height: 28),
            if (hasUnread)
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5C842),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
