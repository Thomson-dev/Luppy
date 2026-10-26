import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/provider/sign_up_provider.dart';
import 'package:luppy/auth/view/sign_in_screen.dart';

/// Shows a confirmation dialog to log out of the current session.
Future<void> showLogoutDialog(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF16161A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Log Out',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Are you sure you want to log out of Luppy?',
        style: TextStyle(color: Color(0xFFB4B4BC)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(
            'Log Out',
            style: TextStyle(
              color: Color(0xFFE8505F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

/// Shows a bottom sheet menu with options including log out.
Future<void> showAppMenuSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16161A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFE8505F)),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFE8505F),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showLogoutDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

