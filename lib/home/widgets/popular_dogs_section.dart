import 'package:flutter/material.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/utils/image_helper.dart';

/// "Popular Dogs" section: title row with "See All" and a horizontal list of
/// tall photo cards with the dog's name, verified badge, age and breed.
class PopularDogsSection extends StatelessWidget {
  final List<Dog> popularDogs;
  final String title;
  final VoidCallback? onSeeAll;
  final ValueChanged<Dog>? onDogTap;

  const PopularDogsSection({
    super.key,
    required this.popularDogs,
    this.title = 'Popular Dogs',
    this.onSeeAll,
    this.onDogTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: text.titleLarge),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: text.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: popularDogs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => DogCard(
              dog: popularDogs[i],
              onTap: onDogTap == null ? null : () => onDogTap!(popularDogs[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class DogCard extends StatelessWidget {
  final Dog dog;
  final VoidCallback? onTap;

  static const double width = 135;
  static const double height = 182;
  static const _verifiedBlue = Color(0xFF3B82F6);

  const DogCard({super.key, required this.dog, this.onTap});

  ImageProvider get _image => appImageProvider(dog.imageUrl);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: _image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF1E1E1E)),
              ),
              // Dark fade so the text stays readable on any photo.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 1],
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            dog.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(fontSize: 16),
                          ),
                        ),
                        if (dog.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: _verifiedBlue,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dog.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
