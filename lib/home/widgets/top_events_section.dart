import 'package:flutter/material.dart';
import 'package:luppy/home/model/Event.dart';
import 'package:luppy/theme/app_theme.dart';
import 'package:luppy/utils/image_helper.dart';

/// "Top Events" section: title row with "See All" and a horizontal list of
/// event cards (date, title, venue, description, member avatars, Join button).
class TopEventsSection extends StatelessWidget {
  final List<Event> events;
  final String title;
  final VoidCallback? onSeeAll;
  final ValueChanged<Event>? onEventTap;
  final ValueChanged<Event>? onJoin;

  const TopEventsSection({
    super.key,
    required this.events,
    this.title = 'Top Events',
    this.onSeeAll,
    this.onEventTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: text.titleLarge),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: text.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => EventCard(
                event: events[i],
                onTap: onEventTap == null ? null : () => onEventTap!(events[i]),
                onJoin: onJoin == null ? null : () => onJoin!(events[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  static const double width = 300;
  static const _gold = Color(0xFFFECC66);
  static const _joinGradient = LinearGradient(
    colors: [Color(0xFFE9525F), Color(0xFFEF7D85)],
  );

  const EventCard({super.key, required this.event, this.onTap, this.onJoin});

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get _dateLabel {
    final d = event.startsAt;
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dateLabel,
              style: text.bodySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(color: _gold),
                  ),
                ),
                if (event.location.venueName != null) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    event.location.venueName!,
                    style: text.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 7),
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(color: Colors.white),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: _MemberStack(members: event.members)),
                _JoinButton(joined: event.hasJoined, onPressed: onJoin),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlapping member avatars followed by a "..." bubble when there are more.
class _MemberStack extends StatelessWidget {
  final List<Member> members;
  static const int maxShown = 5;

  const _MemberStack({required this.members});

  static const double _size = 29;
  static const double _step = 17; // < size so the avatars overlap

  ImageProvider _image(String url) => appImageProvider(url);

  @override
  Widget build(BuildContext context) {
    final shown = members.take(maxShown).toList();
    final hasMore = members.length > maxShown;
    final slots = shown.length + (hasMore ? 1 : 0);

    return SizedBox(
      height: _size,
      width: slots == 0 ? 0 : _step * (slots - 1) + _size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * _step,
              child: CircleAvatar(
                radius: _size / 2,
                backgroundColor: AppColors.surface,
                child: CircleAvatar(
                  radius: _size / 2 - 1.5,
                  backgroundColor: const Color(0xFF2A2A30),
                  backgroundImage: _image(shown[i].avatarUrl),
                  onBackgroundImageError: (_, __) {},
                ),
              ),
            ),
          if (hasMore)
            Positioned(
              left: shown.length * _step,
              child: const CircleAvatar(
                radius: _size / 2,
                backgroundColor: Color(0xFFE6E0F2),
                child: Icon(Icons.more_horiz, size: 14, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final bool joined;
  final VoidCallback? onPressed;

  const _JoinButton({required this.joined, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final color = joined ? Colors.white54 : const Color(0xFFE9525F);

    return SizedBox(
      width: 80,
      height: 35,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: joined ? null : EventCard._joinGradient,
          borderRadius: BorderRadius.circular(13),
          border: joined ? Border.all(color: color) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11.5),
            ),
            child: SizedBox.expand(
              child: TextButton(
                onPressed: joined ? null : onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  disabledForegroundColor: color,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.5),
                  ),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: Text(joined ? 'Joined' : 'Join Us'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
