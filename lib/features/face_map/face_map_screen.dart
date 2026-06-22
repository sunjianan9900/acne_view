import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/spot_display.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/widgets/douji_shell.dart';
import 'add_spot_dialog.dart';
import 'region_spots_screen.dart';
import 'widgets/face_map_painter.dart';

class FaceMapScreen extends ConsumerStatefulWidget {
  const FaceMapScreen({super.key});

  @override
  ConsumerState<FaceMapScreen> createState() => _FaceMapScreenState();
}

class _FaceMapScreenState extends ConsumerState<FaceMapScreen> {
  FaceRegion? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final regionCounts = ref.watch(regionCountsProvider);
    final allSpots = ref.watch(allSpotsProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1080;

    return DoujiShell(
      title: '面部地图',
      subtitle: '点击面部区域查看痘痘，或新增记录',
      actions: [
        FilledButton.icon(
          onPressed: () => _addSpot(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('添加痘痘'),
        ),
      ],
      rightPanel: isDesktop
          ? _selectedRegion == null
              ? allSpots.when(
                  data: (spots) => _SpotListPanel(spots: spots),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                )
              : RegionSpotsContent(
                  region: _selectedRegion!,
                  onClearSelection: () => setState(() => _selectedRegion = null),
                  showHeader: true,
                )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.panelBorder),
              ),
              padding: const EdgeInsets.all(18),
              child: regionCounts.when(
                data: (counts) => FaceMapWidget(
                  regionCounts: counts,
                  onRegionTap: (region) {
                    if (isDesktop) {
                      setState(() => _selectedRegion = region);
                      return;
                    }
                    context.push('/region/${region.id}');
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _RegionLegend(),
        ],
      ),
    );
  }

  Future<void> _addSpot(BuildContext context, WidgetRef ref) async {
    final spotId = await showAddSpotDialog(context, ref);
    if (spotId == null || !context.mounted) return;

    final spot = await ref.read(spotRepositoryProvider).getSpot(spotId);
    if (!context.mounted || spot == null) return;

    final region = FaceRegion.fromId(spot.faceRegion);
    if (MediaQuery.of(context).size.width >= 1080 && region != null) {
      setState(() => _selectedRegion = region);
    } else {
      context.push('/region/${spot.faceRegion}');
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('痘痘已创建')));
  }
}

class _RegionLegend extends StatelessWidget {
  const _RegionLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: FaceRegion.values
            .map(
              (r) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: faceRegionColors[r]!.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(r.label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SpotListPanel extends StatelessWidget {
  const _SpotListPanel({required this.spots});

  final List<AcneSpot> spots;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '已记录的痘痘 (${spots.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: spots.isEmpty
                  ? Center(
                      child: Text(
                        '还没有痘痘记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: spots.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final spot = spots[index];
                        final status = SpotStatus.fromId(spot.status);
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/timeline/${spot.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.softRose.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: status == SpotStatus.active
                                      ? AppTheme.accentCoral.withValues(
                                          alpha: 0.18,
                                        )
                                      : AppTheme.primaryTeal.withValues(
                                          alpha: 0.18,
                                        ),
                                  child: Icon(
                                    status == SpotStatus.active
                                        ? Icons.fiber_manual_record
                                        : Icons.task_alt,
                                    color: status == SpotStatus.active
                                        ? AppTheme.accentCoral
                                        : AppTheme.primaryTeal,
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spotDisplayTitle(spot),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        '区域 ${spotRegionLabel(spot)} · 创建于 ${dateFormat.format(spot.createdAt)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  status.label,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: status == SpotStatus.active
                                            ? AppTheme.accentCoral
                                            : AppTheme.primaryTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
