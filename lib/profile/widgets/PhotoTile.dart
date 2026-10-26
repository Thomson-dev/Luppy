import 'package:flutter/material.dart';
import 'package:luppy/utils/image_helper.dart';

class PhotoTile extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const PhotoTile({required this.url, required this.onRemove});

  ImageProvider _image(String url) => appImageProvider(url);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: _image(url),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF1E1E1E)),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 9,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}