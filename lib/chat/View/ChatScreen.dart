import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luppy/chat/Model/Chat.dart';
import 'package:luppy/chat/Model/Mesaage.dart';
import 'package:luppy/chat/widgets/Bubble.dart';
import 'package:luppy/chat/widgets/Input.dart';
import 'package:luppy/chat/provider/chat_provider.dart';
import 'package:luppy/utils/image_helper.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  late final List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.chat.messages);
  }

  Future<void> _pickAndSendPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        ref.read(chatListProvider.notifier).sendMessage(
          chatId: widget.chat.id,
          text: '📷 Photo',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not attach image: $e')),
        );
      }
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    ref
        .read(chatListProvider.notifier)
        .sendMessage(chatId: widget.chat.id, text: text)
        .catchError((Object error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not send message: $error')),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatListProvider);
    final currentChat = chatState is AsyncData<List<Chat>>
        ? chatState.value.where((chat) => chat.id == widget.chat.id).firstOrNull
        : null;
    final user = currentChat?.user ?? widget.chat.user;

    // Real-time WebSocket stream from Supabase for live messaging between real users!
    final liveMessagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.chat.id));
    final messages = (liveMessagesAsync.hasValue &&
            liveMessagesAsync.value!.isNotEmpty)
        ? liveMessagesAsync.value!
        : (currentChat?.messages.isNotEmpty == true
            ? currentChat!.messages
            : _messages);
    final signedInUserId =
        Supabase.instance.client.auth.currentUser?.id ?? currentUserId;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            _Avatar(url: user.avatarUrl, isOnline: user.isOnline, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: text.titleMedium),
                Text(
                  user.isOnline ? 'Active Now' : 'Offline',
                  style: text.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/camera.png', width: 24, height: 24),
            onPressed: () => _pickAndSendPhoto(ImageSource.camera),
          ),
          IconButton(
            icon: Image.asset('assets/Call.png', width: 24, height: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${user.name}... Audio calls coming soon!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.all(16),
              children: [
                for (final m in messages.reversed)
                  Bubble(
                    message: m,
                    isMine: m.isMine(signedInUserId),
                    senderName: m.isMine(signedInUserId)
                        ? 'You'
                        : widget.chat.user.name,
                    senderAvatarUrl: m.isMine(signedInUserId)
                        ? null
                        : widget.chat.user.avatarUrl,
                  ),
                // const Center(child: _DayPill('today')),
              ],
            ),
          ),
          InputBar(
            controller: _controller,
            onSend: _send,
            onAttach: () => _pickAndSendPhoto(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final bool isOnline;
  final double size;

  const _Avatar({
    required this.url,
    required this.isOnline,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundImage: url.isEmpty ? null : appImageProvider(url),
          child: url.isEmpty ? Icon(Icons.person, size: size / 2) : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
