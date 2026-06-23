import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/backup/backup_provider.dart';
import '../../core/photo/photo_flip_migration_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/douji_shell.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DoujiShell(
      title: '设置',
      subtitle: '数据备份与恢复',
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _DataBackupSection(),
          SizedBox(height: 16),
          _PhotoFlipMigrationSection(),
        ],
      ),
    );
  }
}

class _DataBackupSection extends ConsumerStatefulWidget {
  const _DataBackupSection();

  @override
  ConsumerState<_DataBackupSection> createState() => _DataBackupSectionState();
}

class _DataBackupSectionState extends ConsumerState<_DataBackupSection> {
  bool _busy = false;
  String? _statusMessage;
  bool _statusIsError = false;

  Future<void> _exportBackup() async {
    if (_busy) return;

    final timestamp = DateFormat('yyyy-MM-dd-HHmm').format(DateTime.now());
    final suggestedName = 'douji-backup-$timestamp.zip';

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: '导出数据备份',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (savePath == null) return;

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      final service = ref.read(dataBackupServiceProvider);
      await service.exportToZip(savePath);
      if (!mounted) return;
      setState(() {
        _statusMessage = '备份已导出至：$savePath';
        _statusIsError = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '导出失败：$error';
        _statusIsError = true;
      });
    } finally {
      invalidateDataProviders(ref);
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _importBackup() async {
    if (_busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复数据'),
        content: const Text(
          '导入备份将覆盖当前所有痘痘记录、打卡照片与标签设置，此操作不可撤销。确定继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择备份文件',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final zipPath = result.files.single.path;
    if (zipPath == null || zipPath.isEmpty) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '无法读取所选备份文件';
        _statusIsError = true;
      });
      return;
    }

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      final service = ref.read(dataBackupServiceProvider);
      await service.restoreFromZip(zipPath);
      if (!mounted) return;
      setState(() {
        _statusMessage = '数据已成功恢复';
        _statusIsError = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '恢复失败：$error';
        _statusIsError = true;
      });
    } finally {
      invalidateDataProviders(ref);
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.softRose,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.backup_outlined,
                  size: 18,
                  color: AppTheme.brandPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数据备份与恢复',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '打包导出全部打卡记录、照片与标签；也可从备份文件一键恢复',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _exportBackup,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_outlined, size: 18),
                label: const Text('导出备份'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _importBackup,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('导入恢复'),
              ),
            ],
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _statusMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _statusIsError
                    ? Theme.of(context).colorScheme.error
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoFlipMigrationSection extends ConsumerStatefulWidget {
  const _PhotoFlipMigrationSection();

  @override
  ConsumerState<_PhotoFlipMigrationSection> createState() =>
      _PhotoFlipMigrationSectionState();
}

class _PhotoFlipMigrationSectionState
    extends ConsumerState<_PhotoFlipMigrationSection> {
  bool _busy = false;
  String? _statusMessage;
  bool _statusIsError = false;

  Future<void> _runMigration() async {
    if (_busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('翻转历史相机照片'),
        content: const Text(
          '将把此前通过内置/外接摄像头拍摄并已保存的照片左右翻转，使其与当前取景预览方向一致。\n\n'
          '相册上传的照片不会处理。此操作只能执行一次，且会直接覆盖原图文件，建议先导出备份。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('开始处理'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      final service = ref.read(photoFlipMigrationServiceProvider);
      final result = await service.migrateCameraPhotos();
      if (!mounted) return;

      if (result.alreadyDone) {
        setState(() {
          _statusMessage = '历史照片已处理过，无需重复操作';
          _statusIsError = false;
        });
      } else {
        setState(() {
          _statusMessage =
              '已翻转 ${result.flipped} 张相机照片'
              '${result.skipped > 0 ? '，${result.skipped} 张跳过' : ''}';
          _statusIsError = false;
        });
      }
      ref.invalidate(photoFlipMigrationDoneProvider);
      invalidateDataProviders(ref);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '处理失败：$error';
        _statusIsError = true;
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final migrationDone = ref.watch(photoFlipMigrationDoneProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.softRose,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flip_outlined,
                  size: 18,
                  color: AppTheme.brandPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '历史照片方向校正',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '一次性翻转此前相机拍摄的照片，使其与取景预览左右一致（相册照片不受影响）',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          migrationDone.when(
            data: (done) {
              if (done) {
                return Text(
                  '历史相机照片已校正完成',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                );
              }
              return OutlinedButton.icon(
                onPressed: _busy ? null : _runMigration,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.flip_outlined, size: 18),
                label: const Text('翻转历史相机照片'),
              );
            },
            loading: () => const SizedBox(
              height: 36,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => OutlinedButton.icon(
              onPressed: _busy ? null : _runMigration,
              icon: const Icon(Icons.flip_outlined, size: 18),
              label: const Text('翻转历史相机照片'),
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _statusMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _statusIsError
                    ? Theme.of(context).colorScheme.error
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
