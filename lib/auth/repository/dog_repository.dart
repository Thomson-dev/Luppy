import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/model/Dog.dart';
import '../model/sign_up_models.dart';

class DogRepository {
  final SupabaseClient _supabase;

  DogRepository(this._supabase);

  Future<List<Dog>> getDogs() async {
    final response = await _supabase
        .from('dogs')
        .select()
        .order('created_at', ascending: false);

    return response.map((json) => Dog.fromJson(json)).toList();
  }

  Future<List<Dog>> getPopularDogs() async {
    try {
      final user = _supabase.auth.currentUser;
      var query = _supabase.from('dogs').select();
      if (user != null) {
        query = query.neq('owner_id', user.id);
      }
      final response = await query
          .order('created_at', ascending: false)
          .limit(10);

      final dogs = response.map((json) => Dog.fromJson(json)).toList();
      if (dogs.isNotEmpty) return dogs;
    } catch (_) {}
    return popularDogs;
  }

  Future<List<Dog>> getMatches() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return matches;

      final ownedDogsResponse = await _supabase
          .from('dogs')
          .select('id')
          .eq('owner_id', user.id);
      final ownedDogIds = ownedDogsResponse
          .map((json) => json['id'] as String)
          .toSet();
      if (ownedDogIds.isEmpty) return matches;

      final matchRows = await _supabase
          .from('matches')
          .select('dog_a, dog_b, matched_at')
          .order('matched_at', ascending: false);
      final matchedDogIds = <String>[];
      final seenDogIds = <String>{};
      for (final row in matchRows) {
        final dogA = row['dog_a'] as String;
        final dogB = row['dog_b'] as String;
        if (ownedDogIds.contains(dogA)) {
          if (seenDogIds.add(dogB)) matchedDogIds.add(dogB);
        } else if (ownedDogIds.contains(dogB)) {
          if (seenDogIds.add(dogA)) matchedDogIds.add(dogA);
        }
      }
      if (matchedDogIds.isEmpty) return matches;

      final dogsResponse = await _supabase
          .from('dogs')
          .select()
          .inFilter('id', matchedDogIds);
      final dogsById = {
        for (final json in dogsResponse) json['id'] as String: Dog.fromJson(json),
      };

      final result = matchedDogIds.map((id) => dogsById[id]).whereType<Dog>().toList();
      if (result.isNotEmpty) return result;
    } catch (_) {}
    return matches;
  }

  Future<void> createDog(SignUpData data) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Supabase did not create a session. Disable email confirmation in '
        'Supabase Auth settings to complete signup without verification.',
      );
    }

    if (data.dogBirthDate == null || data.gender == null || data.size == null) {
      throw Exception('Complete all required dog profile fields.');
    }

    await _supabase.from('dogs').insert({
      'owner_id': user.id,
      'name': data.dogName.trim(),
      'birth_date': data.dogBirthDate!.toIso8601String().split('T').first,
      'breed': data.breed.trim(),
      'gender': data.gender!.name,
      'size': data.size!.name,
      'temperaments': data.temperaments.map((item) => item.name).toList(),
      'interests': data.interests.map((item) => item.name).toList(),
    });
  }
}
