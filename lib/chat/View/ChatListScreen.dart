import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luppy/auth/provider/sign_up_provider.dart';
import 'package:luppy/auth/widget/logout_dialog.dart';
import 'package:luppy/chat/Model/Chat.dart';
import 'package:luppy/chat/View/ChatScreen.dart';
import 'package:luppy/chat/widgets/avater.dart';
import 'package:luppy/home/model/Dog.dart';
import 'package:luppy/home/widgets/new_matches_section.dart';
import 'package:luppy/chat/provider/chat_provider.dart';
import 'package:luppy/notification/widgets/notification_button.dart';

class ChatListScreen extends ConsumerWidget {
  final List<Chat>? chats;

  const ChatListScreen({super.key, this.chats});
  String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final chatState = chats == null ? ref.watch(chatListProvider) : null;
    final chatItems =
        chats ??
        (chatState is AsyncData<List<Chat>> ? chatState.value : const <Chat>[]);
    final matchesAsync = ref.watch(matchesProvider);
    final currentMatches = matchesAsync.value ?? matches;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text('Chats', style: text.titleMedium?.copyWith(fontSize: 18)),
        actions: [
          const NotificationButton(),
          IconButton(
            icon: Image.asset('assets/Menu.png', width: 28, height: 28),
            onPressed: () => showAppMenuSheet(context, ref),
          ),
        ],
      ),

      body:
          chatState?.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ChatError(
              message: 'Could not load chats: $error',
              onRetry: () => ref.invalidate(chatListProvider),
            ),
            data: (_) => _chatList(context, ref, text, chatItems, currentMatches),
          ) ??
          _chatList(context, ref, text, chatItems, currentMatches),
    );
  }

  Widget _chatList(
    BuildContext context,
    WidgetRef ref,
    TextTheme text,
    List<Chat> chatItems,
    List<Dog> currentMatches,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),

      children: [
        NewMatchesSection(
          matches: currentMatches,
          onMatchTap: (dog) async {
            final targetChat = await ref
                .read(chatListProvider.notifier)
                .getOrCreateChatForDog(dog);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(chat: targetChat),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < chatItems.length; index++) ...[
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(chat: chatItems[index]),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Avatar(
                    url: chatItems[index].user.avatarUrl,
                    isOnline: chatItems[index].user.isOnline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chatItems[index].user.name,
                          style: text.titleMedium?.copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chatItems[index].lastMessage?.text ??
                              'Start a conversation',
                          style: text.bodyMedium?.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (chatItems[index].lastMessage != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      _time(chatItems[index].lastMessage!.sentAt),
                      style: text.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (index < chatItems.length - 1)
            const Divider(height: 1, indent: 24, endIndent: 24),
        ],
        const Divider(height: 1, indent: 24, endIndent: 24),
      ],
    );
  }
}

class _ChatError extends StatelessWidget {
  const _ChatError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
