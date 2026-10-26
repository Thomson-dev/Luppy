import 'package:flutter/material.dart';
import 'package:luppy/chat/Model/Mesaage.dart';
import 'package:luppy/utils/image_helper.dart';

class Bubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final String senderName;
  final String? senderAvatarUrl;

  const Bubble({
    required this.message,
    required this.isMine,
    required this.senderName,
    this.senderAvatarUrl,
  });

  String _time(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMine) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: senderAvatarUrl == null
                    ? null
                    : _imageProvider(senderAvatarUrl!),
                child: senderAvatarUrl == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(senderName, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.text,
                      style: text.bodyLarge?.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _time(message.sentAt),
                    style: text.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _imageProvider(String url) {
    return appImageProvider(url);
  }
}
