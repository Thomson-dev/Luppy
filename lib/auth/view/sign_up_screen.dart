import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/view/sign_in_screen.dart';
import 'package:luppy/home/View/HomeScreen.dart';
import 'package:luppy/auth/provider/sign_up_provider.dart';
import 'package:luppy/auth/model/sign_up_models.dart';
import 'package:luppy/auth/widget/Progress_bar.dart';
import 'package:luppy/auth/widget/Label.dart';
import 'package:luppy/auth/widget/TextInput.dart';
import 'package:luppy/auth/widget/chipSelect.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final ValueChanged<SignUpData>? onComplete;

  const SignUpScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  static const _pinkLight = Color(0xFFFFB6C9);
  static const _pink = Color(0xFFFF8FB1);

  SignUpData _data = const SignUpData();
  SignUpStep _step = SignUpStep.account;
  final PageController _pageController = PageController();
  bool get _isFirst => _step == SignUpStep.account;
  bool get _isLast => _step == SignUpStep.personality;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _update(SignUpData next) => setState(() => _data = next);

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.dogBirthDate ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.pink,
            onPrimary: Colors.white,
            surface: Color(0xFF16161A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _update(_data.copyWith(dogBirthDate: picked));
  }

  Future<void> _continue() async {
    if (_isLast) {
      setState(() => _isSubmitting = true);
      try {
        await ref
            .read(signUpNotifierProvider.notifier)
            .signUpAndCreateDog(
              email: _data.email,
              password: _data.password,
              data: _data,
            );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Sign-up failed: $error')));
        }
        return;
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      if (!mounted) return;
      widget.onComplete?.call(_data);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final nextStep = SignUpStep.values[_step.index + 1];
      setState(() => _step = nextStep);
      _pageController.animateToPage(
        nextStep.index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_isFirst) {
      Navigator.maybePop(context);
    } else {
      final previousStep = SignUpStep.values[_step.index - 1];
      setState(() => _step = previousStep);
      _pageController.animateToPage(
        previousStep.index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isAccount = _step == SignUpStep.account;
    final signUpState = ref.watch(signUpNotifierProvider);
    final isSubmitting = _isSubmitting || signUpState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ProgressBar(
                current: _step.index,
                total: SignUpStep.values.length,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _back,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_left, size: 20),
                    Text('Back', style: text.bodyLarge?.copyWith(fontSize: 16)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAccount
                    ? 'Find your pawfect match'
                    : 'Tell us about your \u{1F436} soulmate',
                style: text.titleMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                isAccount
                    ? 'Join Luppy, the dog dating app that helps you find love '
                          'for both you and your furry friend.'
                    : 'Help us find the perfect match for your dog by '
                          'providing some information about them.',
                style: text.bodySmall?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: SignUpStep.values.length,
                  // Keep movement tied to Continue/Back so an incomplete step
                  // cannot be skipped with a swipe.
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _buildStepPage(
                    context,
                    SignUpStep.values[index],
                    isSubmitting,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepPage(
    BuildContext context,
    SignUpStep step,
    bool isSubmitting,
  ) {
    final text = Theme.of(context).textTheme;
    final isAccount = step == SignUpStep.account;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          switch (step) {
            SignUpStep.account => AccountStep(
              key: const ValueKey('account'),
              data: _data,
              onChanged: _update,
            ),
            SignUpStep.dogInfo => _DogInfoStep(
              key: const ValueKey('dog'),
              data: _data,
              onChanged: _update,
              onPickDate: _pickBirthDate,
            ),
            SignUpStep.personality => _PersonalityStep(
              key: const ValueKey('personality'),
              data: _data,
              onChanged: _update,
            ),
          },
          const SizedBox(height: 24),
          _GradientButton(
            label: 'Continue',
            onPressed: _data.isStepValid(step) && !isSubmitting
                ? _continue
                : null,
          ),
          if (isAccount) ...[
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: text.bodySmall?.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text(
                      'Log in',
                      style: text.bodySmall?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class AccountStep extends StatelessWidget {
  final SignUpData data;
  final ValueChanged<SignUpData> onChanged;

  const AccountStep({super.key, required this.data, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabeledField(
          label: 'Email',
          child: TextInput(
            initialValue: data.email,
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => onChanged(data.copyWith(email: v)),
          ),
        ),
        LabeledField(
          label: 'Password',
          child: TextInput(
            initialValue: data.password,
            hint: 'At least 8 characters',
            obscureText: true,
            onChanged: (v) => onChanged(data.copyWith(password: v)),
          ),
        ),
      ],
    );
  }
}

class _PersonalityStep extends StatelessWidget {
  final SignUpData data;
  final ValueChanged<SignUpData> onChanged;

  const _PersonalityStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperament:', style: text.bodyLarge?.copyWith(fontSize: 12)),
        const SizedBox(height: 12),
        ChipWrap(
          children: [
            for (final t in Temperament.values)
              SelectChip(
                label: t.label,
                selected: data.temperaments.contains(t),
                onTap: () => onChanged(data.toggleTemperament(t)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Interests:', style: text.bodyLarge?.copyWith(fontSize: 12)),
        const SizedBox(height: 12),
        ChipWrap(
          children: [
            for (final i in DogInterest.values)
              SelectChip(
                label: i.label,
                selected: data.interests.contains(i),
                onTap: () => onChanged(data.toggleInterest(i)),
              ),
          ],
        ),
      ],
    );
  }
}

class _DogInfoStep extends StatelessWidget {
  final SignUpData data;
  final ValueChanged<SignUpData> onChanged;
  final VoidCallback onPickDate;

  const _DogInfoStep({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final age = data.ageAt(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: "Dog's Name",
          child: TextInput(
            initialValue: data.dogName,
            hint: "Enter your dog's name",
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => onChanged(data.copyWith(dogName: v)),
          ),
        ),
        LabeledField(
          label: "Dog's Age",
          child: GestureDetector(
            onTap: onPickDate,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _fieldDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      age?.label ?? 'Select Age',
                      style: TextStyle(
                        fontSize: 12,
                        color: age == null
                            ? const Color(0xFF7C7C86)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ),
        ),
        LabeledField(
          label: 'Breed',
          child: TextInput(
            initialValue: data.breed,
            hint: "Enter your dog's breed",
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => onChanged(data.copyWith(breed: v)),
          ),
        ),
        OptionRow<DogGender>(
          label: 'Gender:',
          options: DogGender.values,
          selected: data.gender,
          labelOf: (g) => g.label,
          onSelected: (g) => onChanged(data.copyWith(gender: g)),
        ),
        const SizedBox(height: 20),
        OptionRow<DogSize>(
          label: 'Size:',
          options: DogSize.values,
          selected: data.size,
          labelOf: (s) => s.label,
          onSelected: (s) => onChanged(data.copyWith(size: s)),
        ),
      ],
    );
  }
}

BoxDecoration _fieldDecoration() => BoxDecoration(
  color: const Color(0xFF131317),
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: const Color(0xFF2E2E36)),
);

/// Pink gradient Continue button; dimmed and inactive when [onPressed] is null.
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
            colors: [_SignUpScreenState._pinkLight, _SignUpScreenState._pink],
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
