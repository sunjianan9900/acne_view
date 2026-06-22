import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/repositories.dart';
import '../../../core/theme/app_theme.dart';
import 'face_map_painter.dart';

/// 当前痘痘项目独立的面部位置预览，点击打开大图编辑器。
class SpotFaceMapPreview extends ConsumerWidget {
  const SpotFaceMapPreview({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markersAsync = ref.watch(spotFaceMarkersProvider(spotId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '拍照位置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '点击标记',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => showSpotFaceMapEditor(context, ref, spotId: spotId),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.softRose.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.panelBorder),
            ),
            padding: const EdgeInsets.all(10),
            child: markersAsync.when(
              data: (markers) => SpotFaceMapCanvas(
                markers: markers,
                interactive: false,
              ),
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showSpotFaceMapEditor(
  BuildContext context,
  WidgetRef ref, {
  required String spotId,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => SpotFaceMapEditorDialog(spotId: spotId),
  );
}

class SpotFaceMapEditorDialog extends ConsumerStatefulWidget {
  const SpotFaceMapEditorDialog({super.key, required this.spotId});

  final String spotId;

  @override
  ConsumerState<SpotFaceMapEditorDialog> createState() =>
      _SpotFaceMapEditorDialogState();
}

class _SpotFaceMapEditorDialogState
    extends ConsumerState<SpotFaceMapEditorDialog> {
  bool _addMode = false;
  String? _selectedMarkerId;
  String? _draggingMarkerId;

  Future<void> _addMarker(double x, double y) async {
    final id = await ref
        .read(spotRepositoryProvider)
        .addFaceMarker(widget.spotId, x, y);
    if (!mounted) return;
    setState(() {
      _selectedMarkerId = id;
      _addMode = false;
    });
  }

  Future<void> _moveMarker(String markerId, double x, double y) async {
    await ref.read(spotRepositoryProvider).updateFaceMarkerPosition(
      markerId,
      x,
      y,
    );
  }

  Future<void> _removeSelectedMarker() async {
    final id = _selectedMarkerId;
    if (id == null) return;
    await ref.read(spotRepositoryProvider).deleteFaceMarker(id);
    if (!mounted) return;
    setState(() => _selectedMarkerId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已移除标记')),
    );
  }

  SpotFaceMarker? _hitTestMarker(
    List<SpotFaceMarker> markers,
    Offset local,
    Size size,
  ) {
    for (final marker in markers) {
      final position = FaceMapCoordinates.markerRecordPosition(
        marker.mapX,
        marker.mapY,
        size,
      );
      if (position == null) continue;
      if ((position - local).distance <= FaceMapCoordinates.markerHitRadius(size)) {
        return marker;
      }
    }
    return null;
  }

  Future<void> _handleTap(
    List<SpotFaceMarker> markers,
    Offset local,
    Size size,
  ) async {
    final normalized = FaceMapCoordinates.normalizedFromLocal(local, size);
    if (normalized == null) return;

    final hit = _hitTestMarker(markers, local, size);
    if (hit != null) {
      setState(() => _selectedMarkerId = hit.id);
      return;
    }

    if (_addMode) {
      await _addMarker(normalized.dx, normalized.dy);
      return;
    }

    await _addMarker(normalized.dx, normalized.dy);
  }

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(spotFaceMarkersProvider(widget.spotId));

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '标记痘痘位置',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                _addMode
                    ? '点击面部添加标记'
                    : '拖动标记调整位置，点击空白处也可添加',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: markersAsync.when(
                  data: (markers) => SpotFaceMapCanvas(
                    markers: markers,
                    selectedMarkerId: _selectedMarkerId,
                    draggingMarkerId: _draggingMarkerId,
                    interactive: true,
                    onTapAt: (local, size) =>
                        _handleTap(markers, local, size),
                    onMarkerDragStart: (markerId) {
                      setState(() {
                        _draggingMarkerId = markerId;
                        _selectedMarkerId = markerId;
                        _addMode = false;
                      });
                    },
                    onMarkerDragUpdate: (markerId, local, size) {
                      final normalized =
                          FaceMapCoordinates.normalizedFromLocal(local, size);
                      if (normalized == null) return;
                      _moveMarker(markerId, normalized.dx, normalized.dy);
                    },
                    onMarkerDragEnd: (_) {
                      setState(() => _draggingMarkerId = null);
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_selectedMarkerId != null)
                    OutlinedButton.icon(
                      onPressed: _removeSelectedMarker,
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('移除标记'),
                    ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() => _addMode = !_addMode),
                    icon: Icon(_addMode ? Icons.close : Icons.add),
                    label: Text(_addMode ? '取消添加' : '添加标记'),
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

class SpotFaceMapCanvas extends StatefulWidget {
  const SpotFaceMapCanvas({
    super.key,
    required this.markers,
    required this.interactive,
    this.selectedMarkerId,
    this.draggingMarkerId,
    this.onTapAt,
    this.onMarkerDragStart,
    this.onMarkerDragUpdate,
    this.onMarkerDragEnd,
  });

  final List<SpotFaceMarker> markers;
  final bool interactive;
  final String? selectedMarkerId;
  final String? draggingMarkerId;
  final void Function(Offset local, Size size)? onTapAt;
  final void Function(String markerId)? onMarkerDragStart;
  final void Function(String markerId, Offset local, Size size)?
  onMarkerDragUpdate;
  final void Function(String markerId)? onMarkerDragEnd;

  @override
  State<SpotFaceMapCanvas> createState() => _SpotFaceMapCanvasState();
}

class _SpotFaceMapCanvasState extends State<SpotFaceMapCanvas> {
  final _canvasKey = GlobalKey();

  Offset? _globalToLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: _canvasKey,
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                faceOutlineAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            if (widget.interactive)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapUp: (details) =>
                      widget.onTapAt?.call(details.localPosition, size),
                ),
              ),
            for (final marker in widget.markers)
              _FaceMarkerDot(
                radius: FaceMapCoordinates.markerRadius(
                  size,
                  selected: marker.id == widget.selectedMarkerId,
                  dragging: marker.id == widget.draggingMarkerId,
                ),
                hitPadding: FaceMapCoordinates.markerHitRadius(size) -
                    FaceMapCoordinates.markerRadius(size),
                selected: marker.id == widget.selectedMarkerId,
                dragging: marker.id == widget.draggingMarkerId,
                position: FaceMapCoordinates.markerRecordPosition(
                  marker.mapX,
                  marker.mapY,
                  size,
                )!,
                interactive: widget.interactive,
                onDragStart: () =>
                    widget.onMarkerDragStart?.call(marker.id),
                onDragUpdate: (global) {
                  final local = _globalToLocal(global);
                  if (local == null) return;
                  widget.onMarkerDragUpdate?.call(marker.id, local, size);
                },
                onDragEnd: () => widget.onMarkerDragEnd?.call(marker.id),
              ),
          ],
        );
      },
    );
  }
}

class _FaceMarkerDot extends StatelessWidget {
  const _FaceMarkerDot({
    required this.radius,
    required this.hitPadding,
    required this.selected,
    required this.dragging,
    required this.position,
    required this.interactive,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final double radius;
  final double hitPadding;
  final bool selected;
  final bool dragging;
  final Offset position;
  final bool interactive;
  final VoidCallback? onDragStart;
  final void Function(Offset global)? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final borderWidth = (radius * 0.22).clamp(1.0, 2.5);
    final touchRadius = interactive
        ? (radius + hitPadding.clamp(4.0, 14.0))
        : radius;

    final dot = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppTheme.accentCoral,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.white : AppTheme.accentCoral,
          width: borderWidth,
        ),
        boxShadow: [
          if (selected || dragging)
            BoxShadow(
              color: AppTheme.accentCoral.withValues(alpha: 0.4),
              blurRadius: radius * 1.2,
              spreadRadius: radius * 0.08,
            ),
        ],
      ),
    );

    Widget body = SizedBox(
      width: touchRadius * 2,
      height: touchRadius * 2,
      child: Center(child: dot),
    );

    if (interactive) {
      body = GestureDetector(
        onPanStart: (_) => onDragStart?.call(),
        onPanUpdate: (details) => onDragUpdate?.call(details.globalPosition),
        onPanEnd: (_) => onDragEnd?.call(),
        child: body,
      );
    }

    return Positioned(
      left: position.dx - touchRadius,
      top: position.dy - touchRadius,
      child: body,
    );
  }
}
