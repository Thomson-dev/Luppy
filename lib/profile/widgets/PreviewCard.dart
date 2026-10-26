import 'package:flutter/material.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/profile/Model/Profile.dart';
import 'package:luppy/utils/image_helper.dart';

class PreviewCard extends StatefulWidget {
  final DogProfile profile;

  const PreviewCard({super.key, required this.profile});

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  int _photoIndex = 0;

  @override
  void didUpdateWidget(PreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_photoIndex >= widget.profile.photos.length) {
      _photoIndex = 0;
    }
  }

  void _changePhoto(int delta) {
    final next = _photoIndex + delta;
    if (next >= 0 && next < widget.profile.photos.length) {
      setState(() => _photoIndex = next);
    }
  }

  ImageProvider _image(String url) => appImageProvider(url);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profile = widget.profile;
    final photos = profile.photos;
    final age = profile.ageAt(DateTime.now());
    final subtitle = age == null
        ? profile.breed
        : '${age.value} ${age.unit == AgeUnit.years ? 'Years' : 'Months'}, '
              '${profile.breed}';
    final imageIndex = photos.isEmpty
        ? 0
        : _photoIndex.clamp(0, photos.length - 1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8505F).withOpacity(0.8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photos.isEmpty)
              const ColoredBox(
                color: Color(0xFF1E1E1E),
                child: Center(child: Text('Add a photo to see your card')),
              )
            else
              Image(
                image: _image(photos[imageIndex]),
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
            if (photos.length > 1)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _changePhoto(-1),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _changePhoto(1),
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
                          profile.name,
                          style: text.titleLarge?.copyWith(fontSize: 24),
                        ),
                        if (profile.isVerified) ...[
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
                      subtitle,
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
                          'Less than 1km',
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
                        for (var i = 0; i < photos.length; i++) ...[
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: i == imageIndex
                                    ? const Color(0xFFF5C842)
                                    : const Color(0xFFE6E0F2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          if (i < photos.length - 1) const SizedBox(width: 4),
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
