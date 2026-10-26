import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/notification/model/Notification.dart';
import 'package:luppy/notification/provider/notification_provider.dart';
import 'package:luppy/utils/image_helper.dart';

const _pink = Color(0xFFE8505F);
const _crimson = Color(0xFFC2305A);
const _gray = Color(0xFF6B6776);

ImageProvider _image(String url) => appImageProvider(url);

/// The three button looks in the design.
enum _ButtonLook { outlined, filled, muted }

_ButtonLook _lookFor(NotificationType type) => switch (type) {
  NotificationType.newMatch => _ButtonLook.outlined,
  NotificationType.message => _ButtonLook.outlined,
  NotificationType.like => _ButtonLook.filled,
  NotificationType.newEvent => _ButtonLook.filled,
  NotificationType.playdateInvite => _ButtonLook.muted,
  NotificationType.boosted => _ButtonLook.muted,
};

// ─────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────

class NotificationScreen extends ConsumerStatefulWidget {
  /// Called when a card's button is pressed (open the chat, event, ...).
  final ValueChanged<AppNotification>? onAction;

  const NotificationScreen({super.key, this.onAction});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Future<void> _onActionPressed(AppNotification item) async {
    try {
      await ref.read(notificationsProvider.notifier).markAsRead(item.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not mark as read. Try again.')),
        );
      }
    }
    widget.onAction?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          behavior: HitTestBehavior.opaque,
          child: const Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.arrow_back_ios_new, size: 16),
              SizedBox(width: 8),
              Text('Back', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF14151A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Stay up to date with new matches, direct messages, nearby playdates, and pet community events.',
                    style: TextStyle(color: Color(0xFFB4B4BC), fontSize: 13, height: 1.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK', style: TextStyle(color: _pink)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _pink)),
        error: (error, stackTrace) =>
            _ErrorState(onRetry: () => ref.invalidate(notificationsProvider)),
        data: (notifications) {
          if (notifications.isEmpty) return const _EmptyState();

          return RefreshIndicator(
            color: _pink,
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _NotificationCard(
                notification: notifications[i],
                onActionPressed: () => _onActionPressed(notifications[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 48, color: _gray),
            const SizedBox(height: 12),
            Text(
              'No notifications yet.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: _gray),
            const SizedBox(height: 12),
            Text(
              'Failed to load notifications.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _pink),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onActionPressed;

  const _NotificationCard({
    required this.notification,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Unread: dark with a pink border. Read: lighter, no border.
        color: n.isUnread ? const Color(0xFF0B0B0D) : const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(12),
        border: n.isUnread ? Border.all(color: _pink.withOpacity(0.7)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(url: n.avatarUrl, isOnline: n.isOnline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MessageText(text: n.text, highlight: n.highlight),
                const SizedBox(height: 10),
                _ActionButton(
                  label: n.type.actionLabel,
                  look: _lookFor(n.type),
                  onTap: onActionPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows [text] with the [highlight] part in bold white.
class _MessageText extends StatelessWidget {
  final String text;
  final String? highlight;

  const _MessageText({required this.text, this.highlight});

  @override
  Widget build(BuildContext context) {
    const normal = TextStyle(
      fontSize: 14,
      color: Color(0xFFD6D6DC),
      height: 1.4,
    );
    const bold = TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      height: 1.4,
    );

    final start = highlight == null ? -1 : text.indexOf(highlight!);
    if (start == -1) return Text(text, style: normal);

    final end = start + highlight!.length;
    return Text.rich(
      TextSpan(
        style: normal,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(text: highlight, style: bold),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final _ButtonLook look;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.look,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = switch (look) {
      _ButtonLook.outlined => Colors.transparent,
      _ButtonLook.filled => _crimson,
      _ButtonLook.muted => _gray,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: look == _ButtonLook.outlined
              ? Border.all(color: _pink)
              : null,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final bool isOnline;

  const _Avatar({required this.url, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF1E1E1E),
            backgroundImage: _image(url),
            onBackgroundImageError: (_, __) {},
          ),
          if (isOnline)
            Positioned(
              right: 2,
              bottom: 4,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0xFF22DD3A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B0B0D),
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
