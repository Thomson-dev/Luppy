import 'package:flutter/material.dart';

const _pink = Color(0xFFE9525F);
const _pinkLight = Color(0xFFEF7D85);
const _lavender = Color(0xFFE6E0F2);

/// The last screen before login: Log In and Sign Up buttons.
class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;

  const WelcomeScreen({super.key, this.onLogin, this.onSignUp});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Welcome Dog.png',
                      height: 110,
                      // Until the real illustration exists, show a paw.
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.pets, size: 90, color: _lavender),
                    ),
                    const SizedBox(height: 24),
                    Text('Welcome to Luppy!', style: text.titleMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Luppy is the dog dating app that makes finding furry '
                      'friends fun and easy.',
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_pinkLight, _pink]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onLogin,
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: Center(child: Text('Log In', style: text.labelLarge)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onSignUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: _pink),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}