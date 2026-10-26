import 'package:flutter/material.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onVoice;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            IconButton(
              icon: Image.asset('assets/link.png', width: 20, height: 20),
              onPressed: onAttach ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attachment options coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write your message',
                  hintStyle: const TextStyle(
                    color: Color(0xFF7C7C86),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF16161A),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Image.asset(
                      'assets/Message 22.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: onSend,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/Frame 163045.png',
                width: 45,
                height: 45,
              ),
              onPressed: onVoice ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice messaging coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}
