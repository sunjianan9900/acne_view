import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

Future<void> exportPhotoFile(BuildContext context, String sourcePath) async {
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('照片文件不存在，无法导出')),
      );
    }
    return;
  }

  final rawExt = p.extension(sourcePath).replaceFirst('.', '');
  final basename = p.basenameWithoutExtension(sourcePath);
  final timestamp = DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now());
  final ext = (rawExt.isNotEmpty ? rawExt : 'jpg').toLowerCase();
  final suggestedName = basename.isNotEmpty && !RegExp(r'^\d+$').hasMatch(basename)
      ? '$basename.$ext'
      : 'douji-photo-$timestamp.$ext';

  final savePath = await FilePicker.platform.saveFile(
    dialogTitle: '导出照片',
    fileName: suggestedName,
    type: FileType.custom,
    allowedExtensions: [ext],
  );
  if (savePath == null) return;

  try {
    await sourceFile.copy(savePath);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('照片已导出至：$savePath')),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$error')),
      );
    }
  }
}
