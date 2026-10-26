import 'package:flutter/material.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/utils/image_helper.dart';

/// "New Matches" section from the Luppy home screen:
/// a title row with "See All" and a horizontal row of round avatars,
/// each with a green dot when the dog is online.
class NewMatchesSection extends StatelessWidget {
  final List<Dog> matches;
  final String title;
  final VoidCallback? onSeeAll;
  final ValueChanged<Dog>? onMatchTap;

  const NewMatchesSection({
    super.key,
    required this.matches,
    this.title = 'New Matches',
    this.onSeeAll,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: textTheme.titleLarge),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _MatchAvatar(
              dog: matches[i],
              onTap: onMatchTap == null ? null : () => onMatchTap!(matches[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  final Dog dog;
  final VoidCallback? onTap;

  static const double _size = 54;

  const _MatchAvatar({required this.dog, this.onTap});

  ImageProvider get _image => appImageProvider(dog.imageUrl);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: '${dog.name}${dog.isOnline ? ', online' : ''}',
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: _size / 2,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: _image,
                onBackgroundImageError: (_, __) {},
              ),
              if (dog.isOnline)
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22DD3A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

///
