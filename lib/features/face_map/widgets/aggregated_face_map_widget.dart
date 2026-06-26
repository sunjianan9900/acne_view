import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/repositories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/face_marker_size.dart';
import '../../../shared/models/placed_spot_marker.dart';
import '../../../shared/models/spot_status.dart';
import 'face_map_painter.dart';

/// 汇集各痘痘项目面部标记的总览地图（无分区色块）。
class AggregatedFaceMapWidget extends StatefulWidget {
  const AggregatedFaceMapWidget({
    super.key,
    required this.placedMarkers,
    required this.onMarkerTap,
    this.highlightedSpotId,
  });

  final List<PlacedSpotMarker> placedMarkers;
  final void Function(String spotId) onMarkerTap;
  final String? highlightedSpotId;

  @override
  State<AggregatedFaceMapWidget> createState() =>
      _AggregatedFaceMapWidgetState();
}

class _AggregatedFaceMapWidgetState extends State<AggregatedFaceMapWidget> {
  String? _hoveredSpotId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
            for (final placed in widget.placedMarkers)
              _AggregatedMarkerDot(
                color: _markerColor(placed.spot),
                markerSize: FaceMarkerSize.fromId(placed.marker.size),
                highlighted: placed.spot.id == widget.highlightedSpotId,
                position: FaceMapCoordinates.markerRecordPosition(
                  placed.marker.mapX,
                  placed.marker.mapY,
                  size,
                ),
                onTap: () => widget.onMarkerTap(placed.spot.id),
                onEnter: () => setState(() => _hoveredSpotId = placed.spot.id),
                onExit: () {
                  if (_hoveredSpotId == placed.spot.id) {
                    setState(() => _hoveredSpotId = null);
                  }
                },
                canvasSize: size,
              ),
            if (_hoveredSpotId != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: IgnorePointer(
                  child: _SpotHoverPreview(spotId: _hoveredSpotId!),
                ),
              ),
          ],
        );
      },
    );
  }

  Color _markerColor(AcneSpot spot) {
    return SpotStatus.fromId(spot.status).isActive
        ? AppTheme.accentCoral
        : AppTheme.primaryTeal;
  }
}

class _AggregatedMarkerDot extends StatelessWidget {
  const _AggregatedMarkerDot({
    required this.color,
    required this.markerSize,
    required this.highlighted,
    required this.position,
    required this.onTap,
    required this.onEnter,
    required this.onExit,
    required this.canvasSize,
  });

  final Color color;
  final FaceMarkerSize markerSize;
  final bool highlighted;
  final Offset position;
  final VoidCallback onTap;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final Size canvasSize;

  @override
  Widget build(BuildContext context) {
    final radius = FaceMapCoordinates.markerRadius(
      canvasSize,
      markerSize: markerSize,
      selected: highlighted,
    );
    final hitRadius = FaceMapCoordinates.markerHitRadius(
      canvasSize,
      markerSize: markerSize,
    );
    final borderWidth = (radius * 0.22).clamp(1.0, 2.5);

    return Positioned(
      left: position.dx - hitRadius,
      top: position.dy - hitRadius,
      child: MouseRegion(
        onEnter: (_) => onEnter(),
        onExit: (_) => onExit(),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: hitRadius * 2,
            height: hitRadius * 2,
            child: Center(
              child: Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: highlighted ? Colors.white : color,
                    width: borderWidth,
                  ),
                  boxShadow: [
                    if (highlighted)
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: radius * 1.2,
                        spreadRadius: radius * 0.08,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotHoverPreview extends ConsumerWidget {
  const _SpotHoverPreview({required this.spotId});

  static const _previewSize = 140.0;

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(spotThumbnailProvider(spotId));

    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        key: const Key('spot-hover-preview'),
        width: _previewSize,
        height: _previewSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.panelBorder),
        ),
        child: photoAsync.when(
          data: (photo) => _previewContent(photo?.filePath),
          loading: () => _placeholder(),
          error: (_, _) => _placeholder(),
        ),
      ),
    );
  }

  Widget _previewContent(String? photoPath) {
    if (photoPath != null && File(photoPath).existsSync()) {
      return Image.file(
        File(photoPath),
        width: _previewSize,
        height: _previewSize,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.softRose,
      alignment: Alignment.center,
      child: Icon(
        Icons.face_retouching_natural_rounded,
        color: AppTheme.brandPink.withValues(alpha: 0.74),
        size: 36,
      ),
    );
  }
}
