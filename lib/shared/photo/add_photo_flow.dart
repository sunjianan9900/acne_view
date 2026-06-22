import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../models/photo_source.dart';

/// 展示「拍摄」或「从相册/文件选择」的添加照片入口。
Future<void> showAddPhotoOptions(BuildContext context, String spotId) async {
  final action = await showModalBottomSheet<_AddPhotoAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.panelBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '添加照片',
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '拍摄新照片，或从本地选择已有图片',
              style: Theme.of(
                ctx,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _AddPhotoOptionTile(
              icon: Icons.camera_alt_outlined,
              title: '拍摄新照片',
              subtitle: '使用摄像头实时拍摄',
              onTap: () => Navigator.pop(ctx, _AddPhotoAction.camera),
            ),
            const SizedBox(height: 10),
            _AddPhotoOptionTile(
              icon: Icons.photo_library_outlined,
              title: '从相册/文件选择',
              subtitle: '上传本地已有图片',
              onTap: () => Navigator.pop(ctx, _AddPhotoAction.gallery),
            ),
          ],
        ),
      ),
    ),
  );

  if (!context.mounted || action == null) return;

  switch (action) {
    case _AddPhotoAction.camera:
      await context.push('/capture/$spotId');
    case _AddPhotoAction.gallery:
      await pickImageAndCheckIn(context, spotId);
  }
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

enum _AddPhotoAction { camera, gallery }

class _AddPhotoOptionTile extends StatelessWidget {
  const _AddPhotoOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.panelBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.softRose,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.brandPink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
