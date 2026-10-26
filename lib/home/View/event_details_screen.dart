import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/home/model/Event.dart';
import 'package:luppy/home/provider/event_provider.dart';
import 'package:luppy/home/widgets/create_event_sheet.dart';
import 'package:luppy/utils/image_helper.dart';

/// Event Details screen: name, description, date/time, location, members,
/// group admin, and the Join Us / Create Event actions.
class EventDetailsScreen extends ConsumerWidget {
  final Event event;
  final VoidCallback? onJoin;
  final VoidCallback? onCreateEvent;
  final VoidCallback? onSeeAllMembers;
  final VoidCallback? onAddMember;
  final VoidCallback? onInfo;

  const EventDetailsScreen({
    super.key,
    required this.event,
    this.onJoin,
    this.onCreateEvent,
    this.onSeeAllMembers,
    this.onAddMember,
    this.onInfo,
  });

  static const _pink = Color(0xFFE8505F);
  static const _pinkLight = Color(0xFFF08A93);
  static const _online = Color(0xFF22DD3A);

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  static String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  /// e.g. "October 28, 2023 . 10:00 AM - 2:00 PM"
  String _dateTimeLabel(Event ev) {
    final s = ev.startsAt;
    return '${_months[s.month - 1]} ${s.day}, ${s.year} . '
        '${_time(s)} - ${_time(ev.endsAt)}';
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14151A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Event Info & Rules', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• All dogs must be vaccinated and socialized.\n'
                '• Please keep leashes handy at all times.\n'
                '• Bring fresh water and cleanup bags.\n'
                '• Be respectful of other owners and their pets.',
                style: TextStyle(color: Color(0xFFB4B4BC), fontSize: 13, height: 1.6),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: _pink)),
          ),
        ],
      ),
    );
  }

  void _showMembersSheet(BuildContext context, List<Member> members) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14151A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Event Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (members.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No other members joined yet. Be the first!',
                      style: TextStyle(color: Color(0xFF7C7C86)),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF2E2E36)),
                    itemBuilder: (context, i) {
                      final m = members[i];
                      return ListTile(
                        leading: _Avatar(member: m, size: 40),
                        title: Text(m.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          m.isOnline ? 'Online' : 'Member',
                          style: TextStyle(
                            color: m.isOnline ? _online : const Color(0xFF7C7C86),
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    // Reactively watch events list to get up-to-date join status
    final eventsState = ref.watch(topEventsProvider);
    final currentEvent = eventsState.value?.where((e) => e.id == event.id).firstOrNull ?? event;
    final hasJoined = currentEvent.hasJoined;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onInfo ?? () => _showInfoDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Field(
                      label: 'Event Name',
                      child: Text(
                        currentEvent.name,
                        style: text.headlineMedium?.copyWith(fontSize: 22),
                      ),
                    ),
                    _Field(
                      label: 'Event Description',
                      child: Text(
                        currentEvent.description,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    _Field(
                      label: 'Event Date & Time',
                      child: Text(
                        _dateTimeLabel(currentEvent),
                        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _Field(
                      label: 'Event Location',
                      child: Text(
                        currentEvent.location.address,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    _Field(
                      label: 'Members',
                      trailing: GestureDetector(
                        onTap: onSeeAllMembers ?? () => _showMembersSheet(context, currentEvent.members),
                        child: Text(
                          'See All',
                          style: text.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ),
                      child: _MembersRow(
                        members: currentEvent.members,
                        onAdd: onAddMember ?? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invite link copied to clipboard!')),
                          );
                        },
                      ),
                    ),
                    _Field(
                      label: 'Group Admin',
                      child: Row(
                        children: [
                          _Avatar(member: currentEvent.admin, size: 40),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentEvent.admin.name, style: text.titleMedium),
                              Text('Admin', style: text.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  _GradientButton(
                    label: hasJoined ? 'Joined' : 'Join Us',
                    onPressed: hasJoined
                        ? null
                        : () {
                            if (onJoin != null) {
                              onJoin!();
                            } else {
                              ref.read(topEventsProvider.notifier).joinEvent(currentEvent.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('You joined ${currentEvent.name}!'),
                                  backgroundColor: _pink,
                                ),
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: onCreateEvent ?? () => showCreateEventSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: _pink),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: text.labelLarge,
                      ),
                      child: const Text('Create Event'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Muted label above a value, with an optional widget on the label row's right.
class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _Field({required this.label, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: text.bodyMedium?.copyWith(color: Colors.white70)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Member member;
  final double size;

  const _Avatar({required this.member, required this.size});

  ImageProvider get _image => appImageProvider(member.avatarUrl);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: const Color(0xFF1E1E1E),
            backgroundImage: _image,
            onBackgroundImageError: (_, __) {},
          ),
          if (member.isOnline)
            Positioned(
              right: 0,
              bottom: 1,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: EventDetailsScreen._online,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0B0B0D), width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MembersRow extends StatelessWidget {
  final List<Member> members;
  final VoidCallback? onAdd;

  const _MembersRow({required this.members, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final m in members) ...[
            _Avatar(member: m, size: 46),
            const SizedBox(width: 10),
          ],
          GestureDetector(
            onTap: onAdd,
            child: CustomPaint(
              painter: _DashedCirclePainter(color: EventDetailsScreen._pink),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(Icons.add, size: 18, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashes = 20;
    const sweep = 2 * math.pi / dashes;
    final rect = Offset.zero & size;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect.deflate(0.5), i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.color != color;
}

/// Pink gradient button. ElevatedButton can't paint gradients, so this wraps
/// an InkWell in a decorated container.
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GradientButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [EventDetailsScreen._pinkLight, EventDetailsScreen._pink],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Center(
                child: Text(label, style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
