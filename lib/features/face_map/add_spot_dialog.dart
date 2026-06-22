import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/face_map_marker_data.dart';
import '../../shared/models/face_marker_size.dart';
import '../../shared/models/face_region.dart';
import 'widgets/face_map_painter.dart';
import 'widgets/spot_face_map_widget.dart';

const _uuid = Uuid();

/// 标记痘痘并创建记录，返回新建 ID；取消时返回 null。
Future<String?> showAddSpotDialog(
  BuildContext context,
  WidgetRef ref, {
  FaceRegion? initialRegion,
}) {
  return showDialog<String?>(
    context: context,
    builder: (ctx) => AddSpotDialog(initialRegion: initialRegion),
  );
}

class AddSpotDialog extends ConsumerStatefulWidget {
  const AddSpotDialog({super.key, this.initialRegion});

  final FaceRegion? initialRegion;

  @override
  ConsumerState<AddSpotDialog> createState() => _AddSpotDialogState();
}

class _AddSpotDialogState extends ConsumerState<AddSpotDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _draftMarkers = <FaceMapMarkerData>[];

  FaceMarkerSize _pendingAddSize = FaceMarkerSize.small;
  String? _selectedMarkerId;
  String? _draggingMarkerId;
  Size _canvasSize = const Size(520, 360);
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectAddSize(FaceMarkerSize size) {
    setState(() => _pendingAddSize = size);
  }

  void _addDraftMarker(double x, double y, FaceMarkerSize size) {
    final id = _uuid.v4();
    setState(() {
      _draftMarkers.add(FaceMapMarkerData(id: id, mapX: x, mapY: y, size: size));
      _selectedMarkerId = id;
    });
  }

  void _moveDraftMarker(String markerId, double x, double y) {
    final index = _draftMarkers.indexWhere((m) => m.id == markerId);
    if (index < 0) return;
    setState(() {
      _draftMarkers[index] = _draftMarkers[index].copyWith(mapX: x, mapY: y);
    });
  }

  void _removeSelectedMarker() {
    final id = _selectedMarkerId;
    if (id == null) return;
    setState(() {
      _draftMarkers.removeWhere((m) => m.id == id);
      _selectedMarkerId = null;
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

  FaceRegion _resolveRegion() {
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

  Future<void> _create() async {
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
        region: _resolveRegion(),
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
      if (mounted) Navigator.of(context).pop(spotId);
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

  String _hintText() {
    return '点击面部添加${_pendingAddSize.label}，可切换大小或拖动调整';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
        child: SizedBox(
          height: 720,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '标记痘痘',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  _hintText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.softRose.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.panelBorder),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: SpotFaceMapCanvas(
                      markers: List<FaceMapMarkerData>.from(_draftMarkers),
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
                            FaceMapCoordinates.normalizedFromLocal(local, size);
                        if (normalized == null) return;
                        _moveDraftMarker(markerId, normalized.dx, normalized.dy);
                      },
                      onMarkerDragEnd: (_) {
                        setState(() => _draggingMarkerId = null);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: '标题（可选）',
                    hintText: '例如：鼻子左侧',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  enabled: !_saving,
                  minLines: 1,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '备注（可选）',
                    hintText: '例如：红肿型',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_selectedMarkerId != null)
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _removeSelectedMarker,
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        label: const Text('移除标记'),
                      ),
                    for (final size in FaceMarkerSize.values)
                      FilledButton.tonal(
                        onPressed: _saving ? null : () => _selectAddSize(size),
                        style: FilledButton.styleFrom(
                          backgroundColor: _pendingAddSize == size
                              ? AppTheme.softRose
                              : null,
                          foregroundColor: _pendingAddSize == size
                              ? AppTheme.brandPink
                              : null,
                        ),
                        child: Text('添加${size.label}'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saving ? null : _create,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('创建'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
