import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/photo_source.dart';
import '../../shared/models/treatment_type.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({
    super.key,
    required this.spotId,
    required this.photoPath,
    this.isExternalCamera = false,
  });

  final String spotId;
  final String photoPath;
  final bool isExternalCamera;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _noteController = TextEditingController();
  final List<_TreatmentRow> _treatments = [_TreatmentRow()];
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    for (final t in _treatments) {
      t.dispose();
    }
    super.dispose();
  }

  void _addTreatment() {
    setState(() => _treatments.add(_TreatmentRow()));
  }

  void _removeTreatment(int index) {
    if (_treatments.length <= 1) return;
    setState(() {
      _treatments[index].dispose();
      _treatments.removeAt(index);
    });
  }

  void _applyTag(String tag) {
    final empty = _treatments.indexWhere((t) => t.nameController.text.isEmpty);
    if (empty >= 0) {
      setState(() => _treatments[empty].nameController.text = tag);
    } else {
      setState(() {
        final row = _TreatmentRow();
        row.nameController.text = tag;
        _treatments.add(row);
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final entries = _treatments
          .where((t) => t.nameController.text.trim().isNotEmpty)
          .map(
            (t) => TreatmentEntry(
              type: t.type,
              name: t.nameController.text,
              dosage: t.dosageController.text,
            ),
          )
          .toList();

      final source = widget.isExternalCamera
          ? PhotoSource.external
          : PhotoSource.builtin;

      await ref.read(checkInRepositoryProvider).createCheckIn(
            spotId: widget.spotId,
            photoSourcePath: widget.photoPath,
            source: source,
            treatments: entries,
            note: _noteController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打卡成功')),
        );
        context.go('/timeline/${widget.spotId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('护理记录'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(widget.photoPath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '今日备注',
                hintText: '描述痘痘状态变化...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '护理项目',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: _addTreatment,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('添加'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonTreatmentTags
                  .map(
                    (tag) => ActionChip(
                      label: Text(tag),
                      onPressed: () => _applyTag(tag),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ...List.generate(_treatments.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TreatmentForm(
                  row: _treatments[index],
                  onRemove: _treatments.length > 1
                      ? () => _removeTreatment(index)
                      : null,
                ),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('保存打卡'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreatmentRow {
  TreatmentType type = TreatmentType.medication;
  final nameController = TextEditingController();
  final dosageController = TextEditingController();

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
  }
}

class _TreatmentForm extends StatefulWidget {
  const _TreatmentForm({required this.row, this.onRemove});

  final _TreatmentRow row;
  final VoidCallback? onRemove;

  @override
  State<_TreatmentForm> createState() => _TreatmentFormState();
}

class _TreatmentFormState extends State<_TreatmentForm> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TreatmentType>(
                    value: widget.row.type,
                    decoration: const InputDecoration(
                      labelText: '类型',
                      isDense: true,
                    ),
                    items: TreatmentType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => widget.row.type = v);
                    },
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.row.nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如：阿达帕林凝胶',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.row.dosageController,
              decoration: const InputDecoration(
                labelText: '用法/剂量（可选）',
                hintText: '例如：每晚薄涂',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
