import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/photo_source.dart';

/// 进入拍摄界面添加照片；相册选择入口在拍摄页快门按钮左侧。
Future<void> showAddPhotoOptions(BuildContext context, String spotId) async {
  await context.push('/capture/$spotId');
}

Future<void> pickImageAndCheckIn(BuildContext context, String spotId) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: false,
  );

  if (result == null || result.files.isEmpty) return;

  final path = result.files.single.path;
  if (path == null || path.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('无法读取所选图片')));
    }
    return;
  }

  if (!context.mounted) return;

  await context.push(
    '/check-in',
    extra: {
      'spotId': spotId,
      'photoPath': path,
      'photoSource': PhotoSource.gallery,
    },
  );
}
