import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/face_region.dart';

final Map<FaceRegion, Color> faceRegionColors = {
  FaceRegion.forehead: const Color(0xFF90E0EF),
  FaceRegion.leftCheek: const Color(0xFFA8DADC),
  FaceRegion.rightCheek: const Color(0xFFB8E0D2),
  FaceRegion.nose: const Color(0xFFE9C46A),
  FaceRegion.chin: const Color(0xFFF4A261),
  FaceRegion.jawline: const Color(0xFFE76F51),
};

class FaceMapWidget extends StatelessWidget {
  const FaceMapWidget({
    super.key,
    required this.regionCounts,
    required this.onRegionTap,
  });

  final Map<String, int> regionCounts;
  final void Function(FaceRegion region) onRegionTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: FaceMapPainter(
            regionCounts: regionCounts,
            onRegionTap: onRegionTap,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) {
              final region = FaceMapPainter.hitTestRegion(
                details.localPosition,
                Size(constraints.maxWidth, constraints.maxHeight),
              );
              if (region != null) onRegionTap(region);
            },
          ),
        );
      },
    );
  }
}

class FaceMapPainter extends CustomPainter {
  FaceMapPainter({
    required this.regionCounts,
    required this.onRegionTap,
  });

  final Map<String, int> regionCounts;
  final void Function(FaceRegion region) onRegionTap;

  static final Map<FaceRegion, Path Function(Size)> _regionPaths = {
    FaceRegion.forehead: (s) {
      final path = Path();
      path.moveTo(s.width * 0.25, s.height * 0.12);
      path.quadraticBezierTo(
        s.width * 0.5, s.height * 0.02,
        s.width * 0.75, s.height * 0.12,
      );
      path.lineTo(s.width * 0.68, s.height * 0.28);
      path.lineTo(s.width * 0.32, s.height * 0.28);
      path.close();
      return path;
    },
    FaceRegion.leftCheek: (s) {
      final path = Path();
      path.moveTo(s.width * 0.18, s.height * 0.32);
      path.lineTo(s.width * 0.38, s.height * 0.35);
      path.lineTo(s.width * 0.35, s.height * 0.58);
      path.lineTo(s.width * 0.15, s.height * 0.52);
      path.close();
      return path;
    },
    FaceRegion.rightCheek: (s) {
      final path = Path();
      path.moveTo(s.width * 0.82, s.height * 0.32);
      path.lineTo(s.width * 0.62, s.height * 0.35);
      path.lineTo(s.width * 0.65, s.height * 0.58);
      path.lineTo(s.width * 0.85, s.height * 0.52);
      path.close();
      return path;
    },
    FaceRegion.nose: (s) {
      final path = Path();
      path.moveTo(s.width * 0.44, s.height * 0.30);
      path.lineTo(s.width * 0.56, s.height * 0.30);
      path.lineTo(s.width * 0.54, s.height * 0.48);
      path.lineTo(s.width * 0.46, s.height * 0.48);
      path.close();
      return path;
    },
    FaceRegion.chin: (s) {
      final path = Path();
      path.moveTo(s.width * 0.35, s.height * 0.58);
      path.lineTo(s.width * 0.65, s.height * 0.58);
      path.quadraticBezierTo(
        s.width * 0.5, s.height * 0.78,
        s.width * 0.35, s.height * 0.58,
      );
      path.close();
      return path;
    },
    FaceRegion.jawline: (s) {
      final path = Path();
      path.moveTo(s.width * 0.15, s.height * 0.52);
      path.quadraticBezierTo(
        s.width * 0.5, s.height * 0.72,
        s.width * 0.85, s.height * 0.52,
      );
      path.lineTo(s.width * 0.65, s.height * 0.58);
      path.lineTo(s.width * 0.35, s.height * 0.58);
      path.close();
      return path;
    },
  };

  static FaceRegion? hitTestRegion(Offset position, Size size) {
    for (final entry in _regionPaths.entries) {
      if (entry.value(size).contains(position)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Face outline
    final facePaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    final facePath = Path();
    facePath.moveTo(size.width * 0.5, size.height * 0.05);
    facePath.quadraticBezierTo(
      size.width * 0.92, size.height * 0.25,
      size.width * 0.88, size.height * 0.55,
    );
    facePath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.88,
      size.width * 0.12, size.height * 0.55,
    );
    facePath.quadraticBezierTo(
      size.width * 0.08, size.height * 0.25,
      size.width * 0.5, size.height * 0.05,
    );
    facePath.close();
    canvas.drawPath(facePath, facePaint);

    final outlinePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(facePath, outlinePaint);

    // Regions
    for (final entry in _regionPaths.entries) {
      final region = entry.key;
      final path = entry.value(size);
      final count = regionCounts[region.id] ?? 0;

      final fillPaint = Paint()
        ..color = faceRegionColors[region]!.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      final borderPaint = Paint()
        ..color = faceRegionColors[region]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, borderPaint);

      if (count > 0) {
        final bounds = path.getBounds();
        final center = bounds.center;
        final badgePaint = Paint()..color = AppTheme.accentCoral;
        canvas.drawCircle(center, 14, badgePaint);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FaceMapPainter oldDelegate) {
    return oldDelegate.regionCounts != regionCounts;
  }
}
