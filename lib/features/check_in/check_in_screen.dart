import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/custom_phase_labels.dart';
import '../../core/preferences/custom_treatment_tags.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/photo_source.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/widgets/douji_shell.dart';
import '../../shared/widgets/treatment_tags_panel.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({
    super.key,
    required this.spotId,
    required this.photoPath,
    this.photoSource,
    this.isExternalCamera = false,
  });

  final String spotId;
  final String photoPath;
  final PhotoSource? photoSource;
  final bool isExternalCamera;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _noteController = TextEditingController();
  final List<_TreatmentRow> _treatments = [_TreatmentRow()];
  AcnePhase _selectedPhase = AcnePhase.swollen;
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

  Future<void> _persistCustomTags(Iterable<String> names) async {
    final notifier = ref.read(customTreatmentTagsProvider.notifier);
    final existing = ref.read(allTreatmentTagsProvider);
    for (final name in names) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty && !existing.contains(trimmed)) {
        await notifier.addTag(trimmed);
      }
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

      await _persistCustomTags(entries.map((e) => e.name));

      final source =
          widget.photoSource ??
          (widget.isExternalCamera
              ? PhotoSource.external
              : PhotoSource.builtin);

      await ref
          .read(checkInRepositoryProvider)
          .createCheckIn(
            spotId: widget.spotId,
            photoSourcePath: widget.photoPath,
            source: source,
            treatments: entries,
            phase: _selectedPhase,
            note: _noteController.text,
          );

      if (mounted) {
        ref.read(selectedHomeSpotIdProvider.notifier).state = widget.spotId;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('打卡成功')));
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotAsync = ref.watch(spotProvider(widget.spotId));
    final isDesktop = MediaQuery.of(context).size.width >= 1080;
    final regionLabel = spotAsync.maybeWhen(
      data: (spot) {
        final region = spot != null ? FaceRegion.fromId(spot.faceRegion) : null;
        return region?.label ?? '痘痘';
      },
      orElse: () => '痘痘',
    );

    return DoujiShell(
      title: '护理记录',
      subtitle: '$regionLabel · 记录本次护理与变化',
      showHeader: true,
      actions: [
        OutlinedButton.icon(
          onPressed: _saving ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('返回'),
        ),
      ],
      rightPanel: isDesktop ? const _CheckInTipsPanel() : null,
      child: isDesktop
          ? _DesktopCheckInBody(
              photoPath: widget.photoPath,
              noteController: _noteController,
              selectedPhase: _selectedPhase,
              treatments: _treatments,
              saving: _saving,
              onPhaseChanged: (phase) =>
                  setState(() => _selectedPhase = phase),
              onApplyTag: _applyTag,
              onAddTreatment: _addTreatment,
              onRemoveTreatment: _removeTreatment,
              onSave: _save,
            )
          : _MobileCheckInBody(
              photoPath: widget.photoPath,
              noteController: _noteController,
              selectedPhase: _selectedPhase,
              treatments: _treatments,
              saving: _saving,
              onPhaseChanged: (phase) =>
                  setState(() => _selectedPhase = phase),
              onApplyTag: _applyTag,
              onAddTreatment: _addTreatment,
              onRemoveTreatment: _removeTreatment,
              onSave: _save,
            ),
    );
  }
}

class _DesktopCheckInBody extends StatelessWidget {
  const _DesktopCheckInBody({
    required this.photoPath,
    required this.noteController,
    required this.selectedPhase,
    required this.treatments,
    required this.saving,
    required this.onPhaseChanged,
    required this.onApplyTag,
    required this.onAddTreatment,
    required this.onRemoveTreatment,
    required this.onSave,
  });

  final String photoPath;
  final TextEditingController noteController;
  final AcnePhase selectedPhase;
  final List<_TreatmentRow> treatments;
  final bool saving;
  final ValueChanged<AcnePhase> onPhaseChanged;
  final ValueChanged<String> onApplyTag;
  final VoidCallback onAddTreatment;
  final ValueChanged<int> onRemoveTreatment;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _PhotoPreview(photoPath: photoPath),
        ),
        const VerticalDivider(width: 1, color: AppTheme.panelBorder),
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: _CheckInForm(
            noteController: noteController,
            selectedPhase: selectedPhase,
            treatments: treatments,
            saving: saving,
            onPhaseChanged: onPhaseChanged,
            onApplyTag: onApplyTag,
            onAddTreatment: onAddTreatment,
            onRemoveTreatment: onRemoveTreatment,
            onSave: onSave,
          ),
        ),
      ],
    );
  }
}

class _MobileCheckInBody extends StatelessWidget {
  const _MobileCheckInBody({
    required this.photoPath,
    required this.noteController,
    required this.selectedPhase,
    required this.treatments,
    required this.saving,
    required this.onPhaseChanged,
    required this.onApplyTag,
    required this.onAddTreatment,
    required this.onRemoveTreatment,
    required this.onSave,
  });

  final String photoPath;
  final TextEditingController noteController;
  final AcnePhase selectedPhase;
  final List<_TreatmentRow> treatments;
  final bool saving;
  final ValueChanged<AcnePhase> onPhaseChanged;
  final ValueChanged<String> onApplyTag;
  final VoidCallback onAddTreatment;
  final ValueChanged<int> onRemoveTreatment;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 220, child: _PhotoPreview(photoPath: photoPath)),
          const SizedBox(height: 20),
          _CheckInForm(
            noteController: noteController,
            selectedPhase: selectedPhase,
            treatments: treatments,
            saving: saving,
            onPhaseChanged: onPhaseChanged,
            onApplyTag: onApplyTag,
            onAddTreatment: onAddTreatment,
            onRemoveTreatment: onRemoveTreatment,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photoPath});

  final String photoPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black,
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Center(
            child: Image.file(
              File(photoPath),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInForm extends ConsumerWidget {
  const _CheckInForm({
    required this.noteController,
    required this.selectedPhase,
    required this.treatments,
    required this.saving,
    required this.onPhaseChanged,
    required this.onApplyTag,
    required this.onAddTreatment,
    required this.onRemoveTreatment,
    required this.onSave,
  });

  final TextEditingController noteController;
  final AcnePhase selectedPhase;
  final List<_TreatmentRow> treatments;
  final bool saving;
  final ValueChanged<AcnePhase> onPhaseChanged;
  final ValueChanged<String> onApplyTag;
  final VoidCallback onAddTreatment;
  final ValueChanged<int> onRemoveTreatment;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phaseLabels = ref.watch(phaseLabelsProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '痘痘阶段',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AcnePhase.values.map((phase) {
              final selected = selectedPhase == phase;
              final color = acnePhaseColor(phase);
              return ChoiceChip(
                label: Text(phaseDisplayLabel(phase, phaseLabels)),
                selected: selected,
                onSelected: (_) => onPhaseChanged(phase),
                selectedColor: color.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected ? color : AppTheme.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: selected ? color : AppTheme.panelBorder,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: '今日备注',
              hintText: '描述痘痘状态变化...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '护理项目',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: onAddTreatment,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加明细'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TreatmentTagsPanel(onTagSelected: onApplyTag),
          const SizedBox(height: 14),
          ...List.generate(treatments.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TreatmentForm(
                row: treatments[index],
                onRemove: treatments.length > 1
                    ? () => onRemoveTreatment(index)
                    : null,
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: saving ? null : onSave,
            child: saving
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
    );
  }
}

class _CheckInTipsPanel extends StatelessWidget {
  const _CheckInTipsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.panelBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '记录提示',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _TipRow(
                icon: Icons.touch_app_outlined,
                text: '点击快捷标签可快速填入护理项目',
              ),
              const SizedBox(height: 10),
              _TipRow(
                icon: Icons.add_circle_outline,
                text: '「自定义」添加的项目对所有痘痘记录通用',
              ),
              const SizedBox(height: 10),
              _TipRow(
                icon: Icons.home_outlined,
                text: '保存后将返回主页查看变化时间线',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.brandPink),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
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
                  value: widget.row.type,
                  decoration: const InputDecoration(
                    labelText: '类型',
                    isDense: true,
                  ),
                  items: TreatmentType.values
                      .map(
                        (t) =>
                            DropdownMenuItem(value: t, child: Text(t.label)),
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
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.textSecondary,
                  ),
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
