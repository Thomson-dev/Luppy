import 'package:flutter/material.dart';

const Color _pink = Color(0xFFFF4F9A);

class ActionBar extends StatelessWidget {
  final VoidCallback onMessage;
  final VoidCallback onPass;
  final VoidCallback onLike;

  const ActionBar({
    required this.onMessage,
    required this.onPass,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131317),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _pink.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundButton(
            label: 'Send message',
            color: _pink,
            icon: Icons.chat_bubble,
            onTap: onMessage,
          ),
          _RoundButton(
            label: 'Pass',
            color: const Color(0xFFF5C842),
            icon: Icons.close,
            outlined: true,
            onTap: onPass,
          ),
          _RoundButton(
            label: 'Like',
            color: const Color(0xFF22DD3A),
            icon: Icons.favorite,
            onTap: onLike,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;

  const _RoundButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: outlined ? Colors.transparent : color,
            border: outlined ? Border.all(color: color) : null,
            boxShadow: outlined
                ? null
                : [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)],
          ),
          child: Icon(icon, size: 22, color: outlined ? color : Colors.black87),
        ),
      ),
    );
  }
}
