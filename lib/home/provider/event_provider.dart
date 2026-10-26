import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/Event.dart';
import '../repository/event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(Supabase.instance.client);
});

final topEventsProvider =
    AsyncNotifierProvider<TopEventsController, List<Event>>(
      TopEventsController.new,
    );

class TopEventsController extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    return ref.watch(eventRepositoryProvider).getTopEvents();
  }

  Future<void> joinEvent(String eventId) async {
    final currentEvents = state.value ?? [];
    state = AsyncData([
      for (final ev in currentEvents)
        if (ev.id == eventId)
          Event(
            id: ev.id,
            name: ev.name,
            description: ev.description,
            startsAt: ev.startsAt,
            endsAt: ev.endsAt,
            location: ev.location,
            members: ev.members,
            admin: ev.admin,
            hasJoined: true,
          )
        else
          ev,
    ]);

    try {
      await ref.read(eventRepositoryProvider).joinEvent(eventId);
    } catch (_) {}
  }

  Future<void> createEvent({
    required String name,
    required String description,
    required String address,
    required String? venueName,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    final currentEvents = state.value ?? [];
    final currentUser = Supabase.instance.client.auth.currentUser;
    final newEvent = Event(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      startsAt: startsAt,
      endsAt: endsAt,
      location: EventLocation(venueName: venueName, address: address),
      members: const [],
      admin: Member(
        id: currentUser?.id ?? 'u_me',
        name: currentUser?.email?.split('@').first ?? 'My Dog',
        avatarUrl:
            'https://images.unsplash.com/photo-1517849845537-4d257902454a',
      ),
      hasJoined: true,
    );

    state = AsyncData([newEvent, ...currentEvents]);

    try {
      await ref.read(eventRepositoryProvider).createEvent(
        name: name,
        description: description,
        address: address,
        venueName: venueName,
        startsAt: startsAt,
        endsAt: endsAt,
      );
    } catch (_) {}
  }
}
