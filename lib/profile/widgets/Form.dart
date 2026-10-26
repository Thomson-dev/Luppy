import 'package:flutter/material.dart';

const Color _fieldBorder = Color(0xFF2E2E36);

class Labeled extends StatelessWidget {
  final String label;
  final Widget child;
 
  const Labeled(this.label, this.child);
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
 
class Input extends StatelessWidget {
  final String initialValue;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String> onChanged;
 
  const Input({
    super.key,
    required this.initialValue,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });
 
  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
 
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7C7C86), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF131317),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 17),
        border: _border(_fieldBorder),
        enabledBorder: _border(_fieldBorder),
        focusedBorder: _border(const Color(0xFF5A5A66)),
      ),
    );
  }
}
