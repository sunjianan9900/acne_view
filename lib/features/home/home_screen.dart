import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/douji_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = ref.watch(activeSpotCountProvider);
    final todayCheckIns = ref.watch(todayCheckInCountProvider);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isDesktop = MediaQuery.of(context).size.width >= 1080;
    final active = activeCount.valueOrNull ?? 0;
    final checkIns = todayCheckIns.valueOrNull ?? 0;

    return DoujiShell(
      title: '我的痘痘',
      subtitle: '记录每次变化，看到真实进展',
      actions: [
        FilledButton.icon(
          onPressed: () => context.push('/face-map'),
          icon: const Icon(Icons.add),
          label: const Text('新增痘痘'),
        ),
      ],
      rightPanel: isDesktop
          ? _HomeRightPanel(
              today: today,
              activeCount: active,
              todayCheckIns: checkIns,
            )
          : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryCard(activeCount: active, todayCheckIns: checkIns),
            const SizedBox(height: 18),
            _QuickActionCard(today: today, todayCheckIns: checkIns),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => context.push('/help'),
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('拍摄与记录建议'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.activeCount, required this.todayCheckIns});

  final int activeCount;
  final int todayCheckIns;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                label: '活跃痘痘',
                value: '$activeCount',
                icon: Icons.fiber_manual_record,
                color: AppTheme.accentCoral,
              ),
            ),
            Container(width: 1, height: 48, color: AppTheme.panelBorder),
            Expanded(
              child: _StatItem(
                label: '今日打卡',
                value: '$todayCheckIns',
                icon: Icons.task_alt,
                color: AppTheme.primaryTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.today, required this.todayCheckIns});

  final String today;
  final int todayCheckIns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日记录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '$today · ${todayCheckIns > 0 ? "已完成 $todayCheckIns 次打卡" : "还未打卡"}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/face-map'),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('开始拍摄'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/face-map'),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('面部地图'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeRightPanel extends StatelessWidget {
  const _HomeRightPanel({
    required this.today,
    required this.activeCount,
    required this.todayCheckIns,
  });

  final String today;
  final int activeCount;
  final int todayCheckIns;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.panelBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '用药记录',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _infoLine(context, '日期', today),
              _infoLine(context, '活跃痘痘', '$activeCount 处'),
              _infoLine(context, '今日打卡', '$todayCheckIns 次'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.softRose,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '保持作息规律、饮食清淡，连续记录会更容易观察治疗方案是否有效。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoLine(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
