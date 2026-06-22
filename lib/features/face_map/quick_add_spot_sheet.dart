import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/photo_source.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/widgets/treatment_tags_panel.dart';

class QuickAddSpotSheet extends ConsumerStatefulWidget {
  const QuickAddSpotSheet({
    super.key,
    required this.photoPath,
    required this.initialRegion,
    required this.photoSource,
  });

  final String photoPath;
  final FaceRegion? initialRegion;
  final PhotoSource photoSource;

  @override
  ConsumerState<QuickAddSpotSheet> createState() => _QuickAddSpotSheetState();
}

class _QuickAddSpotSheetState extends ConsumerState<QuickAddSpotSheet> {
  late FaceRegion _selectedRegion;
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final List<_TreatmentRow> _treatments = [_TreatmentRow()];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialRegion ?? FaceRegion.forehead;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    for (final row in _treatments) {
      row.dispose();
    }
    super.dispose();
  }

  void _addTreatment() => setState(() => _treatments.add(_TreatmentRow()));

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

  void _removeTreatment(int index) {
    if (_treatments.length <= 1) return;
    setState(() {
      _treatments[index].dispose();
      _treatments.removeAt(index);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final spotId = await ref
          .read(spotRepositoryProvider)
          .createSpot(
            region: _selectedRegion,
            title: _titleController.text,
            note: _noteController.text,
          );

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

      await ref
          .read(checkInRepositoryProvider)
          .createCheckIn(
            spotId: spotId,
            photoSourcePath: widget.photoPath,
            source: widget.photoSource,
            treatments: entries,
            phase: AcnePhase.swollen,
          );

      if (mounted) {
        Navigator.of(context).pop(spotId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(760.0, constraints.maxWidth);
          final height = math.min(720.0, constraints.maxHeight);
          final previewHeight = math.min(132.0, math.max(96.0, height * 0.16));

          return SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '快速添加痘痘',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: previewHeight,
                      width: double.infinity,
                      child: Image.file(
                        File(widget.photoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppTheme.softBackground,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _titleController,
                            enabled: !_saving,
                            decoration: const InputDecoration(
                              labelText: '标题',
                              hintText: '例如：额头新痘',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<FaceRegion>(
                            initialValue: _selectedRegion,
                            decoration: const InputDecoration(labelText: '区域'),
                            items: FaceRegion.values
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r.label),
                                  ),
                                )
                                .toList(),
                            onChanged: _saving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _selectedRegion = value);
                                    }
                                  },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteController,
                            enabled: !_saving,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: '备注',
                              hintText: '例如：红肿明显',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '药物 / 标签',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TreatmentTagsPanel(onTagSelected: _applyTag),
                          const SizedBox(height: 8),
                          ...List.generate(_treatments.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TreatmentForm(
                                row: _treatments[index],
                                onRemove: _treatments.length > 1
                                    ? () => _removeTreatment(index)
                                    : null,
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: _saving ? null : _addTreatment,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('添加药物 / 标签'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('保存并继续预览'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TreatmentType>(
                  initialValue: widget.row.type,
                  decoration: const InputDecoration(
                    labelText: '类型',
                    isDense: true,
                  ),
                  items: TreatmentType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)),
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
    );
  }
}
