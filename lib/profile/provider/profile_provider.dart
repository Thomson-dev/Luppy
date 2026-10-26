import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Model/Profile.dart';
import '../repository/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final currentProfileProvider = FutureProvider<DogProfile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final profile = await repo.getCurrentProfile();
  return profile ?? lokiProfile;
});

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, DogProfile>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<DogProfile> {
  @override
  Future<DogProfile> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final profile = await repo.getCurrentProfile();
    return profile ?? lokiProfile;
  }

  Future<void> saveProfile(DogProfile profile) async {
    final previousPhotos = state.value?.photos;
    if (!listEquals(previousPhotos, profile.photos)) {
      debugPrint(
        '[Profile] Photo change requested: $previousPhotos -> ${profile.photos}',
      );
    }

    state = const AsyncLoading();
    try {
      final repo = ref.read(profileRepositoryProvider);

      final saved = await repo.saveProfile(profile);
      debugPrint(
        '[Profile] Profile saved: id=${saved.id}, photos=${saved.photos}',
      );
      state = AsyncData(saved);
      ref.invalidate(currentProfileProvider);
    } catch (error, stackTrace) {
      debugPrint('[Profile] Failed to save profile: $error');
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
