import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/view/sign_in_screen.dart';
import 'package:luppy/auth/view/sign_up_screen.dart';
import 'package:luppy/home/View/HomeScreen.dart';
import 'package:luppy/onboardimg/OnboardingScreen.dart';
import 'package:luppy/onboardimg/welcomeScreen.dart';
import 'package:luppy/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = "https://wrolrltlnejvmbsuntyt.supabase.co";
const _supabasePublishableKey =
    "sb_publishable_kX1pkcLSbkM7QwVY4SYuvg_4-GSShO8";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseUrl.isNotEmpty && _supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabasePublishableKey,
    );
  }
  runApp(const ProviderScope(child: MyApp()));
}

const _onboardingSeenKey = 'onboarding_seen';

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _loading = true;
  bool _onboardingSeen = false;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _onboardingSeen = prefs.getBool(_onboardingSeenKey) ?? false;
      _loading = false;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
    if (!mounted) return;
    setState(() => _onboardingSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;

        if (session != null) return const HomeScreen();

        if (!_onboardingSeen) {
          return OnboardingScreen(onFinish: _finishOnboarding);
        }

        return WelcomeScreen(
          onLogin: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          onSignUp: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luppy',
      theme: AppTheme.dark,

      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}
