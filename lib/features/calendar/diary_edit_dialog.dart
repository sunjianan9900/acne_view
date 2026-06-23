import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';

Future<bool?> showDiaryEditDialog(
  BuildContext context,
  WidgetRef ref, {
  DiaryEntry? existing,
  DateTime? initialDate,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => DiaryEditDialog(
      existing: existing,
      initialDate: initialDate,
    ),
  );
}

class DiaryEditDialog extends ConsumerStatefulWidget {
  const DiaryEditDialog({
    super.key,
    this.existing,
    this.initialDate,
  });

  final DiaryEntry? existing;
  final DateTime? initialDate;

  @override
  ConsumerState<DiaryEditDialog> createState() => _DiaryEditDialogState();
}

class _DiaryEditDialogState extends ConsumerState<DiaryEditDialog> {
  late DateTime _entryDate;
  final _contentController = TextEditingController();
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _entryDate = existing.entryDate;
      _contentController.text = existing.content;
    } else {
      final initial = widget.initialDate ?? DateTime.now();
      _entryDate = DateTime(initial.year, initial.month, initial.day);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '选择日记日期',
    );
    if (picked != null) {
      setState(() => _entryDate = picked);
    }
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请写下今天的心情')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(diaryRepositoryProvider);
      if (_isEditing) {
        await repo.updateEntry(
          id: widget.existing!.id,
          entryDate: _entryDate,
          content: content,
        );
      } else {
        await repo.createEntry(entryDate: _entryDate, content: content);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除日记'),
        content: const Text('确定要删除这条日记吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref.read(diaryRepositoryProvider).deleteEntry(existing.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy年M月d日').format(_entryDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? '编辑日记' : '新建日记',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _saving ? null : _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.panelBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppTheme.brandPink,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _contentController,
                maxLines: 6,
                minLines: 4,
                enabled: !_saving,
                decoration: InputDecoration(
                  hintText: '写下今天的心情、皮肤状态或任何想记录的事…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.panelBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.panelBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.brandPink),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_isEditing) ...[
                    TextButton(
                      onPressed: _saving ? null : _delete,
                      child: const Text(
                        '删除',
                        style: TextStyle(color: AppTheme.accentCoral),
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? '保存' : '创建'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
