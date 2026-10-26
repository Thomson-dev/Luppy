import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Model/Profile.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  /// Fetches the profile of the current logged-in user's dog.
  Future<DogProfile?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('dogs')
        .select()
        .eq('owner_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DogProfile.fromJson(response);
  }

  /// Uploads a local photo to Supabase Storage and returns the public URL.
  Future<String> uploadPhoto(String localPath) async {
    debugPrint('[ProfileRepository] Uploading photo: $localPath');
    final file = File(localPath);
    if (!await file.exists()) {
      debugPrint(
        '[ProfileRepository] Photo file not found, keeping path: $localPath',
      );
      return localPath;
    }

    final user = _supabase.auth.currentUser;
    final extension = localPath.split('.').last;
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${user?.id ?? "dog"}.$extension';
    final storagePath = '${user?.id ?? "public"}/$fileName';

    try {
      await _supabase.storage
          .from('dog_photos')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      final publicUrl = _supabase.storage
          .from('dog_photos')
          .getPublicUrl(storagePath);
      debugPrint('[ProfileRepository] Photo uploaded: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[ProfileRepository] Photo upload failed: $e');
      // If bucket upload fails (e.g. bucket doesn't exist yet), return path
      return localPath;
    }
  }

  /// Saves or updates the dog profile in Supabase.
  Future<DogProfile> saveProfile(DogProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // Upload local photos to storage first
    final resolvedPhotos = <String>[];
    for (final photo in profile.photos) {
      if (photo.startsWith('/') || photo.startsWith('file://')) {
        final publicUrl = await uploadPhoto(photo);
        resolvedPhotos.add(publicUrl);
      } else {
        resolvedPhotos.add(photo);
      }
    }

    final updatedProfile = profile.copyWith(photos: resolvedPhotos);

    final payload = {
      'owner_id': user.id,
      'name': updatedProfile.name.trim(),
      'about': updatedProfile.about.trim(),
      'birth_date': updatedProfile.birthDate
          ?.toIso8601String()
          .split('T')
          .first,
      'breed': updatedProfile.breed.trim(),
      'gender': updatedProfile.gender?.name,
      'size': updatedProfile.size?.name,
      'photos': updatedProfile.photos,
      'image_url': updatedProfile.photos.isNotEmpty
          ? updatedProfile.photos.first
          : '',
      'temperaments': updatedProfile.temperaments.map((e) => e.name).toList(),
      'interests': updatedProfile.interests.map((e) => e.name).toList(),
      'energy_level': updatedProfile.energyLevel,
      'is_trained': updatedProfile.isTrained,
      'instagram': updatedProfile.instagram.trim(),
    };

    // If we have an existing database record
    if (profile.id.isNotEmpty && !profile.id.startsWith('u_')) {
      final updated = await _supabase
          .from('dogs')
          .update(payload)
          .eq('id', profile.id)
          .select()
          .maybeSingle();
      if (updated != null) {
        return DogProfile.fromJson(updated);
      }
      return updatedProfile;
    } else {
      // Check if this user already has a dog record in the database
      final existing = await _supabase
          .from('dogs')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        final existingId = existing['id'].toString();
        final updated = await _supabase
            .from('dogs')
            .update(payload)
            .eq('id', existingId)
            .select()
            .single();
        return DogProfile.fromJson(updated);
      } else {
        final inserted = await _supabase
            .from('dogs')
            .insert(payload)
            .select()
            .single();
        return DogProfile.fromJson(inserted);
      }
    }
  }
}
