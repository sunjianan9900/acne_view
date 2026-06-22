import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/app_theme.dart';
import '../../core/window/window_service.dart';

/// 自定义窗口控制按钮，替代系统交通灯。
class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (isDesktopPlatform) {
      windowManager.addListener(this);
      _syncMaximized();
    }
  }

  @override
  void dispose() {
    if (isDesktopPlatform) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _syncMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = maximized);
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    if (!isDesktopPlatform) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowControlButton(
          icon: Icons.close_rounded,
          tooltip: '关闭',
          hoverColor: const Color(0xFFFFE8EC),
          hoverIconColor: const Color(0xFFE85D75),
          onPressed: windowManager.close,
        ),
        const SizedBox(width: 8),
        _WindowControlButton(
          icon: Icons.remove_rounded,
          tooltip: '最小化',
          onPressed: windowManager.minimize,
        ),
        const SizedBox(width: 8),
        _WindowControlButton(
          icon: _isMaximized
              ? Icons.filter_none_rounded
              : Icons.crop_square_rounded,
          tooltip: _isMaximized ? '还原' : '最大化',
          onPressed: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
            await _syncMaximized();
          },
        ),
      ],
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hoverColor,
    this.hoverIconColor,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onPressed;
  final Color? hoverColor;
  final Color? hoverIconColor;

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hovered
        ? (widget.hoverColor ?? AppTheme.softRose)
        : AppTheme.softBackground;
    final iconColor = _hovered
        ? (widget.hoverIconColor ?? AppTheme.brandPink)
        : AppTheme.textSecondary;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered
                    ? AppTheme.brandPink.withValues(alpha: 0.35)
                    : AppTheme.panelBorder,
              ),
            ),
            child: Icon(widget.icon, size: 14, color: iconColor),
          ),
        ),
      ),
    );
  }
}
