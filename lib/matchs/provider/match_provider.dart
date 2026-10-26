import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/provider/sign_up_provider.dart';
import '../../chat/provider/chat_provider.dart';
import '../../home/model/Dog.dart';
import '../model/Match.dart';
import '../repository/match_repository.dart';

const useDummyMatchData = bool.fromEnvironment(
  'USE_DUMMY_MATCH_DATA',
  defaultValue: true,
);

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(Supabase.instance.client);
});

final matchFeedProvider = AsyncNotifierProvider<MatchFeedController, MatchFeed>(
  MatchFeedController.new,
);

class MatchFeed {
  const MatchFeed({required this.me, required this.candidates});

  final Dog me;
  final List<MatchCandidate> candidates;
}

class MatchFeedController extends AsyncNotifier<MatchFeed> {
  @override
  Future<MatchFeed> build() async {
    final repository = ref.read(matchRepositoryProvider);
    Dog activeDog = myDog;
    try {
      activeDog = await repository.getMyDog();
    } catch (_) {}

    try {
      final candidatesList = await repository.getCandidates(activeDog.id);
      if (candidatesList.isNotEmpty) {
        return MatchFeed(me: activeDog, candidates: candidatesList);
      }
    } catch (_) {}

    return MatchFeed(me: activeDog, candidates: candidates);
  }

  Future<bool> recordSwipe({
    required String candidateDogId,
    required String action,
  }) async {
    final feed = state.value;
    if (feed != null && !feed.me.id.startsWith('u_')) {
      try {
        final isMatch = await ref
            .read(matchRepositoryProvider)
            .swipe(
              myDogId: feed.me.id,
              candidateDogId: candidateDogId,
              action: action,
            );
        if (isMatch) {
          // Immediately update both users' matches and chat list
          ref.invalidate(matchesProvider);
          ref.invalidate(chatListProvider);
        }
        return isMatch;
      } catch (_) {}
    }
    final isDemoMatch = action == 'like' && likedYouIds.contains(candidateDogId);
    if (isDemoMatch) {
      ref.invalidate(matchesProvider);
      ref.invalidate(chatListProvider);
    }
    return isDemoMatch;
  }
}
