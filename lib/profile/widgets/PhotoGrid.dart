import 'package:flutter/material.dart';
import 'package:luppy/profile/Model/Profile.dart';
import 'package:luppy/profile/widgets/PhotoTile.dart';

const Color _pink = Color(0xFFFF4081);

class PhotoGrid extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const PhotoGrid({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.78,
      children: [
        for (var i = 0; i < DogProfile.maxPhotos; i++)
          if (i < photos.length)
            PhotoTile(url: photos[i], onRemove: () => onRemove(i))
          else
            GestureDetector(
              onTap: onAdd,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _pink.withOpacity(0.6)),
                ),
                child: const Icon(Icons.add_circle_outline, size: 22),
              ),
            ),
      ],
    );
  }
}