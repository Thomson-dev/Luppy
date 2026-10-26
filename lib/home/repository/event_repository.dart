import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/Event.dart';

class EventRepository {
  static const _fallbackAvatar =
      'https://images.unsplash.com/photo-1517849845537-4d257902454a';

  EventRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<List<Event>> getTopEvents() async {
    try {
      final events = await _supabase
          .from('events')
          .select()
          .gte('starts_at', DateTime.now().toUtc().toIso8601String())
          .order('starts_at')
          .limit(10);

      if (events.isEmpty) return _fallbackEvents();

      final eventIds = events.map((row) => row['id'] as String).toList();
      final memberRows = await _supabase
          .from('event_members')
          .select('event_id, user_id')
          .inFilter('event_id', eventIds);

      final userIds = <String>{
        for (final row in events) row['admin_id'] as String,
        for (final row in memberRows) row['user_id'] as String,
      };
      final profiles = userIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await _supabase
                .from('profiles')
                .select('id, display_name, avatar_url')
                .inFilter('id', userIds.toList());
      final profileById = {
        for (final profile in profiles)
          profile['id'] as String: profile,
      };
      final membersByEvent = <String, List<Member>>{};
      for (final row in memberRows) {
        final eventId = row['event_id'] as String;
        final userId = row['user_id'] as String;
        final profile = profileById[userId];
        if (profile == null) continue;
        membersByEvent.putIfAbsent(eventId, () => []).add(_member(profile));
      }

      final currentUserId = _supabase.auth.currentUser?.id;
      final joinedEventIds = memberRows
          .where((row) => row['user_id'] == currentUserId)
          .map((row) => row['event_id'] as String)
          .toSet();

      return events.map((row) {
        final eventId = row['id'] as String;
        final adminId = row['admin_id'] as String;
        final adminProfile = profileById[adminId];
        final admin = adminProfile == null
            ? Member(
                id: adminId,
                name: 'Event host',
                avatarUrl: _fallbackAvatar,
              )
            : _member(adminProfile);
        return Event(
          id: eventId,
          name: row['name'] as String,
          description: row['description'] as String? ?? '',
          startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
          endsAt: DateTime.parse(row['ends_at'] as String).toLocal(),
          location: EventLocation(
            venueName: row['venue_name'] as String?,
            address: row['address'] as String,
          ),
          members: membersByEvent[eventId] ?? const [],
          admin: admin,
          hasJoined: joinedEventIds.contains(eventId),
        );
      }).toList();
    } catch (_) {
      return _fallbackEvents();
    }
  }

  List<Event> _fallbackEvents() {
    final now = DateTime.now();
    final luna = Member(
      id: 'u_luna',
      name: 'Luna Cutipie',
      avatarUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a',
      isOnline: true,
    );
    final members = [
      Member(
        id: 'm1',
        name: 'Mochi',
        avatarUrl: 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8',
      ),
      Member(
        id: 'm2',
        name: 'Rex',
        avatarUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
      ),
      Member(
        id: 'm3',
        name: 'Coco',
        avatarUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
        isOnline: true,
      ),
      Member(
        id: 'm4',
        name: 'Shadow',
        avatarUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d',
      ),
    ];
    return [
      Event(
        id: 'e1',
        name: 'Puppy Playdate',
        description:
            'Bring your furry friend for a day of fun and socialization with '
            'other puppies. There will be toys, treats and plenty of space to run.',
        startsAt: now.add(const Duration(days: 3)),
        endsAt: now.add(const Duration(days: 3, hours: 4)),
        location: const EventLocation(
          venueName: 'Dog Park',
          address: 'Dog Park, Anytown, CA 12345',
        ),
        members: members,
        admin: luna,
      ),
      Event(
        id: 'e2',
        name: 'Dog Costume Contest',
        description:
            'Dress up your dog in their most outrageous costume for a chance to '
            'win prizes! There will be categories for funniest, most creative, '
            'and best overall costume.',
        startsAt: now.add(const Duration(days: 10)),
        endsAt: now.add(const Duration(days: 10, hours: 4)),
        location: const EventLocation(
          venueName: 'Bark Park',
          address: 'Bark Park 123 Main Street, Anytown, CA 12345',
        ),
        members: members,
        admin: luna,
      ),
    ];
  }

  Future<void> joinEvent(String eventId) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('event_members').insert({
          'event_id': eventId,
          'user_id': user.id,
        });
      } catch (_) {}
    }
  }

  Future<void> createEvent({
    required String name,
    required String description,
    required String address,
    required String? venueName,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    final user = _supabase.auth.currentUser;
    await _supabase.from('events').insert({
      'name': name.trim(),
      'description': description.trim(),
      'address': address.trim(),
      'venue_name': venueName?.trim(),
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt.toUtc().toIso8601String(),
      'admin_id': user?.id ?? 'u_admin',
    });
  }

  Member _member(Map<String, dynamic> profile) => Member(
    id: profile['id'] as String,
    name: profile['display_name'] as String? ?? 'Luppy member',
    avatarUrl: profile['avatar_url'] as String? ?? _fallbackAvatar,
  );
}
