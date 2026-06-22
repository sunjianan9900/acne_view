import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/repositories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/face_region.dart';
import '../../../shared/models/spot_display.dart';
import '../../../shared/models/spot_status.dart';
import 'face_map_painter.dart';

/// 概览页右侧面板中的面部位置预览，点击打开大图编辑器。
class SpotFaceMapPreview extends ConsumerWidget {
  const SpotFaceMapPreview({
    super.key,
    required this.spots,
    required this.selectedSpotId,
  });

  final List<AcneSpot> spots;
  final String selectedSpotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () => showSpotFaceMapEditor(
            context,
            ref,
            spots: spots,
            selectedSpotId: selectedSpotId,
          ),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.softRose.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.panelBorder),
            ),
            padding: const EdgeInsets.all(10),
            child: SpotFaceMapCanvas(
              spots: spots,
              selectedSpotId: selectedSpotId,
              interactive: false,
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
  required List<AcneSpot> spots,
  required String selectedSpotId,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => SpotFaceMapEditorDialog(
      spots: spots,
      initialSelectedSpotId: selectedSpotId,
    ),
  );
}

class SpotFaceMapEditorDialog extends ConsumerStatefulWidget {
  const SpotFaceMapEditorDialog({
    super.key,
    required this.spots,
    required this.initialSelectedSpotId,
  });

  final List<AcneSpot> spots;
  final String initialSelectedSpotId;

  @override
  ConsumerState<SpotFaceMapEditorDialog> createState() =>
      _SpotFaceMapEditorDialogState();
}

class _SpotFaceMapEditorDialogState
    extends ConsumerState<SpotFaceMapEditorDialog> {
  late String _selectedSpotId;
  bool _addMode = false;
  String? _draggingSpotId;

  @override
  void initState() {
    super.initState();
    _selectedSpotId = widget.initialSelectedSpotId;
  }

  List<AcneSpot> get _spots =>
      ref.watch(allSpotsProvider).maybeWhen(
        data: (spots) => spots,
        orElse: () => widget.spots,
      );

  AcneSpot? _spotById(String id) {
    for (final spot in _spots) {
      if (spot.id == id) return spot;
    }
    return null;
  }

  Future<void> _persistPosition(String spotId, double x, double y) async {
    await ref.read(spotRepositoryProvider).updateSpotMapPosition(spotId, x, y);
  }

  Future<void> _clearPosition(String spotId) async {
    await ref.read(spotRepositoryProvider).updateSpotMapPosition(spotId, null, null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已移除面部标记')),
    );
  }

  Future<void> _createSpotAt(Offset local, Size size) async {
    final normalized = FaceMapCoordinates.normalizedFromLocal(local, size);
    if (normalized == null) return;

    final region =
        FaceMapPainter.hitTestRegion(local, size) ?? FaceRegion.forehead;
    final spotId = await ref.read(spotRepositoryProvider).createSpot(
      region: region,
      faceMapX: normalized.dx,
      faceMapY: normalized.dy,
    );
    if (!mounted) return;
    setState(() {
      _selectedSpotId = spotId;
      _addMode = false;
    });
    ref.read(selectedHomeSpotIdProvider.notifier).state = spotId;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加痘痘标记')),
    );
  }

  Future<void> _handleTap(Offset local, Size size) async {
    final normalized = FaceMapCoordinates.normalizedFromLocal(local, size);
    if (normalized == null) return;

    if (_addMode) {
      await _createSpotAt(local, size);
      return;
    }

    final hitSpot = _hitTestMarker(local, size);
    if (hitSpot != null) {
      setState(() => _selectedSpotId = hitSpot.id);
      return;
    }

    await _persistPosition(_selectedSpotId, normalized.dx, normalized.dy);
  }

  AcneSpot? _hitTestMarker(Offset local, Size size) {
    for (final spot in _spots) {
      final position = FaceMapCoordinates.markerPosition(spot, size);
      if (position == null) continue;
      if ((position - local).distance <= 16) return spot;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _spotById(_selectedSpotId);

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
                    ? '点击面部任意位置添加新痘痘'
                    : '拖动标记调整位置，点击空白处放置当前痘痘',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SpotFaceMapCanvas(
                      spots: _spots,
                      selectedSpotId: _selectedSpotId,
                      interactive: true,
                      draggingSpotId: _draggingSpotId,
                      onTapAt: (local, size) => _handleTap(local, size),
                      onMarkerDragStart: (spotId) {
                        setState(() {
                          _draggingSpotId = spotId;
                          _selectedSpotId = spotId;
                          _addMode = false;
                        });
                      },
                      onMarkerDragUpdate: (spotId, local, size) {
                        final normalized =
                            FaceMapCoordinates.normalizedFromLocal(local, size);
                        if (normalized == null) return;
                        _persistPosition(
                          spotId,
                          normalized.dx,
                          normalized.dy,
                        );
                      },
                      onMarkerDragEnd: (_) {
                        setState(() => _draggingSpotId = null);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (selected != null &&
                      FaceMapCoordinates.hasMapPosition(selected))
                    OutlinedButton.icon(
                      onPressed: () => _clearPosition(selected.id),
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('移除标记'),
                    ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() => _addMode = !_addMode),
                    icon: Icon(_addMode ? Icons.close : Icons.add),
                    label: Text(_addMode ? '取消添加' : '添加痘痘'),
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
    required this.spots,
    required this.selectedSpotId,
    required this.interactive,
    this.draggingSpotId,
    this.onTapAt,
    this.onMarkerDragStart,
    this.onMarkerDragUpdate,
    this.onMarkerDragEnd,
  });

  final List<AcneSpot> spots;
  final String selectedSpotId;
  final bool interactive;
  final String? draggingSpotId;
  final void Function(Offset local, Size size)? onTapAt;
  final void Function(String spotId)? onMarkerDragStart;
  final void Function(String spotId, Offset local, Size size)?
  onMarkerDragUpdate;
  final void Function(String spotId)? onMarkerDragEnd;

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
            for (final spot in widget.spots)
              if (FaceMapCoordinates.hasMapPosition(spot))
                _SpotMarker(
                  spot: spot,
                  selected: spot.id == widget.selectedSpotId,
                  position: FaceMapCoordinates.markerPosition(spot, size)!,
                  interactive: widget.interactive,
                  dragging: spot.id == widget.draggingSpotId,
                  onDragStart: () => widget.onMarkerDragStart?.call(spot.id),
                  onDragUpdate: (global) {
                    final local = _globalToLocal(global);
                    if (local == null) return;
                    widget.onMarkerDragUpdate?.call(spot.id, local, size);
                  },
                  onDragEnd: () => widget.onMarkerDragEnd?.call(spot.id),
                ),
          ],
        );
      },
    );
  }
}

class _SpotMarker extends StatelessWidget {
  const _SpotMarker({
    required this.spot,
    required this.selected,
    required this.position,
    required this.interactive,
    required this.dragging,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final AcneSpot spot;
  final bool selected;
  final Offset position;
  final bool interactive;
  final bool dragging;
  final VoidCallback? onDragStart;
  final void Function(Offset global)? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final status = SpotStatus.fromId(spot.status);
    final color = status == SpotStatus.active
        ? AppTheme.accentCoral
        : AppTheme.primaryTeal;
    final radius = selected ? 11.0 : 8.0;

    Widget marker = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.white : color.withValues(alpha: 0.4),
          width: selected ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (selected || dragging)
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: selected
          ? Text(
              _markerLabel(spot),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    if (interactive) {
      marker = GestureDetector(
        onPanStart: (_) => onDragStart?.call(),
        onPanUpdate: (details) => onDragUpdate?.call(details.globalPosition),
        onPanEnd: (_) => onDragEnd?.call(),
        child: marker,
      );
    }

    return Positioned(
      left: position.dx - radius,
      top: position.dy - radius,
      child: marker,
    );
  }
}

String _markerLabel(AcneSpot spot) {
  final title = spotDisplayTitle(spot).trim();
  if (title.isEmpty) return '痘';
  return title.characters.first;
}
