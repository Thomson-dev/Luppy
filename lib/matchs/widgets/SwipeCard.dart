import 'package:flutter/material.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/matchs/model/Match.dart';
import 'package:luppy/utils/image_helper.dart';

class SwipeCard extends StatelessWidget {
  final MatchCandidate candidate;
  final int photoIndex;
  final VoidCallback onPrevPhoto;
  final VoidCallback onNextPhoto;

  const SwipeCard({
    super.key,
    required this.candidate,
    required this.photoIndex,
    required this.onPrevPhoto,
    required this.onNextPhoto,
  });

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE8505F);
    final text = Theme.of(context).textTheme;
    final dog = candidate.dog;
    final imageIndex = photoIndex.clamp(0, candidate.photos.length - 1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pink.withOpacity(0.8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: appImageProvider(candidate.photos[imageIndex]),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF1E1E1E)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.55, 1],
                  colors: [Colors.transparent, Color(0xDD000000)],
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onPrevPhoto,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onNextPhoto,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          dog.name,
                          style: text.titleLarge?.copyWith(fontSize: 24),
                        ),
                        if (dog.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            size: 18,
                            color: Color(0xFF3B82F6),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dog.age.value} '
                      '${dog.age.unit == AgeUnit.years ? 'Years' : 'Months'}, '
                      '${dog.breed}',
                      style: text.bodyLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          candidate.distanceLabel,
                          style: text.bodySmall?.copyWith(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // One segment per photo; the current one is yellow.
                    Row(
                      children: [
                        for (var i = 0; i < candidate.photos.length; i++) ...[
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: i == photoIndex
                                    ? const Color(0xFFF5C842)
                                    : const Color(0xFFE6E0F2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          if (i < candidate.photos.length - 1)
                            const SizedBox(width: 4),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
