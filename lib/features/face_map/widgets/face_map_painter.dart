import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/face_region.dart';

final Map<FaceRegion, Color> faceRegionColors = {
  FaceRegion.forehead: const Color(0xFF8FD3F4),
  FaceRegion.leftCheek: const Color(0xFFAED9D6),
  FaceRegion.rightCheek: const Color(0xFFCDE4D6),
  FaceRegion.nose: const Color(0xFFF0D36B),
  FaceRegion.chin: const Color(0xFFF5B08A),
  FaceRegion.jawline: const Color(0xFFED8F7E),
};

const String _faceOutlineAsset = 'assets/face_map/face_outline.png';
const Size _faceOutlineSize = Size(1448, 1086);
const Rect _faceContentFrame = Rect.fromLTWH(0.274, 0.022, 0.451, 0.924);

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
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                _faceOutlineAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: FaceMapPainter(regionCounts: regionCounts),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) {
                  final region = FaceMapPainter.hitTestRegion(
                    details.localPosition,
                    constraints.biggest,
                  );
                  if (region != null) onRegionTap(region);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class FaceMapPainter extends CustomPainter {
  FaceMapPainter({required this.regionCounts});

  final Map<String, int> regionCounts;

  static Rect _contentRect(Size size) {
    return Rect.fromLTWH(
      size.width * _faceContentFrame.left,
      size.height * _faceContentFrame.top,
      size.width * _faceContentFrame.width,
      size.height * _faceContentFrame.height,
    );
  }

  static final Map<FaceRegion, Path Function(Size)> _regionPaths = {
    FaceRegion.forehead: (s) {
      final face = _contentRect(s);
      final path = Path();
      path.moveTo(face.left + face.width * 0.28, face.top + face.height * 0.05);
      path.quadraticBezierTo(
        face.left + face.width * 0.50,
        face.top + face.height * 0.00,
        face.left + face.width * 0.72,
        face.top + face.height * 0.05,
      );
      path.lineTo(face.left + face.width * 0.69, face.top + face.height * 0.20);
      path.quadraticBezierTo(
        face.left + face.width * 0.50,
        face.top + face.height * 0.17,
        face.left + face.width * 0.31,
        face.top + face.height * 0.20,
      );
      path.close();
      return path;
    },
    FaceRegion.leftCheek: (s) {
      final face = _contentRect(s);
      final path = Path();
      path.moveTo(face.left + face.width * 0.12, face.top + face.height * 0.34);
      path.lineTo(face.left + face.width * 0.31, face.top + face.height * 0.36);
      path.lineTo(face.left + face.width * 0.27, face.top + face.height * 0.57);
      path.quadraticBezierTo(
        face.left + face.width * 0.18,
        face.top + face.height * 0.69,
        face.left + face.width * 0.11,
        face.top + face.height * 0.60,
      );
      path.quadraticBezierTo(
        face.left + face.width * 0.08,
        face.top + face.height * 0.42,
        face.left + face.width * 0.12,
        face.top + face.height * 0.34,
      );
      path.close();
      return path;
    },
    FaceRegion.rightCheek: (s) {
      final face = _contentRect(s);
      final path = Path();
      path.moveTo(face.left + face.width * 0.88, face.top + face.height * 0.34);
      path.lineTo(face.left + face.width * 0.69, face.top + face.height * 0.36);
      path.lineTo(face.left + face.width * 0.73, face.top + face.height * 0.57);
      path.quadraticBezierTo(
        face.left + face.width * 0.82,
        face.top + face.height * 0.69,
        face.left + face.width * 0.89,
        face.top + face.height * 0.60,
      );
      path.quadraticBezierTo(
        face.left + face.width * 0.92,
        face.top + face.height * 0.42,
        face.left + face.width * 0.88,
        face.top + face.height * 0.34,
      );
      path.close();
      return path;
    },
    FaceRegion.nose: (s) {
      final face = _contentRect(s);
      final path = Path();
      path.moveTo(face.left + face.width * 0.45, face.top + face.height * 0.33);
      path.lineTo(face.left + face.width * 0.55, face.top + face.height * 0.33);
      path.lineTo(face.left + face.width * 0.58, face.top + face.height * 0.46);
      path.quadraticBezierTo(
        face.left + face.width * 0.50,
        face.top + face.height * 0.55,
        face.left + face.width * 0.42,
        face.top + face.height * 0.46,
      );
      path.close();
      return path;
    },
    FaceRegion.chin: (s) {
      final face = _contentRect(s);
      final path = Path();
      path.moveTo(face.left + face.width * 0.42, face.top + face.height * 0.66);
      path.quadraticBezierTo(
        face.left + face.width * 0.50,
        face.top + face.height * 0.73,
        face.left + face.width * 0.58,
        face.top + face.height * 0.66,
      );
      path.quadraticBezierTo(
        face.left + face.width * 0.63,
        face.top + face.height * 0.78,
        face.left + face.width * 0.50,
        face.top + face.height * 0.85,
      );
      path.quadraticBezierTo(
        face.left + face.width * 0.37,
        face.top + face.height * 0.78,
        face.left + face.width * 0.42,
        face.top + face.height * 0.66,
      );
      path.close();
      return path;
    },
    FaceRegion.jawline: (s) {
      final face = _contentRect(s);
      final path = Path();
      path.moveTo(face.left + face.width * 0.11, face.top + face.height * 0.59);
      path.quadraticBezierTo(
        face.left + face.width * 0.29,
        face.top + face.height * 0.84,
        face.left + face.width * 0.48,
        face.top + face.height * 0.88,
      );
      path.lineTo(face.left + face.width * 0.52, face.top + face.height * 0.88);
      path.quadraticBezierTo(
        face.left + face.width * 0.71,
        face.top + face.height * 0.84,
        face.left + face.width * 0.89,
        face.top + face.height * 0.59,
      );
      path.lineTo(face.left + face.width * 0.76, face.top + face.height * 0.65);
      path.quadraticBezierTo(
        face.left + face.width * 0.61,
        face.top + face.height * 0.76,
        face.left + face.width * 0.50,
        face.top + face.height * 0.82,
      );
      path.quadraticBezierTo(
        face.left + face.width * 0.39,
        face.top + face.height * 0.76,
        face.left + face.width * 0.24,
        face.top + face.height * 0.65,
      );
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
    if (size.isEmpty) return;

    for (final entry in _regionPaths.entries) {
      final region = entry.key;
      final path = entry.value(size);
      final count = regionCounts[region.id] ?? 0;

      final fillPaint = Paint()
        ..color = faceRegionColors[region]!.withValues(alpha: 0.45)
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
