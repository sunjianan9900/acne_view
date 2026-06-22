import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/spot_display.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/widgets/douji_shell.dart';
import '../home/spot_detail_dialog.dart';
import 'add_spot_dialog.dart';
import 'widgets/aggregated_face_map_widget.dart';

class FaceMapScreen extends ConsumerStatefulWidget {
  const FaceMapScreen({super.key});

  @override
  ConsumerState<FaceMapScreen> createState() => _FaceMapScreenState();
}

class _FaceMapScreenState extends ConsumerState<FaceMapScreen> {
  String? _highlightedSpotId;

  @override
  Widget build(BuildContext context) {
    final placedMarkers = ref.watch(allPlacedSpotMarkersProvider);
    final allSpots = ref.watch(allSpotsProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1080;

    return DoujiShell(
      title: '面部地图',
      subtitle: '点击面部标记查看痘痘详情',
      actions: [
        FilledButton.icon(
          onPressed: () => _addSpot(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('添加痘痘'),
        ),
      ],
      rightPanel: isDesktop
          ? allSpots.when(
              data: (spots) => _SpotListPanel(
                spots: spots,
                highlightedSpotId: _highlightedSpotId,
                onSpotTap: (spotId) => _openSpotDetail(context, ref, spotId),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.panelBorder),
        ),
        padding: const EdgeInsets.all(18),
        child: placedMarkers.when(
          data: (markers) => markers.isEmpty
              ? Center(
                  child: Text(
                    '还没有面部标记\n在概览页为痘痘项目添加拍照位置后会显示在这里',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                )
              : AggregatedFaceMapWidget(
                  placedMarkers: markers,
                  highlightedSpotId: _highlightedSpotId,
                  onMarkerTap: (spotId) {
                    setState(() => _highlightedSpotId = spotId);
                    _openSpotDetail(context, ref, spotId);
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败: $e')),
        ),
      ),
    );
  }

  void _openSpotDetail(BuildContext context, WidgetRef ref, String spotId) {
    showSpotDetailDialog(context, ref, initialSpotId: spotId);
  }

  Future<void> _addSpot(BuildContext context, WidgetRef ref) async {
    final spotId = await showAddSpotDialog(context, ref);
    if (spotId == null || !context.mounted) return;

    setState(() => _highlightedSpotId = spotId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('痘痘已创建，可在概览页标记拍照位置')));
  }
}

class _SpotListPanel extends StatelessWidget {
  const _SpotListPanel({
    required this.spots,
    required this.onSpotTap,
    this.highlightedSpotId,
  });

  final List<AcneSpot> spots;
  final void Function(String spotId) onSpotTap;
  final String? highlightedSpotId;

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
                        final selected = spot.id == highlightedSpotId;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onSpotTap(spot.id),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.softRose
                                  : AppTheme.softRose.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(
                                      color: AppTheme.brandPink.withValues(
                                        alpha: 0.5,
                                      ),
                                    )
                                  : null,
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
