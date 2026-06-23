import 'dart:io';

import 'package:image/image.dart' as img;

/// 将图片文件沿垂直轴左右翻转（与取景预览的 flipX 一致）。
Future<void> flipImageFileHorizontally(String path, {int jpegQuality = 92}) async {
  final file = File(path);
  if (!await file.exists()) return;

  final bytes = await file.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return;

  final flipped = img.flipHorizontal(decoded);
  await file.writeAsBytes(img.encodeJpg(flipped, quality: jpegQuality));
}
