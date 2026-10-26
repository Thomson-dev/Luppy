import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Model/Chat.dart';
import '../Model/Mesaage.dart';
import '../../home/model/Dog.dart';
import '../../home/model/Event.dart';

class ChatRepository {
  ChatRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Fetches real 1-on-1 chats for the current user from Supabase.
  Future<List<Chat>> fetchChats() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return dummyChats;

    try {
      final rows = await _supabase
          .from('chats')
          .select('id, user_a, user_b, created_at, updated_at')
          .or('user_a.eq.${currentUser.id},user_b.eq.${currentUser.id}')
          .order('updated_at', ascending: false);

      if (rows.isEmpty) return dummyChats;

      final chats = <Chat>[];
      for (final row in rows) {
        final userA = row['user_a'] as String;
        final userB = row['user_b'] as String;
        final otherUserId = userA == currentUser.id ? userB : userA;

        // Fetch other user's dog profile
        Member member = Member(
          id: otherUserId,
          name: 'Pet Friend',
          avatarUrl:
              'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
          isOnline: true,
        );

        try {
          final dogResponse = await _supabase
              .from('dogs')
              .select('id, name, photos, image_url, is_online')
              .eq('owner_id', otherUserId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (dogResponse != null) {
            final photos = (dogResponse['photos'] as List?)?.cast<String>() ?? [];
            final img = photos.isNotEmpty
                ? photos.first
                : (dogResponse['image_url'] as String? ?? '');
            member = Member(
              id: dogResponse['id'] as String,
              name: dogResponse['name'] as String? ?? 'Pet Friend',
              avatarUrl: img.isEmpty
                  ? 'https://images.unsplash.com/photo-1543466835-00a7907e9de1'
                  : img,
              isOnline: dogResponse['is_online'] as bool? ?? false,
            );
          } else {
            // Check profiles table fallback
            final profile = await _supabase
                .from('profiles')
                .select('id, display_name, avatar_url')
                .eq('id', otherUserId)
                .maybeSingle();

            if (profile != null) {
              member = Member(
                id: profile['id'] as String,
                name: profile['display_name'] as String? ?? 'Pet Friend',
                avatarUrl: profile['avatar_url'] as String? ?? '',
              );
            }
          }
        } catch (_) {}

        final messages = await fetchMessages(row['id'] as String);
        chats.add(
          Chat(
            id: row['id'] as String,
            user: member,
            messages: messages,
          ),
        );
      }

      return chats.isNotEmpty ? chats : dummyChats;
    } catch (e) {
      debugPrint('[ChatRepository] Error fetching chats: $e');
      return dummyChats;
    }
  }

  /// Finds or creates a real 1-on-1 chat room between the current user and the other dog's owner.
  Future<Chat> getOrCreateChatForDog(Dog otherDog) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      return _localChat(otherDog);
    }

    try {
      // 1. Look up the other dog in Supabase to find their owner_id
      String? otherOwnerId;
      final dogRow = await _supabase
          .from('dogs')
          .select('id, owner_id, name, image_url, photos, is_online')
          .eq('id', otherDog.id)
          .maybeSingle();

      if (dogRow != null && dogRow['owner_id'] != null) {
        otherOwnerId = dogRow['owner_id'] as String;
      }

      // If other dog has no owner_id in database (sample mock dog), use local chat
      if (otherOwnerId == null || otherOwnerId == currentUser.id) {
        return _localChat(otherDog);
      }

      // 2. Order user IDs to enforce unique pair (user_a < user_b)
      final userA =
          currentUser.id.compareTo(otherOwnerId) < 0 ? currentUser.id : otherOwnerId;
      final userB =
          currentUser.id.compareTo(otherOwnerId) < 0 ? otherOwnerId : currentUser.id;

      // 3. Find existing chat
      final existingChat = await _supabase
          .from('chats')
          .select('id')
          .eq('user_a', userA)
          .eq('user_b', userB)
          .maybeSingle();

      String chatId;
      if (existingChat != null) {
        chatId = existingChat['id'] as String;
      } else {
        // Create new chat room
        final newChat = await _supabase
            .from('chats')
            .insert({'user_a': userA, 'user_b': userB})
            .select('id')
            .single();
        chatId = newChat['id'] as String;
      }

      // 4. Fetch existing messages
      final messages = await fetchMessages(chatId);

      return Chat(
        id: chatId,
        user: Member(
          id: otherDog.id,
          name: otherDog.name,
          avatarUrl: otherDog.imageUrl,
          isOnline: otherDog.isOnline,
        ),
        messages: messages,
      );
    } catch (e) {
      debugPrint('[ChatRepository] Error getting/creating chat: $e');
      return _localChat(otherDog);
    }
  }

  Chat _localChat(Dog dog) {
    return Chat(
      id: 'c_${dog.id}',
      user: Member(
        id: dog.id,
        name: dog.name,
        avatarUrl: dog.imageUrl,
        isOnline: dog.isOnline,
      ),
      messages: const [],
    );
  }

  /// Fetches messages for a given chat room.
  Future<List<Message>> fetchMessages(String chatId) async {
    if (chatId.startsWith('c_')) return [];
    try {
      final rows = await _supabase
          .from('messages')
          .select('id, sender_id, text, sent_at')
          .eq('chat_id', chatId)
          .order('sent_at');

      return rows.map((row) => Message.fromJson(Map<String, dynamic>.from(row))).toList();
    } catch (e) {
      debugPrint('[ChatRepository] Error fetching messages: $e');
      return [];
    }
  }

  /// Sends a real message to the database and updates chat updated_at timestamp.
  Future<Message> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
  }) async {
    final row = await _supabase
        .from('messages')
        .insert({
          'chat_id': chatId,
          'sender_id': senderId,
          'text': text.trim(),
        })
        .select('id, sender_id, text, sent_at')
        .single();

    try {
      await _supabase
          .from('chats')
          .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', chatId);
    } catch (_) {}

    return Message.fromJson(Map<String, dynamic>.from(row));
  }

  /// Listens to live messages via Supabase Realtime WebSocket connection!
  Stream<List<Message>> streamMessages(String chatId) {
    if (chatId.startsWith('c_')) {
      return const Stream.empty();
    }

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('sent_at')
        .map((rows) {
          return rows.map((r) => Message.fromJson(Map<String, dynamic>.from(r))).toList();
        });
  }
}
