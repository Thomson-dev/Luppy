import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/model/Dog.dart';
import '../repository/auth_repository.dart';
import '../repository/dog_repository.dart';
import '../model/sign_up_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final dogRepositoryProvider = Provider<DogRepository>((ref) {
  return DogRepository(Supabase.instance.client);
});

final popularDogsProvider = FutureProvider<List<Dog>>((ref) {
  return ref.read(dogRepositoryProvider).getPopularDogs();
});

final matchesProvider = FutureProvider<List<Dog>>((ref) {
  return ref.read(dogRepositoryProvider).getMatches();
});

final signUpNotifierProvider = AsyncNotifierProvider<SignUpNotifier, void>(
  SignUpNotifier.new,
);

class SignUpNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signUpAndCreateDog({
    required String email,
    required String password,
    required SignUpData data,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password);
      await ref.read(dogRepositoryProvider).createDog(data);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
