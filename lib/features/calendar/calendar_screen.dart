import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/spot_display.dart';
import '../../shared/widgets/douji_shell.dart';
import 'calendar_day_dialog.dart';
import 'diary_edit_dialog.dart';

DateTime _dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

Map<DateTime, List<CheckInWithSpot>> _groupCheckInsByDay(
  List<CheckInWithSpot> checkIns,
) {
  final grouped = <DateTime, List<CheckInWithSpot>>{};
  for (final item in checkIns) {
    final key = _dateOnly(item.checkIn.checkInDate);
    grouped.putIfAbsent(key, () => []).add(item);
  }
  return grouped;
}

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 1080;
    final focusedMonth = ref.watch(calendarFocusedMonthProvider);
    final checkInsAsync = ref.watch(monthCheckInsProvider(focusedMonth));

    return DoujiShell(
      title: '日历',
      subtitle: '按月查看打卡记录，记录每天心情',
      showHeader: !isDesktop,
      rightPanel: isDesktop ? const _DiaryPanel() : null,
      child: checkInsAsync.when(
        data: (checkIns) {
          final grouped = _groupCheckInsByDay(checkIns);
          final calendar = _MonthCalendar(
            focusedMonth: focusedMonth,
            checkInsByDay: grouped,
          );

          if (isDesktop) {
            return calendar;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: calendar),
              const SizedBox(height: 16),
              const SizedBox(height: 280, child: _DiaryPanel()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
      ),
    );
  }
}

class _MonthCalendar extends ConsumerWidget {
  const _MonthCalendar({
    required this.focusedMonth,
    required this.checkInsByDay,
  });

  final DateTime focusedMonth;
  final Map<DateTime, List<CheckInWithSpot>> checkInsByDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthLabel = DateFormat('yyyy年M月').format(focusedMonth);
    final today = _dateOnly(DateTime.now());
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final leadingEmpty = (firstOfMonth.weekday - 1) % 7;
    final totalCells = ((leadingEmpty + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                final current = ref.read(calendarFocusedMonthProvider);
                ref.read(calendarFocusedMonthProvider.notifier).state =
                    DateTime(current.year, current.month - 1);
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                monthLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                final current = ref.read(calendarFocusedMonthProvider);
                ref.read(calendarFocusedMonthProvider.notifier).state =
                    DateTime(current.year, current.month + 1);
              },
              icon: const Icon(Icons.chevron_right),
            ),
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                ref.read(calendarFocusedMonthProvider.notifier).state =
                    DateTime(now.year, now.month);
              },
              child: const Text('今天'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final label in const ['一', '二', '三', '四', '五', '六', '日'])
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.92,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayNumber = index - leadingEmpty + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = DateTime(
                focusedMonth.year,
                focusedMonth.month,
                dayNumber,
              );
              final dayCheckIns = checkInsByDay[_dateOnly(day)] ?? const [];
              final isToday = _isSameDay(day, today);

              return _DayCell(
                day: day,
                checkIns: dayCheckIns,
                isToday: isToday,
                onTap: () => showCalendarDayDialog(
                  context,
                  ref,
                  day: day,
                  checkIns: dayCheckIns,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.checkIns,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final List<CheckInWithSpot> checkIns;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visible = checkIns.take(3).toList();
    final overflow = checkIns.length - visible.length;

    return Material(
      color: isToday ? AppTheme.softRose : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday ? AppTheme.brandPink.withValues(alpha: 0.35) : AppTheme.panelBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isToday ? AppTheme.brandPink : AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: checkIns.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final item in visible)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.brandPink.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  spotDisplayTitle(item.spot),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.brandPink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          if (overflow > 0)
                            Text(
                              '+$overflow',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaryPanel extends ConsumerWidget {
  const _DiaryPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryEntriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '心情日记',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await showDiaryEditDialog(context, ref);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('新建'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '记录每天的皮肤状态与心情',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        '还没有日记，点击「新建」开始记录',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _DiaryTile(entry: entries[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('加载失败：$error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryTile extends ConsumerWidget {
  const _DiaryTile({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = DateFormat('M月d日').format(entry.entryDate);

    return Material(
      color: AppTheme.softBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => showDiaryEditDialog(context, ref, existing: entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.brandPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
