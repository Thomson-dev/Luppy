import 'package:flutter/material.dart';
import 'package:luppy/profile/Model/Profile.dart';
import 'package:luppy/profile/View/EditProfileScreen.dart';
import 'package:luppy/utils/image_helper.dart';

class ProfileCard extends StatelessWidget {
  final DogProfile profile;
  final VoidCallback? onEdit;

  const ProfileCard({required this.profile, this.onEdit});

  void _handleEdit(BuildContext context) {
    if (onEdit != null) {
      onEdit!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditProfileScreen(profile: profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // "2 Yo, Bulldog" (skips any part that is missing)
    final subtitle = [
      profile.ageAt(DateTime.now())?.label,
      profile.breed,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9525F).withValues(alpha: 0.8),
        ),
      ),

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(url: profile.avatarUrl, onTap: () => _handleEdit(context)),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.name.isEmpty ? 'Your dog' : profile.name,
                  style: text.titleLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.verified,
                  size: 19,
                  color: profile.isVerified
                      ? const Color(0xFF3B82F6)
                      : Colors.white38,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(subtitle, style: text.bodyLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _handleEdit(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC0325D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  profile.isComplete ? 'Edit' : 'Complete My Profile',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dog photo with a green dot, or a white camera circle when there is none.
class _Avatar extends StatelessWidget {
  final String? url;
  final VoidCallback? onTap;

  const _Avatar({required this.url, this.onTap});

  ImageProvider _image(String url) => appImageProvider(url);

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return GestureDetector(
        onTap: onTap,
        child: const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white,
          child: Icon(Icons.photo_camera_outlined, color: Colors.black54),
        ),
      );
    }

    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF1E1E1E),
            backgroundImage: _image(url!),
            onBackgroundImageError: (_, __) {},
          ),
          Positioned(
            right: 2,
            bottom: 4,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFF22DD3A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B0B0D), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
