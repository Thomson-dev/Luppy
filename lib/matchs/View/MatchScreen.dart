import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/widget/logout_dialog.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/matchs/model/Match.dart';
import 'package:luppy/matchs/provider/match_provider.dart';
import 'package:luppy/matchs/widgets/SwipeCard.dart';
import 'package:luppy/matchs/widgets/ActionBar.dart';
import 'package:luppy/matchs/View/ItsAMatchScreen.dart';
import 'package:luppy/notification/widgets/notification_button.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final List<MatchCandidate>? candidates;
  final Dog? me;
  final ValueChanged<Dog>? onMessage;

  const MatchScreen({Key? key, this.candidates, this.me, this.onMessage})
    : super(key: key);

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  // Each candidate is one page. viewportFraction < 1 lets the neighbouring
  // cards peek in from the sides, like the design.
  final _pageController = PageController(viewportFraction: 0.88);
  int _page = 0; // which card is showing
  int _photoIndex = 0; // which photo of that card
  bool _isSavingSwipe = false;
  List<MatchCandidate> _loadedCandidates = const [];
  Dog? _loadedMe;

  List<MatchCandidate> get _candidates =>
      widget.candidates ?? _loadedCandidates;
  Dog? get _me => widget.me ?? _loadedMe;

  // The last page is the "No more dogs nearby" message, not a dog.
  bool get _onCard => _page < _candidates.length;
  MatchCandidate get _current => _candidates[_page];

  void _changePhoto(int delta) {
    final photos = _current.photos.length;
    final next = _photoIndex + delta;
    if (next >= 0 && next < photos) setState(() => _photoIndex = next);
  }

  void _goToNext() => _pageController.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  Future<bool> _swipe(String action) async {
    if (_isSavingSwipe || !_onCard) return false;
    final candidate = _current;
    setState(() => _isSavingSwipe = true);
    var isMatch = false;
    try {
      isMatch = await ref
          .read(matchFeedProvider.notifier)
          .recordSwipe(candidateDogId: candidate.dog.id, action: action);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your choice: $error')),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSavingSwipe = false);
    }
    _goToNext();
    return isMatch;
  }

  Future<void> _like() async {
    final candidate = _current;
    final isMatch = await _swipe('like');
    if (!isMatch || !mounted || _me == null) return;

    final match = DogMatch(
      id: 'match_${candidate.dog.id}',
      me: _me!,
      other: candidate.dog,
      matchedAt: DateTime.now(),
    );
    final sendMessage = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItsAMatchScreen(match: match)),
    );
    if (sendMessage == true) widget.onMessage?.call(match.other);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final feedState = ref.watch(matchFeedProvider);
    if (widget.candidates == null && feedState is AsyncData<MatchFeed>) {
      _loadedCandidates = feedState.value.candidates;
      _loadedMe = feedState.value.me;
    }

    if (widget.candidates == null && feedState is AsyncLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (widget.candidates == null && feedState is AsyncError) {
      return Scaffold(
        body: Center(child: Text('Could not load matches: ${feedState.error}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text('Matches', style: text.titleMedium?.copyWith(fontSize: 18)),
        actions: [
          const NotificationButton(),
          IconButton(
            icon: Image.asset('assets/Menu.png', width: 28, height: 28),
            onPressed: () => showAppMenuSheet(context, ref),
          ),
        ],
      ),
      body: _candidates.isEmpty
          ? const Center(child: Text('No more dogs nearby'))
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _page = page;
                        _photoIndex = 0;
                      });
                    },
                    itemCount: _candidates.length + 1, // +1 = end message
                    itemBuilder: (context, i) {
                      if (i == _candidates.length) {
                        return const Center(child: Text('No more dogs nearby'));
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(6, 8, 6, 16),
                        child: SwipeCard(
                          candidate: _candidates[i],
                          // Only the card in front shows a photo other than the first.
                          photoIndex: i == _page ? _photoIndex : 0,
                          onPrevPhoto: () => _changePhoto(-1),
                          onNextPhoto: () => _changePhoto(1),
                        ),
                      );
                    },
                  ),
                ),

                if (_onCard)
                  ActionBar(
                    onMessage: _isSavingSwipe
                        ? () {}
                        : () => widget.onMessage?.call(_current.dog),
                    onPass: _isSavingSwipe ? () {} : () => _swipe('pass'),
                    onLike: _isSavingSwipe ? () {} : _like,
                  ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
