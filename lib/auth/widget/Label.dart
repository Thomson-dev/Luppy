import 'package:flutter/material.dart';
import 'package:luppy/auth/widget/chipSelect.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// "Gender:  (•) Male  ( ) Female" style row of radio options.
class OptionRow<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  const OptionRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: text.bodyLarge?.copyWith(fontSize: 14)),
        ),
        for (final o in options)
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: GestureDetector(
              onTap: () => onSelected(o),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioDot(selected: o == selected),
                  const SizedBox(width: 8),
                  Text(
                    labelOf(o),
                    style: text.bodyLarge?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
