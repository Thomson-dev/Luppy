import 'package:flutter/material.dart';

const _pink = Color(0xFFE8505F);
const _pinkLight = Color(0xFFF08A93);
const _lavender = Color(0xFFE6E0F2);

/// One onboarding slide.
class OnboardingPage {
  final String title;
  final String description;
  final String image; // illustration asset path
  final bool imageFirst; // slide 2 shows the picture above the text

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    this.imageFirst = false,
  });
}

const onboardingPages = [
  OnboardingPage(
    title: 'Welcome to Luppy!',
    description:
        'With our easy-to-use app, you can browse profiles, send '
        'messages, and arrange meetups with other dog owners in your area.',
    image: 'assets/Dog Illustration.png',
  ),
  OnboardingPage(
    title: "Create your dog's profile.",
    description:
        "Include information about your dog's breed, size, "
        'temperament, energy level, and play style.',
    image: 'assets/Dog Illustration (1).png',
    imageFirst: true,
  ),
  OnboardingPage(
    title: 'Start swiping!',
    description:
        "Once you've created your dog's profile, you can start "
        'swiping through potential matches.',
    image: 'assets/Dog Illustration (2).png',
  ),
];

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingPage> pages;

  /// Called by "Skip" and by the arrow button on the last slide.
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    this.pages = onboardingPages,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == widget.pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onFinish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onFinish,
                child: const Text('Skip', style: TextStyle(fontSize: 14 ,color:Colors.white )),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _Slide(page: widget.pages[i]),
              ),
            ),
            _Dots(count: widget.pages.length, current: _page),
            const SizedBox(height: 28),
            _ProgressButton(
              progress: (_page + 1) / widget.pages.length,
              onTap: _next,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final OnboardingPage page;

  const _Slide({required this.page});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final picture = Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Image.asset(
        page.image,
        height: 170,
        // Until the real illustration exists, show a paw.
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.pets, size: 120, color: _lavender),
      ),
    );

    final words = Column(
      children: [
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: text.titleMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          page.description,
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(fontSize: 14, height: 1.5),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: page.imageFirst ? [picture, words] : [words, picture],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == current ? Colors.white : Colors.white24,
            ),
          ),
      ],
    );
  }
}

/// Round arrow button with a ring that fills as you move through the slides.
class _ProgressButton extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final VoidCallback onTap;

  const _ProgressButton({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, _) => SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 2,
                  color: _pink,
                  backgroundColor: _pink.withOpacity(0.2),
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_pinkLight, _pink]),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
