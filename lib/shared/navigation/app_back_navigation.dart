import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 应用内统一的「返回」行为：先关弹层，再退路由，最后取消输入焦点。
class AppBackNavigation {
  const AppBackNavigation._();

  static void tryPop(
    BuildContext context, {
    GoRouter? router,
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) {
    final rootNav =
        rootNavigatorKey?.currentState ??
        Navigator.maybeOf(context, rootNavigator: true);
    if (rootNav != null && rootNav.canPop()) {
      rootNav.pop();
      return;
    }

    final goRouter = router ?? GoRouter.maybeOf(context);
    if (goRouter != null && goRouter.canPop()) {
      goRouter.pop();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }
}
