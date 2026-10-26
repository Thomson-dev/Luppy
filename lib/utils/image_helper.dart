import 'dart:io';
import 'package:flutter/material.dart';

/// Safely resolves any image string (HTTP remote URL, local device file path,
/// or bundled asset path) into the correct Flutter ImageProvider.
ImageProvider appImageProvider(
  String? url, {
  String defaultAsset = 'assets/Dog Illustration.png',
}) {
  if (url == null || url.trim().isEmpty) {
    return AssetImage(defaultAsset);
  }

  final clean = url.trim();

  // 1. Remote Network Image
  if (clean.startsWith('http://') || clean.startsWith('https://')) {
    return NetworkImage(clean);
  }

  // 2. Local Device File (e.g. /data/user/0/... from ImagePicker or cache)
  if (clean.startsWith('/') || clean.startsWith('file://')) {
    final filePath =
        clean.startsWith('file://') ? clean.replaceFirst('file://', '') : clean;
    return FileImage(File(filePath));
  }

  // 3. Bundled Flutter Asset
  return AssetImage(clean);
}

