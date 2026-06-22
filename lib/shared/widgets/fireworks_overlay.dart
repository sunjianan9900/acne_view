import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// 全屏烟花庆祝动效，播放结束后自动关闭。
Future<void> showFireworksCelebration(BuildContext context) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, _, _) => const _FireworksOverlay(),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _FireworksOverlay extends StatefulWidget {
  const _FireworksOverlay();

  @override
  State<_FireworksOverlay> createState() => _FireworksOverlayState();
}

class _FireworksOverlayState extends State<_FireworksOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _random = Random();
  late final List<_FireworkBurst> _bursts;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward().whenComplete(() {
        if (mounted) Navigator.of(context).pop();
      });

    _bursts = List.generate(5, (index) {
      return _FireworkBurst(
        center: Offset(
          0.15 + _random.nextDouble() * 0.7,
          0.12 + _random.nextDouble() * 0.45,
        ),
        delay: index * 0.12,
        color: _palette[_random.nextInt(_palette.length)],
        particleCount: 28 + _random.nextInt(12),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _FireworksPainter(
              progress: _controller.value,
              bursts: _bursts,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

const _palette = <Color>[
  Color(0xFFE96A80),
  Color(0xFF49A685),
  Color(0xFFF0A060),
  Color(0xFFE8C547),
  Color(0xFF6BBF8A),
  Color(0xFFD94F6A),
];

class _FireworkBurst {
  const _FireworkBurst({
    required this.center,
    required this.delay,
    required this.color,
    required this.particleCount,
  });

  final Offset center;
  final double delay;
  final Color color;
  final int particleCount;
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter({required this.progress, required this.bursts});

  final double progress;
  final List<_FireworkBurst> bursts;

  @override
  void paint(Canvas canvas, Size size) {
    for (final burst in bursts) {
      final local = ((progress - burst.delay) / 0.55).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final center = Offset(
        burst.center.dx * size.width,
        burst.center.dy * size.height,
      );
      final fade = (1 - local).clamp(0.0, 1.0);
      final radius = lerpDouble(8, 120, Curves.easeOut.transform(local))!;

      for (var i = 0; i < burst.particleCount; i++) {
        final angle = (i / burst.particleCount) * pi * 2;
        final offset = Offset(cos(angle), sin(angle)) * radius;
        final particlePos = center + offset;
        final paint = Paint()
          ..color = burst.color.withValues(alpha: fade * 0.9)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(particlePos, lerpDouble(3.5, 1.2, local)!, paint);

        final trail = center + offset * 0.55;
        final trailPaint = Paint()
          ..color = burst.color.withValues(alpha: fade * 0.35)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(center, trail, trailPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
