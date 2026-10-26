import 'package:flutter/material.dart';
import 'package:luppy/matchs/model/Match.dart';
import 'package:luppy/utils/image_helper.dart';

const _pink = Color(0xFFE91E63);
const _pinkLight = Color(0xFFFF80AB);

/// Pops with `true` for "Send A Message", `false` for "Keep Swiping".
class ItsAMatchScreen extends StatelessWidget {
  final DogMatch match;

  const ItsAMatchScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _pink.withValues(alpha: 0.8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "It's a Match!",
                style: text.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text('Unleashing a new friendship', style: text.bodySmall),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MatchAvatar(url: match.me.imageUrl),
                  Transform.translate(
                    offset: const Offset(-12, 0), // overlap the two avatars
                    child: _MatchAvatar(url: match.other.imageUrl),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_pinkLight, _pink]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context, true),
                      child: Center(
                        child: Text('Send A Message', style: text.labelLarge),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: _pink.withOpacity(0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Keep Swiping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  final String url;

  const _MatchAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFF0B0B0D),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF1E1E1E),
        backgroundImage: appImageProvider(url),
        onBackgroundImageError: (_, __) {},
      ),
    );
  }
}
