import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_back_navigation.dart';

class AppEscapeHandler extends StatelessWidget {
  const AppEscapeHandler({
    super.key,
    required this.child,
    required this.router,
    required this.rootNavigatorKey,
  });

  final Widget child;
  final GoRouter router;
  final GlobalKey<NavigatorState> rootNavigatorKey;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _AppBackIntent(),
      },
      child: Actions(
        actions: {
          _AppBackIntent: CallbackAction<_AppBackIntent>(
            onInvoke: (_) {
              AppBackNavigation.tryPop(
                context,
                router: router,
                rootNavigatorKey: rootNavigatorKey,
              );
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _AppBackIntent extends Intent {
  const _AppBackIntent();
}
