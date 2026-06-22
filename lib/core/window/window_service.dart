import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_theme.dart';

const _keyWidth = 'window_width';
const _keyHeight = 'window_height';
const _keyX = 'window_x';
const _keyY = 'window_y';

const _defaultSize = Size(1280, 820);
const _minimumSize = Size(960, 640);

bool get isDesktopPlatform =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

class WindowService {
  WindowService._();

  static final _listener = _WindowStateListener();

  static Future<void> initialize() async {
    if (!isDesktopPlatform) return;

    await windowManager.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final width = prefs.getDouble(_keyWidth) ?? _defaultSize.width;
    final height = prefs.getDouble(_keyHeight) ?? _defaultSize.height;
    final x = prefs.getDouble(_keyX);
    final y = prefs.getDouble(_keyY);
    final hasPosition = x != null && y != null;

    final windowOptions = WindowOptions(
      size: Size(width, height),
      minimumSize: _minimumSize,
      center: !hasPosition,
      backgroundColor: AppTheme.softBackground,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      title: '痘迹',
    );

    windowManager.addListener(_listener);

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (hasPosition) {
        await windowManager.setPosition(Offset(x, y));
      }
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

class _WindowStateListener with WindowListener {
  Timer? _saveTimer;

  @override
  void onWindowResize() => _scheduleSave();

  @override
  void onWindowMove() => _scheduleSave();

  @override
  void onWindowClose() {
    _saveTimer?.cancel();
    unawaited(_persistState());
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _persistState);
  }

  Future<void> _persistState() async {
    if (!isDesktopPlatform) return;

    final prefs = await SharedPreferences.getInstance();
    final size = await windowManager.getSize();
    final position = await windowManager.getPosition();

    await prefs.setDouble(_keyWidth, size.width);
    await prefs.setDouble(_keyHeight, size.height);
    await prefs.setDouble(_keyX, position.dx);
    await prefs.setDouble(_keyY, position.dy);
  }
}

/// 桌面端窗口顶部拖拽区域，配合 hidden title bar 使用。
class WindowDragRegion extends StatelessWidget {
  const WindowDragRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktopPlatform) return child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: child,
    );
  }
}
