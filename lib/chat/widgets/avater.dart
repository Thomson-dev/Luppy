import 'package:flutter/material.dart';
import 'package:luppy/utils/image_helper.dart';

class Avatar extends StatelessWidget {
  final String url;
  final bool isOnline;
  final double size;

  const Avatar({required this.url, this.isOnline = false, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: const Color(0xFF1E1E1E),
            backgroundImage: appImageProvider(url),
            onBackgroundImageError: (_, __) {},
          ),
          if (isOnline)
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
                    color: const Color(0xFF0B0B0D),
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
