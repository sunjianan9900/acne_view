import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/window/window_service.dart';
import 'window_controls.dart';

class DoujiShell extends StatelessWidget {
  const DoujiShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.rightPanel,
    this.actions = const <Widget>[],
    this.showHeader = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? rightPanel;
  final List<Widget> actions;
  final bool showHeader;

  static const _navItems = <_NavItem>[
    _NavItem(label: '概览', icon: Icons.home_outlined, route: '/'),
    _NavItem(label: '痘痘地图', icon: Icons.face_outlined, route: '/face-map'),
    _NavItem(label: '痘痘科普', icon: Icons.menu_book_outlined, route: '/acne-education'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1080;
    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Sidebar(),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.panelBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showHeader) ...[
                        Row(
                          children: [
                            Expanded(
                              child: WindowDragRegion(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            ...actions,
                          ],
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions,
                        ),
                        if (actions.isNotEmpty) const SizedBox(height: 12),
                      ],
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ),
            if (rightPanel != null) ...[
              const SizedBox(width: 16),
              SizedBox(width: 300, child: rightPanel!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WindowControls(),
            const SizedBox(height: 16),
            Row(
              children: [
                WindowDragRegion(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.softRose,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          color: AppTheme.brandPink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '痘迹',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '记录一处变化',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            for (final item in DoujiShell._navItems) ...[
              _NavTile(item: item, selected: location == item.route),
              const SizedBox(height: 6),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.softRose,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '坚持记录',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.brandPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '规律追踪会让你更容易看到改善趋势。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected});

  final _NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.softRose : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: selected ? AppTheme.brandPink : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? AppTheme.brandPink : AppTheme.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
