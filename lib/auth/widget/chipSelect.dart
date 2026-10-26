import 'package:flutter/material.dart';


/// Lavender pill; gets a pink outline when selected.
const Color _lavender = Color(0xFFE6DDF5);
const Color _pink = Color(0xFFFF6FAE);
class ChipWrap extends StatelessWidget {
  final List<Widget> children;

  const ChipWrap({required this.children});

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 12, children: children);
}



class SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          // Background changes when selected
          color: selected
              ? const Color(0xFF14151A)
              : _lavender,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _pink : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : const Color(0xFF1B1B1F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class RadioDot extends StatelessWidget {
  final bool selected;

  const RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _pink : Colors.transparent,
        border: Border.all(
          color: selected ? _pink : Colors.white70,
          width: 1.2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
