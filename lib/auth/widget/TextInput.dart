import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String initialValue;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  const TextInput({
    required this.initialValue,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c),
    );

    return SizedBox(
      height: 52,
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7C7C86), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF131317),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: border(const Color(0xFF2E2E36)),
          enabledBorder: border(const Color(0xFF2E2E36)),
          focusedBorder: border(const Color(0xFF5A5A66)),
        ),
      ),
    );
  }
}
