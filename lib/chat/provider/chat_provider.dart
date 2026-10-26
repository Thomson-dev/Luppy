import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Model/Chat.dart';
import '../Model/Mesaage.dart';
import '../../home/model/Dog.dart';
import '../repository/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

final chatListProvider = AsyncNotifierProvider<ChatListController, List<Chat>>(
  ChatListController.new,
);

final chatMessagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).streamMessages(chatId);
});

class ChatListController extends AsyncNotifier<List<Chat>> {
  ChatRepository get _repository => ref.read(chatRepositoryProvider);

  @override
  Future<List<Chat>> build() async {
    return _repository.fetchChats();
  }

  Future<Chat> getOrCreateChatForDog(Dog dog) async {
    final chat = await _repository.getOrCreateChatForDog(dog);
    final currentChats = state.value ?? [];
    if (!currentChats.any((c) => c.id == chat.id)) {
      state = AsyncData([chat, ...currentChats]);
    }
    return chat;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final senderId =
        Supabase.instance.client.auth.currentUser?.id ?? currentUserId;

    Message? message;
    if (!chatId.startsWith('c_')) {
      try {
        message = await _repository.sendMessage(
          chatId: chatId,
          text: trimmedText,
          senderId: senderId,
        );
      } catch (_) {}
    }

    message ??= Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: senderId,
      text: trimmedText,
      sentAt: DateTime.now(),
    );

    final currentChats = state.value ?? [];
    state = AsyncData([
      for (final chat in currentChats)
        if (chat.id == chatId)
          chat.copyWith(messages: [...chat.messages, message])
        else
          chat,
    ]);
  }
}
