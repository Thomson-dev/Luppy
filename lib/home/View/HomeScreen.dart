import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luppy/chat/Model/Chat.dart';
import 'package:luppy/chat/View/ChatListScreen.dart';
import 'package:luppy/chat/View/ChatScreen.dart';
import 'package:luppy/chat/provider/chat_provider.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/profile/Model/Profile.dart';
import 'package:luppy/home/model/Event.dart';
import 'package:luppy/home/View/event_details_screen.dart';
import 'package:luppy/home/provider/event_provider.dart';
import 'package:luppy/home/widgets/create_event_sheet.dart';
import 'package:luppy/matchs/View/MatchScreen.dart';
import 'package:luppy/profile/View/ProfileScreen.dart';
import 'package:luppy/home/widgets/home_header.dart';
import 'package:luppy/home/widgets/new_matches_section.dart';
import 'package:luppy/home/widgets/popular_dogs_section.dart';
import 'package:luppy/home/widgets/top_events_section.dart';
import 'package:luppy/notification/View/NotificationScreen.dart';
import 'package:luppy/notification/provider/notification_provider.dart';
import 'package:luppy/auth/provider/sign_up_provider.dart';
import 'package:luppy/auth/widget/logout_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final luna = Member(
    id: 'u_luna',
    name: 'Luna Cutipie',
    avatarUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a',
    isOnline: true,
  );

  late final List<Widget> _screens = [
    const _HomeTab(),
    const ChatListScreen(),
    MatchScreen(onMessage: _openChats),
    const ProfileScreen(plans: plans),
  ];

  Future<void> _openChats(Dog dog) async {
    final targetChat =
        await ref.read(chatListProvider.notifier).getOrCreateChatForDog(dog);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chat: targetChat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: LuppyBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim());
  }

  bool _contains(String? value, String query) =>
      value != null && value.toLowerCase().contains(query);

  List<Dog> _filterDogs(List<Dog> dogs, String query) {
    if (query.isEmpty) return dogs;
    final q = query.toLowerCase();
    return dogs
        .where((dog) => _contains(dog.name, q) || _contains(dog.breed, q))
        .toList();
  }

  List<Event> _filterEvents(List<Event> events, String query) {
    if (query.isEmpty) return events;
    final q = query.toLowerCase();
    return events
        .where(
          (event) =>
              _contains(event.name, q) ||
              _contains(event.description, q) ||
              _contains(event.location.venueName, q) ||
              _contains(event.location.address, q),
        )
        .toList();
  }

  Future<void> _openChatWithDog(Dog dog) async {
    final targetChat =
        await ref.read(chatListProvider.notifier).getOrCreateChatForDog(dog);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chat: targetChat)),
    );
  }

  void _joinEvent(Event event) {
    ref.read(topEventsProvider.notifier).joinEvent(event.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${event.name}!'),
        backgroundColor: const Color(0xFFE8505F),
      ),
    );
  }

  void _openEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          event: event,
          onJoin: () => _joinEvent(event),
          onCreateEvent: () => showCreateEventSheet(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesProvider);
    final popularDogsAsync = ref.watch(popularDogsProvider);
    final eventsAsync = ref.watch(topEventsProvider);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final isSearching = _query.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          HomeHeader(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onSearchSubmitted: (_) => FocusScope.of(context).unfocus(),
            hasUnreadNotifications: unreadNotifications > 0,
            onNotificationsTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            onMenuTap: () => showAppMenuSheet(context, ref),
          ),
          const SizedBox(height: 25),
          if (isSearching)
            _buildSearchResults(
              matchesAsync,
              popularDogsAsync,
              eventsAsync,
              _query,
            )
          else ...[
            matchesAsync.when(
              loading: () => const _MatchesSkeleton(),
              error: (error, stackTrace) =>
                  const Text('Failed to load matches.'),
              data: (dogs) => dogs.isEmpty
                  ? const Text('No matches yet.')
                  : NewMatchesSection(
                      matches: dogs,
                      onMatchTap: _openChatWithDog,
                    ),
            ),
            const SizedBox(height: 25),
            popularDogsAsync.when(
              loading: () => const _PopularDogsSkeleton(),
              error: (error, stackTrace) =>
                  const Text('Failed to load popular dogs.'),
              data: (dogs) {
                if (dogs.isEmpty) {
                  return const Text('No dogs available yet.');
                }

                return PopularDogsSection(
                  popularDogs: dogs,
                  onDogTap: _openChatWithDog,
                );
              },
            ),
            const SizedBox(height: 25),
            eventsAsync.when(
              loading: () => const _EventsSkeleton(),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Failed to load events: $error'),
              ),
              data: (events) => events.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('No upcoming events yet.'),
                    )
                  : TopEventsSection(
                      events: events,
                      onEventTap: _openEvent,
                      onJoin: _joinEvent,
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<List<Dog>> matchesAsync,
    AsyncValue<List<Dog>> dogsAsync,
    AsyncValue<List<Event>> eventsAsync,
    String query,
  ) {
    final matchResults = _filterDogs(matchesAsync.value ?? const [], query);
    final dogResults = _filterDogs(dogsAsync.value ?? const [], query);
    final eventResults = _filterEvents(eventsAsync.value ?? const [], query);
    final hasResults =
        matchResults.isNotEmpty ||
        dogResults.isNotEmpty ||
        eventResults.isNotEmpty;
    final isLoading =
        matchesAsync.isLoading || dogsAsync.isLoading || eventsAsync.isLoading;
    final hasError =
        matchesAsync.hasError && dogsAsync.hasError && eventsAsync.hasError;

    if (isLoading && !hasResults) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasResults) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF7C7C86)),
            const SizedBox(height: 12),
            Text(
              hasError
                  ? 'Could not search right now. Please try again.'
                  : 'No results for "$query".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (matchResults.isNotEmpty) ...[
          NewMatchesSection(
            title: 'Matches',
            matches: matchResults,
            onMatchTap: _openChatWithDog,
          ),
          const SizedBox(height: 25),
        ],
        if (dogResults.isNotEmpty) ...[
          PopularDogsSection(
            title: 'Dogs',
            popularDogs: dogResults,
            onDogTap: _openChatWithDog,
          ),
          const SizedBox(height: 25),
        ],
        if (eventResults.isNotEmpty)
          TopEventsSection(
            title: 'Events',
            events: eventResults,
            onEventTap: _openEvent,
            onJoin: _joinEvent,
          ),
      ],
    );
  }
}

class _PopularDogsSkeleton extends StatelessWidget {
  const _PopularDogsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _shimmerSkeleton(
      context,
      SizedBox(
        height: 182,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => const _SkeletonDogCard(),
        ),
      ),
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _shimmerSkeleton(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SkeletonBar(width: 100, height: 20),
                _SkeletonBar(width: 48, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 2,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => Container(
                width: 300,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF29292D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBar(width: 105, height: 12),
                    SizedBox(height: 10),
                    _SkeletonBar(width: 180, height: 16),
                    SizedBox(height: 10),
                    _SkeletonBar(width: 250, height: 11),
                    SizedBox(height: 6),
                    _SkeletonBar(width: 210, height: 11),
                    Spacer(),
                    _SkeletonBar(width: 90, height: 26),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchesSkeleton extends StatelessWidget {
  const _MatchesSkeleton();

  @override
  Widget build(BuildContext context) {
    return _shimmerSkeleton(
      context,
      SizedBox(
        height: 58,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => const CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFF29292D),
          ),
        ),
      ),
    );
  }
}

Widget _shimmerSkeleton(BuildContext context, Widget child) {
  final colorScheme = Theme.of(context).colorScheme;
  return Shimmer.fromColors(
    baseColor: colorScheme.surfaceContainerHighest,
    highlightColor: colorScheme.surface,
    period: const Duration(milliseconds: 1400),
    child: child,
  );
}

class _SkeletonDogCard extends StatelessWidget {
  const _SkeletonDogCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: DogCard.width,
        height: DogCard.height,
        color: const Color(0xFF29292D),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        alignment: Alignment.bottomLeft,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBar(width: 72, height: 16),
            SizedBox(height: 6),
            _SkeletonBar(width: 96, height: 12),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF414147),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class LuppyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LuppyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0B0B0D),
      selectedItemColor: const Color(0xFFE8505F),
      unselectedItemColor: Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/home.png', width: 24, height: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/Message 22.png', width: 24, height: 24),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/love.png', width: 24, height: 24),
          label: 'Matches',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/Profile Square.png', width: 24, height: 24),
          label: 'Profile',
        ),
      ],
    );
  }
}
