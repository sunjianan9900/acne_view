import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 全屏彩纸拉花庆祝动效，播放结束后自动关闭。
Future<void> showConfettiCelebration(BuildContext context) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.15),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, _, _) => const _ConfettiCelebrationOverlay(),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _ConfettiCelebrationOverlay extends StatefulWidget {
  const _ConfettiCelebrationOverlay();

  @override
  State<_ConfettiCelebrationOverlay> createState() =>
      _ConfettiCelebrationOverlayState();
}

class _ConfettiCelebrationOverlayState extends State<_ConfettiCelebrationOverlay> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 3),
    )..play();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
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
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.08,
              numberOfParticles: 24,
              maxBlastForce: 28,
              minBlastForce: 12,
              gravity: 0.12,
              colors: const [
                AppTheme.brandPink,
                AppTheme.primaryTeal,
                AppTheme.accentCoral,
                Color(0xFFE8C547),
                Color(0xFF6BBF8A),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 18,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.1,
              colors: const [
                AppTheme.brandPink,
                AppTheme.primaryTeal,
                AppTheme.accentCoral,
                Color(0xFFE8C547),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
