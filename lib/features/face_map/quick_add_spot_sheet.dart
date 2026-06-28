import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/face_map_marker_data.dart';
import '../../shared/models/face_marker_size.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/photo_source.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/photo/photo_viewer.dart';
import '../../shared/widgets/treatment_tags_panel.dart';
import 'widgets/face_map_painter.dart';
import 'widgets/spot_face_map_widget.dart';

const _uuid = Uuid();

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
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _draftMarkers = <FaceMapMarkerData>[];
  final List<_TreatmentRow> _treatments = [_TreatmentRow()];

  FaceMarkerSize _pendingAddSize = FaceMarkerSize.small;
  String? _selectedMarkerId;
  String? _draggingMarkerId;
  Size _canvasSize = const Size(520, 360);
  late FaceRegion _selectedRegion;
  bool _regionManuallySet = false;
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

  void _selectAddSize(FaceMarkerSize size) {
    setState(() => _pendingAddSize = size);
  }

  void _addDraftMarker(double x, double y, FaceMarkerSize size) {
    final id = _uuid.v4();
    setState(() {
      _draftMarkers.add(
        FaceMapMarkerData(id: id, mapX: x, mapY: y, size: size),
      );
      _selectedMarkerId = id;
      _syncRegionFromMarkers();
    });
  }

  void _moveDraftMarker(String markerId, double x, double y) {
    final index = _draftMarkers.indexWhere((m) => m.id == markerId);
    if (index < 0) return;
    setState(() {
      _draftMarkers[index] = _draftMarkers[index].copyWith(mapX: x, mapY: y);
      _syncRegionFromMarkers();
    });
  }

  void _removeSelectedMarker() {
    final id = _selectedMarkerId;
    if (id == null) return;
    setState(() {
      _draftMarkers.removeWhere((m) => m.id == id);
      _selectedMarkerId = null;
      if (_draftMarkers.isEmpty) {
        _regionManuallySet = false;
        _selectedRegion = widget.initialRegion ?? FaceRegion.forehead;
      } else {
        _syncRegionFromMarkers();
      }
    });
  }

  FaceMapMarkerData? _hitTestMarker(Offset local, Size size) {
    for (final marker in _draftMarkers) {
      final position = FaceMapCoordinates.markerRecordPosition(
        marker.mapX,
        marker.mapY,
        size,
      );
      final hitRadius = FaceMapCoordinates.markerHitRadius(
        size,
        markerSize: marker.size,
      );
      if ((position - local).distance <= hitRadius) return marker;
    }
    return null;
  }

  void _handleTap(Offset local, Size size) {
    _canvasSize = size;
    final normalized = FaceMapCoordinates.normalizedFromLocal(local, size);
    if (normalized == null) return;

    final hit = _hitTestMarker(local, size);
    if (hit != null) {
      setState(() => _selectedMarkerId = hit.id);
      return;
    }

    _addDraftMarker(normalized.dx, normalized.dy, _pendingAddSize);
  }

  FaceRegion _regionFromMarkers() {
    if (_draftMarkers.isEmpty) {
      return widget.initialRegion ?? FaceRegion.forehead;
    }
    final first = _draftMarkers.first;
    final local = FaceMapCoordinates.localFromNormalized(
      first.mapX,
      first.mapY,
      _canvasSize,
    );
    return FaceMapPainter.hitTestRegion(local, _canvasSize) ??
        widget.initialRegion ??
        FaceRegion.forehead;
  }

  void _syncRegionFromMarkers() {
    if (_regionManuallySet || _draftMarkers.isEmpty) return;
    _selectedRegion = _regionFromMarkers();
  }

  String _hintText() {
    return '点击面部添加${_pendingAddSize.label}，可切换大小或拖动调整';
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
    if (_draftMarkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在面部标记至少一个痘痘位置')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(spotRepositoryProvider);
      final spotId = await repo.createSpot(
        region: _selectedRegion,
        title: _titleController.text,
        note: _noteController.text,
      );

      for (final marker in _draftMarkers) {
        await repo.addFaceMarker(
          spotId,
          marker.mapX,
          marker.mapY,
          size: marker.size,
        );
      }

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

      await ref.read(checkInRepositoryProvider).createCheckIn(
            spotId: spotId,
            photoSourcePath: widget.photoPath,
            source: widget.photoSource,
            treatments: entries,
            phaseId: AcnePhase.mildComedone.id,
          );

      ref.invalidate(spotTimelineProvider(spotId));
      ref.invalidate(spotThumbnailProvider(spotId));

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
          final width = math.min(860.0, constraints.maxWidth);
          final height = math.min(720.0, constraints.maxHeight);

          return SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '标记并添加痘痘',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '在面部图上标记位置，并填写本次拍照记录',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
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
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _hintText(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.softRose.withValues(
                                      alpha: 0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.panelBorder,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: SpotFaceMapCanvas(
                                    markers: List<FaceMapMarkerData>.from(
                                      _draftMarkers,
                                    ),
                                    selectedMarkerId: _selectedMarkerId,
                                    draggingMarkerId: _draggingMarkerId,
                                    interactive: !_saving,
                                    onTapAt: _handleTap,
                                    onMarkerDragStart: (markerId) {
                                      setState(() {
                                        _draggingMarkerId = markerId;
                                        _selectedMarkerId = markerId;
                                      });
                                    },
                                    onMarkerDragUpdate: (markerId, local, size) {
                                      _canvasSize = size;
                                      final normalized =
                                          FaceMapCoordinates.normalizedFromLocal(
                                            local,
                                            size,
                                          );
                                      if (normalized == null) return;
                                      _moveDraftMarker(
                                        markerId,
                                        normalized.dx,
                                        normalized.dy,
                                      );
                                    },
                                    onMarkerDragEnd: (_) {
                                      setState(() => _draggingMarkerId = null);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (_selectedMarkerId != null)
                                    OutlinedButton.icon(
                                      onPressed: _saving
                                          ? null
                                          : _removeSelectedMarker,
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 18,
                                      ),
                                      label: const Text('移除标记'),
                                    ),
                                  for (final size in FaceMarkerSize.values)
                                    FilledButton.tonal(
                                      onPressed: _saving
                                          ? null
                                          : () => _selectAddSize(size),
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            _pendingAddSize == size
                                            ? AppTheme.softRose
                                            : null,
                                        foregroundColor:
                                            _pendingAddSize == size
                                            ? AppTheme.brandPink
                                            : null,
                                      ),
                                      child: Text('添加${size.label}'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InkWell(
                                onTap: _saving
                                    ? null
                                    : () => showPhotoViewer(
                                          context,
                                          widget.photoPath,
                                        ),
                                borderRadius: BorderRadius.circular(14),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
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
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '本次拍照',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller: _titleController,
                                        enabled: !_saving,
                                        decoration: const InputDecoration(
                                          labelText: '标题（可选）',
                                          hintText: '例如：额头新痘',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      DropdownButtonFormField<FaceRegion>(
                                        key: ValueKey(_selectedRegion),
                                        initialValue: _selectedRegion,
                                        decoration: InputDecoration(
                                          labelText: '区域',
                                          helperText: _regionManuallySet
                                              ? null
                                              : '根据面部标记自动识别，可手动调整',
                                          helperMaxLines: 2,
                                        ),
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
                                                if (value == null) return;
                                                setState(() {
                                                  _selectedRegion = value;
                                                  _regionManuallySet = true;
                                                });
                                              },
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _noteController,
                                        enabled: !_saving,
                                        maxLines: 2,
                                        decoration: const InputDecoration(
                                          labelText: '备注（可选）',
                                          hintText: '例如：红肿明显',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '药物 / 标签',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TreatmentTagsPanel(onTagSelected: _applyTag),
                                      const SizedBox(height: 8),
                                      ...List.generate(_treatments.length, (
                                        index,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
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
                            ],
                          ),
                        ),
                      ],
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
