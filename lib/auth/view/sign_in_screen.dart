import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/model/sign_in.model.dart';
import 'package:luppy/auth/provider/sign_up_provider.dart';
import 'package:luppy/auth/view/sign_up_screen.dart';
import 'package:luppy/home/View/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Login screen: email + password (with show/hide), forgot password,
/// Log In button, social login buttons, and a link to sign up.
class LoginScreen extends ConsumerStatefulWidget {
  final ValueChanged<LoginData>? onLogin;
  final ValueChanged<SocialProvider>? onSocialLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  const LoginScreen({
    super.key,
    this.onLogin,
    this.onSocialLogin,
    this.onForgotPassword,
    this.onSignUp,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _pink = Color(0xFFE8505F);
  static const _pinkLight = Color(0xFFF08A93);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginData _data = const LoginData();
  bool _obscurePassword = true; // screen state, not part of the model
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onTextChanged);
    _passwordController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _data = _data.copyWith(
        email: _emailController.text,
        password: _passwordController.text,
      );
    });
  }

  Future<void> _submit() async {
    final loginData = LoginData(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!loginData.canSubmit || _isSubmitting) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final response = await ref.read(authRepositoryProvider).signIn(loginData);
      if (!mounted) return;
      final user = response.user;
      if (user != null) {
        widget.onLogin?.call(loginData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Log in failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              Text(
                'Back to pawsome matches',
                style: text.titleLarge?.copyWith(fontSize: 23),
              ),
              const SizedBox(height: 8),
              Text(
                'Missed us? Log in to resume your furry love quest.',
                style: text.bodySmall?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 28),
              _FieldLabel('Email'),
              _LoginField(
                controller: _emailController,
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 22),
              _FieldLabel('Password'),
              _LoginField(
                controller: _passwordController,
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    _data.canSubmit && !_isSubmitting ? _submit() : null,
                suffix: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF7C7C86),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onForgotPassword,
                  child: Text(
                    'Forgot your password?',
                    style: text.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _GradientButton(
                label: _isSubmitting ? 'Logging in…' : 'Log In',
                onPressed: _data.canSubmit && !_isSubmitting ? _submit : null,
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'OR',
                  style: text.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                    provider: SocialProvider.facebook,
                    icon: const Icon(Icons.facebook, color: Colors.white),
                    onTap: widget.onSocialLogin,
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    provider: SocialProvider.apple,
                    icon: const Icon(Icons.apple, color: Colors.white),
                    onTap: widget.onSocialLogin,
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    provider: SocialProvider.google,
                    icon: const _GoogleG(),
                    onTap: widget.onSocialLogin,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'New to Luppy? ',
                      style: text.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: text.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _LoginField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        autocorrect: false,
        enableSuggestions: !obscureText,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7C7C86), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF131317),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: suffix,
          border: _border(const Color(0xFF2E2E36)),
          enabledBorder: _border(const Color(0xFF2E2E36)),
          focusedBorder: _border(const Color(0xFF5A5A66)),
        ),
      ),
    );
  }
}

/// Square dark button with a pink outline for each social provider.
class _SocialButton extends StatelessWidget {
  final SocialProvider provider;
  final Widget icon;
  final ValueChanged<SocialProvider>? onTap;

  const _SocialButton({required this.provider, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with ${provider.label}',
      child: GestureDetector(
        onTap: onTap == null ? null : () => onTap!(provider),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF131317),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _LoginScreenState._pink.withOpacity(0.5)),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

/// Colored "G" stand-in for the Google logo. Swap for the official SVG asset
/// (flutter_svg) or font_awesome_flutter before release.
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const SweepGradient(
        colors: [
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(bounds),
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Pink gradient button; dimmed and inactive when [onPressed] is null.
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GradientButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_LoginScreenState._pinkLight, _LoginScreenState._pink],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
