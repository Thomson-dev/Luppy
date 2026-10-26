import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/widget/logout_dialog.dart';
import 'package:luppy/notification/widgets/notification_button.dart';
import 'package:luppy/profile/Model/Profile.dart';
import 'package:luppy/profile/View/EditProfileScreen.dart';
import 'package:luppy/profile/provider/profile_provider.dart';
import 'package:luppy/profile/widgets/profileCard.dart';

const _pink = Color(0xFFFF4F9A);
const _pinkLight = Color(0xFFFF8FC4);

class ProfileScreen extends ConsumerStatefulWidget {
  final DogProfile? profile;
  final List<SubscriptionPlan> plans;
  final VoidCallback? onEdit; // "Complete My Profile" / "Edit" / camera
  final VoidCallback? onUpgrade;

  const ProfileScreen({
    super.key,
    this.profile,
    required this.plans,
    this.onEdit,
    this.onUpgrade,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final int _startPage = widget.plans.length > 1 ? 1 : 0;

  // viewportFraction < 1 lets the neighbouring plans peek in from the sides.
  late final _controller = PageController(
    viewportFraction: 0.62,
    initialPage: _startPage,
  );
  late int _page = _startPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// "$2,99" for the cheapest plan.
  String get _cheapestLabel =>
      widget.plans.reduce((a, b) => a.price <= b.price ? a : b).priceLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profileAsync = ref.watch(profileNotifierProvider);
    final activeProfile = widget.profile ?? profileAsync.value ?? lokiProfile;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text('Profile', style: text.titleMedium?.copyWith(fontSize: 18)),
        actions: [
          const NotificationButton(),
          IconButton(
            icon: Image.asset('assets/Menu.png', width: 28, height: 28),
            onPressed: () => showAppMenuSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: profileAsync.isLoading && widget.profile == null
                  ? const Center(child: CircularProgressIndicator(color: _pink))
                  : ProfileCard(
                      profile: activeProfile,
                      onEdit:
                          widget.onEdit ??
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfileScreen(profile: activeProfile),
                            ),
                          ),
                    ),
            ),
          ),

          if (widget.plans.isNotEmpty) ...[
            SizedBox(
              height: 96,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.plans.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) =>
                    _PlanCard(plan: widget.plans[i], selected: i == _page),
              ),
            ),
            const SizedBox(height: 12),
            _Dots(count: widget.plans.length, current: _page),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _GradientButton(
                label: 'Upgrade From $_cheapestLabel',
                onPressed: widget.onUpgrade,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => showLogoutDialog(context, ref),
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE8505F),
                size: 18,
              ),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFE8505F),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool selected;

  const _PlanCard({required this.plan, required this.selected});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF131317),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _pink : const Color(0xFF2E2E36),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pentagon_outlined, size: 20),
          const SizedBox(height: 8),
          Text(
            plan.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.priceLabel,
            style: text.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          Container(
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

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GradientButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_pinkLight, _pink]),
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
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
