import 'package:flutter/material.dart';

import '../../../core/database/database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/placed_spot_marker.dart';
import '../../../shared/models/spot_status.dart';
import 'face_map_painter.dart';

/// 汇集各痘痘项目面部标记的总览地图（无分区色块）。
class AggregatedFaceMapWidget extends StatelessWidget {
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
            for (final placed in placedMarkers)
              _AggregatedMarkerDot(
                color: _markerColor(placed.spot),
                highlighted: placed.spot.id == highlightedSpotId,
                position: FaceMapCoordinates.markerRecordPosition(
                  placed.marker,
                  size,
                )!,
                onTap: () => onMarkerTap(placed.spot.id),
                canvasSize: size,
              ),
          ],
        );
      },
    );
  }

  Color _markerColor(AcneSpot spot) {
    return SpotStatus.fromId(spot.status) == SpotStatus.active
        ? AppTheme.accentCoral
        : AppTheme.primaryTeal;
  }
}

class _AggregatedMarkerDot extends StatelessWidget {
  const _AggregatedMarkerDot({
    required this.color,
    required this.highlighted,
    required this.position,
    required this.onTap,
    required this.canvasSize,
  });

  final Color color;
  final bool highlighted;
  final Offset position;
  final VoidCallback onTap;
  final Size canvasSize;

  @override
  Widget build(BuildContext context) {
    final radius = FaceMapCoordinates.markerRadius(
      canvasSize,
      selected: highlighted,
    );
    final hitRadius = FaceMapCoordinates.markerHitRadius(canvasSize);
    final borderWidth = (radius * 0.22).clamp(1.0, 2.5);

    return Positioned(
      left: position.dx - hitRadius,
      top: position.dy - hitRadius,
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
    );
  }
}
