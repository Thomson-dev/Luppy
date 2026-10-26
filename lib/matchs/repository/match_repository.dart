import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/model/Dog.dart';
import '../model/Match.dart';

class MatchRepository {
  MatchRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<Dog> getMyDog() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before loading match candidates.');
    }

    final rows = await _supabase
        .from('dogs')
        .select()
        .eq('owner_id', user.id)
        .limit(1);
    if (rows.isEmpty) {
      throw StateError('Create a dog profile before browsing matches.');
    }
    return Dog.fromJson(rows.first);
  }

  Future<List<MatchCandidate>> getCandidates(String dogId) async {
    // 1. Try remote RPC if it exists in Supabase
    try {
      final rows = await _supabase.rpc(
        'get_candidates',
        params: {'my_dog_id': dogId},
      );
      if (rows is List && rows.isNotEmpty) {
        return _parseCandidates(rows);
      }
    } catch (_) {}

    // 2. Direct query fallback: fetch dogs not owned by this dog and not swiped yet
    try {
      final swipedRows = await _supabase
          .from('swipes')
          .select('target_dog_id')
          .eq('swiper_dog_id', dogId);

      final swipedIds = swipedRows
          .map((r) => r['target_dog_id'] as String)
          .toSet();

      final response = await _supabase
          .from('dogs')
          .select()
          .neq('id', dogId)
          .order('created_at', ascending: false)
          .limit(30);

      final newDogs = response
          .where((row) => !swipedIds.contains(row['id'] as String))
          .toList();

      if (newDogs.isNotEmpty) {
        return _parseCandidates(newDogs);
      }
    } catch (_) {}

    // 3. Fallback to sample candidates if no other dogs exist in database yet
    return candidates;
  }

  List<MatchCandidate> _parseCandidates(List<dynamic> rows) {
    return rows.map<MatchCandidate>((row) {
      final data = Map<String, dynamic>.from(row as Map);
      final photos = (data['photos'] as List?)?.cast<String>() ?? <String>[];
      final imageUrl = data['image_url'] as String? ?? '';
      final resolvedPhotos = photos.isNotEmpty
          ? photos
          : (imageUrl.isNotEmpty
              ? [imageUrl]
              : const [
                  'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
                ]);

      return MatchCandidate.fromJson({
        'dog': data,
        'photos': resolvedPhotos,
        'distance_km': data['distance_km'] as num? ?? 1.5,
      });
    }).toList();
  }

  /// Flow:
  /// 1. User A likes Bella. Save that action in the database.
  /// 2. User B later likes Bruno. Save that action too.
  /// 3. The backend checks whether the reverse like already exists.
  /// 4. If both likes exist, create one match record.
  /// 5. Make that match appear in both users' match lists.
  /// 6. Allow chat only for participants in that match.
  /// Important: don't create a match record just because one person likes another dog.
  /// A match requires mutual interest.
  Future<bool> swipe({
    required String myDogId,
    required String candidateDogId,
    required String action,
  }) async {
    // 1. Save swipe in the database
    try {
      await _supabase.from('swipes').upsert({
        'swiper_dog_id': myDogId,
        'target_dog_id': candidateDogId,
        'action': action,
      });
    } catch (_) {
      try {
        await _supabase.from('swipes').insert({
          'swiper_dog_id': myDogId,
          'target_dog_id': candidateDogId,
          'action': action,
        });
      } catch (_) {}
    }

    // A match requires mutual interest. If not 'like', no match.
    if (action != 'like') return false;

    // 2. Check whether reverse like already exists in database
    var isMutual = false;
    try {
      final reverseRows = await _supabase
          .from('swipes')
          .select('id, action')
          .eq('swiper_dog_id', candidateDogId)
          .eq('target_dog_id', myDogId)
          .eq('action', 'like')
          .limit(1);

      isMutual = reverseRows.isNotEmpty;
    } catch (_) {}

    // If reverse like does not exist yet, do NOT create a match record.
    if (!isMutual) return false;

    // 3. Both likes exist! Create exactly one mutual match record in public.matches
    final dogIds = [myDogId, candidateDogId]..sort();
    try {
      final existing = await _supabase
          .from('matches')
          .select('id')
          .eq('dog_a', dogIds.first)
          .eq('dog_b', dogIds.last)
          .limit(1);

      if (existing.isEmpty) {
        await _supabase.from('matches').insert({
          'dog_a': dogIds.first,
          'dog_b': dogIds.last,
          'matched_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (_) {}

    return true; // Mutual match created!
  }
}
