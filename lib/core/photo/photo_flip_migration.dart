import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import 'photo_image_utils.dart';

const photoFlipMigrationPrefsKey = 'photos_flip_x_migrated_v1';

class PhotoFlipMigrationResult {
  const PhotoFlipMigrationResult({
    required this.flipped,
    required this.skipped,
    this.alreadyDone = false,
  });

  final int flipped;
  final int skipped;
  final bool alreadyDone;
}

class PhotoFlipMigrationService {
  PhotoFlipMigrationService(this._db);

  final AppDatabase _db;

  Future<bool> isMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(photoFlipMigrationPrefsKey) ?? false;
  }

  Future<PhotoFlipMigrationResult> migrateCameraPhotos() async {
    if (await isMigrated()) {
      return const PhotoFlipMigrationResult(
        flipped: 0,
        skipped: 0,
        alreadyDone: true,
      );
    }

    final photos = await _db.getCameraPhotos();
    var flipped = 0;
    var skipped = 0;

    for (final photo in photos) {
      final file = File(photo.filePath);
      if (!await file.exists()) {
        skipped++;
        continue;
      }
      try {
        await flipImageFileHorizontally(photo.filePath);
        flipped++;
      } catch (_) {
        skipped++;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(photoFlipMigrationPrefsKey, true);

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    return PhotoFlipMigrationResult(flipped: flipped, skipped: skipped);
  }
}
