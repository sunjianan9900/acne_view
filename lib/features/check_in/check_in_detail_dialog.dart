import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/preferences/custom_phases.dart';
import '../../core/preferences/custom_treatment_tags.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/photo/photo_viewer.dart';
import '../../shared/widgets/treatment_tags_panel.dart';

Future<void> showCheckInDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required String checkInId,
  bool initialEditing = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => CheckInDetailDialog(
      checkInId: checkInId,
      initialEditing: initialEditing,
    ),
  );
}

class CheckInDetailDialog extends ConsumerStatefulWidget {
  const CheckInDetailDialog({
    super.key,
    required this.checkInId,
    this.initialEditing = false,
  });

  final String checkInId;
  final bool initialEditing;

  @override
  ConsumerState<CheckInDetailDialog> createState() =>
      _CheckInDetailDialogState();
}

class _CheckInDetailDialogState extends ConsumerState<CheckInDetailDialog> {
  late bool _editing;
  bool _saving = false;
  bool _deleting = false;
  String _selectedPhaseId = AcnePhase.mildComedone.id;
  DateTime _selectedCheckInDate = DateTime.now();
  final _noteController = TextEditingController();
  final List<_TreatmentRow> _treatments = [];
  bool _formReady = false;

  @override
  void initState() {
    super.initState();
    _editing = widget.initialEditing;
  }

  @override
  void didUpdateWidget(covariant CheckInDetailDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checkInId != widget.checkInId) {
      _editing = widget.initialEditing;
      _formReady = false;
    } else if (oldWidget.initialEditing != widget.initialEditing) {
      _editing = widget.initialEditing;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    for (final row in _treatments) {
      row.dispose();
    }
    super.dispose();
  }

  void _ensureFormLoaded(CheckInDetail detail) {
    if (_formReady) return;
    _selectedPhaseId = detail.checkIn.phase.isNotEmpty
        ? detail.checkIn.phase
        : AcnePhase.mildComedone.id;
    _selectedCheckInDate = detail.checkIn.checkInDate;
    _noteController.text = detail.checkIn.note;
    for (final row in _treatments) {
      row.dispose();
    }
    _treatments.clear();
    if (detail.treatments.isEmpty) {
      _treatments.add(_TreatmentRow());
    } else {
      for (final item in detail.treatments) {
        final row = _TreatmentRow();
        row.type = TreatmentType.fromId(item.type);
        row.nameController.text = item.name;
        row.dosageController.text = item.dosage;
        _treatments.add(row);
      }
    }
    _formReady = true;
  }

  void _addTreatment() => setState(() => _treatments.add(_TreatmentRow()));

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

  Future<void> _save(CheckInDetail detail) async {
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

      await ref
          .read(checkInRepositoryProvider)
          .updateCheckIn(
            checkInId: detail.checkIn.id,
            phaseId: _selectedPhaseId,
            note: _noteController.text,
            checkInDate: _selectedCheckInDate,
            treatments: entries,
          );

      ref.invalidate(checkInDetailProvider(widget.checkInId));
      ref.invalidate(spotTimelineProvider(detail.checkIn.spotId));
      if (mounted) {
        setState(() {
          _editing = false;
          _formReady = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('记录已更新')));
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

  Future<void> _confirmDelete(CheckInDetail detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除打卡记录'),
        content: const Text('将删除该条打卡的照片、用药和备注信息，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _delete(detail);
  }

  Future<void> _delete(CheckInDetail detail) async {
    setState(() => _deleting = true);
    try {
      final spotId = detail.checkIn.spotId;
      await ref
          .read(checkInRepositoryProvider)
          .deleteCheckIn(detail.checkIn.id);
      ref.invalidate(spotTimelineProvider(spotId));
      ref.invalidate(spotThumbnailProvider(spotId));
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('记录已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(checkInDetailProvider(widget.checkInId));

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 640),
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Text('记录不存在'),
              );
            }
            _ensureFormLoaded(detail);
            return _buildContent(context, detail);
          },
          loading: () => const SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(32),
            child: Text('加载失败: $e'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CheckInDetail detail) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isWide = MediaQuery.of(context).size.width >= 720;

    final photoPanel = _PhotoPanel(photoPath: detail.photo?.filePath);
    final infoPanel = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: _editing
          ? _buildEditForm(detail)
          : _buildViewInfo(context, detail, dateFormat, detail.checkIn.phase),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _editing ? '编辑打卡记录' : '打卡详情',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (!_editing)
                TextButton.icon(
                  onPressed: _deleting ? null : () => _confirmDelete(detail),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              if (!_editing)
                TextButton.icon(
                  onPressed: _deleting ? null : () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('编辑'),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Flexible(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: photoPanel),
                    const VerticalDivider(
                      width: 1,
                      color: AppTheme.panelBorder,
                    ),
                    Expanded(flex: 4, child: infoPanel),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(height: 240, child: photoPanel),
                    Expanded(child: infoPanel),
                  ],
                ),
        ),
        if (_editing)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                            _editing = false;
                            _formReady = false;
                          }),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : () => _save(detail),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('保存修改'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildViewInfo(
    BuildContext context,
    CheckInDetail detail,
    DateFormat dateFormat,
    String phaseId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormat.format(detail.checkIn.checkInDate),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Text(
          '痘痘阶段',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (phaseId.isNotEmpty)
          _PhaseTag(phaseId: phaseId)
        else
          Text(
            '未标记',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        const SizedBox(height: 18),
        Text(
          '备注',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          detail.checkIn.note.isEmpty ? '无' : detail.checkIn.note,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        Text(
          '用药记录',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (detail.treatments.isEmpty)
          Text(
            '无',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          )
        else
          ...detail.treatments.map((item) => _TreatmentViewTile(item: item)),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedCheckInDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _selectedCheckInDate = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedCheckInDate.hour,
        _selectedCheckInDate.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedCheckInDate),
    );
    if (time == null || !mounted) return;
    setState(() {
      _selectedCheckInDate = DateTime(
        _selectedCheckInDate.year,
        _selectedCheckInDate.month,
        _selectedCheckInDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _buildEditForm(CheckInDetail detail) {
    final allPhases = ref.watch(allPhasesProvider);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '打卡时间',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(dateFormat.format(_selectedCheckInDate)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(timeFormat.format(_selectedCheckInDate)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '痘痘阶段',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allPhases.map((phase) {
            final selected = _selectedPhaseId == phase.id;
            final color = phase.color;
            return ChoiceChip(
              label: Text(phase.label),
              selected: selected,
              onSelected: (_) => setState(() => _selectedPhaseId = phase.id),
              selectedColor: color.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: selected ? color : AppTheme.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(color: selected ? color : AppTheme.panelBorder),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: '备注',
            hintText: '描述痘痘状态变化...',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '护理项目',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _addTreatment,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加明细'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TreatmentTagsPanel(onTagSelected: _applyTag),
        const SizedBox(height: 12),
        ...List.generate(_treatments.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TreatmentEditCard(
              row: _treatments[index],
              onRemove: _treatments.length > 1
                  ? () => _removeTreatment(index)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _PhotoPanel extends StatelessWidget {
  const _PhotoPanel({this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    if (photoPath == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.image_not_supported, color: Colors.white54),
        ),
      );
    }

    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () => showPhotoViewer(context, photoPath!),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Image.file(
                File(photoPath!),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '点击放大',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseTag extends ConsumerWidget {
  const _PhaseTag({required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPhases = ref.watch(allPhasesProvider);
    final phase = findPhaseInfo(phaseId, allPhases);
    if (phase == null) {
      return Text(
        phaseId,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
      );
    }
    final color = phase.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        phase.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TreatmentViewTile extends StatelessWidget {
  const _TreatmentViewTile({required this.item});

  final TreatmentItem item;

  @override
  Widget build(BuildContext context) {
    final type = TreatmentType.fromId(item.type);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${type.label} · ${item.name}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (item.dosage.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.dosage,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ],
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

class _TreatmentEditCard extends StatefulWidget {
  const _TreatmentEditCard({required this.row, this.onRemove});

  final _TreatmentRow row;
  final VoidCallback? onRemove;

  @override
  State<_TreatmentEditCard> createState() => _TreatmentEditCardState();
}

class _TreatmentEditCardState extends State<_TreatmentEditCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
