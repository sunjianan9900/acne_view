import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/spot_display.dart';
import '../check_in/check_in_detail_dialog.dart';

Future<void> showCalendarDayDialog(
  BuildContext context,
  WidgetRef ref, {
  required DateTime day,
  required List<CheckInWithSpot> checkIns,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => CalendarDayDialog(day: day, checkIns: checkIns),
  );
}

class CalendarDayDialog extends ConsumerWidget {
  const CalendarDayDialog({
    super.key,
    required this.day,
    required this.checkIns,
  });

  final DateTime day;
  final List<CheckInWithSpot> checkIns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = DateFormat('yyyy年M月d日').format(day);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${checkIns.length} 条打卡记录',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: checkIns.isEmpty
                    ? Center(
                        child: Text(
                          '这一天还没有打卡记录',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: checkIns.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = checkIns[index];
                          return _CheckInTile(
                            item: item,
                            onTap: () async {
                              await showCheckInDetailDialog(
                                context,
                                ref,
                                checkInId: item.checkIn.id,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInTile extends StatelessWidget {
  const _CheckInTile({required this.item, required this.onTap});

  final CheckInWithSpot item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final phase = AcnePhase.fromId(item.checkIn.phase);
    final timeLabel = DateFormat('HH:mm').format(item.checkIn.checkInDate);

    return Material(
      color: AppTheme.softRose,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spotDisplayTitle(item.spot),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${spotRegionLabel(item.spot)} · $timeLabel · ${phase.label}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (item.checkIn.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.checkIn.note.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
