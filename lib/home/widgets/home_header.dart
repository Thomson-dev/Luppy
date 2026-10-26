import 'package:flutter/material.dart';

/// Top of the Home screen: "Luppy" logo, notification bell, menu icon,
/// and the search field below them.
class HomeHeader extends StatelessWidget {
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onMenuTap;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  const HomeHeader({
    super.key,
    this.hasUnreadNotifications = true,
    this.onNotificationsTap,
    this.onMenuTap,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset('assets/Luppy.png', height: 32),
          actions: [
            _BellButton(
              showDot: hasUnreadNotifications,
              onTap: onNotificationsTap,
            ),
            const SizedBox(width: 16),
            _MenuButton(onTap: onMenuTap),
            const SizedBox(width: 20),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: LuppySearchField(
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted,
          ),
        ),
      ],
    );
  }
}

class LuppyLogo extends StatelessWidget {
  const LuppyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/Luppy.png', height: 32);
  }
}

class _BellButton extends StatelessWidget {
  final bool showDot;
  final VoidCallback? onTap;

  const _BellButton({required this.showDot, this.onTap});

  static const _dotYellow = Color(0xFFF5C842);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Image.asset('assets/Notification 4.png', width: 26, height: 26),
            if (showDot)
              Positioned(
                top: 2,
                right: 3,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _dotYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Three-line menu icon with a shorter middle line, as in the design.
class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Image.asset('assets/Menu.png', width: 28, height: 28),
      ),
    );
  }
}

class LuppySearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hint;

  const LuppySearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hint = 'Search',
  });

  static const _fill = Color(0xFF131317);
  static const _border = Color(0xFF2E2E36);

  OutlineInputBorder _outline(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7C7C86), fontSize: 14),
        filled: true,
        fillColor: _fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        suffixIcon: controller == null
            ? const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.search, color: Color(0xFF7C7C86), size: 24),
              )
            : ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller!,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF7C7C86),
                        size: 24,
                      ),
                    );
                  }
                  return IconButton(
                    tooltip: 'Clear search',
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF7C7C86),
                      size: 20,
                    ),
                    onPressed: () {
                      controller!.clear();
                      onChanged?.call('');
                    },
                  );
                },
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 40),
        border: _outline(_border),
        enabledBorder: _outline(_border),
        focusedBorder: _outline(const Color(0xFF5A5A66)),
      ),
    );
  }
}
