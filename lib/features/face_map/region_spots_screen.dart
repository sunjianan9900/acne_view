import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/photo/add_photo_flow.dart';

class RegionSpotsScreen extends ConsumerWidget {
  const RegionSpotsScreen({super.key, required this.regionId});

  final String regionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = FaceRegion.fromId(regionId);
    if (region == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('区域')),
        body: const Center(child: Text('未知区域')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${region.label} - 痘痘列表')),
      body: RegionSpotsContent(region: region),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createSpot(context, ref, region),
        icon: const Icon(Icons.add),
        label: const Text('添加痘痘'),
      ),
    );
  }

  Future<void> _createSpot(
    BuildContext context,
    WidgetRef ref,
    FaceRegion region,
  ) async {
    await ref.read(spotRepositoryProvider).createSpot(region: region);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('痘痘已创建')));
    }
  }
}

class RegionSpotsContent extends ConsumerWidget {
  const RegionSpotsContent({
    super.key,
    required this.region,
    this.onClearSelection,
    this.showHeader = true,
  });

  final FaceRegion region;
  final VoidCallback? onClearSelection;
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotsAsync = ref.watch(spotsByRegionProvider(region.id));

    return spotsAsync.when(
      data: (spots) {
        if (showHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${region.label} · 痘痘列表',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onClearSelection != null)
                    TextButton(
                      onPressed: onClearSelection,
                      child: const Text('查看全部'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _RegionSpotsList(spots: spots, region: region),
              ),
            ],
          );
        }
        return _RegionSpotsList(spots: spots, region: region);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

class _RegionSpotsList extends StatelessWidget {
  const _RegionSpotsList({required this.spots, required this.region});

  final List<AcneSpot> spots;
  final FaceRegion region;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.face_retouching_natural,
              size: 64,
              color: AppTheme.primaryTeal.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              '该区域暂无痘痘记录',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: spots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _SpotCard(spot: spots[index], region: region);
      },
    );
  }
}

class _SpotCard extends ConsumerWidget {
  const _SpotCard({required this.spot, required this.region});

  final AcneSpot spot;
  final FaceRegion region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = SpotStatus.fromId(spot.status);
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/timeline/${spot.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: status == SpotStatus.active
                      ? AppTheme.accentCoral.withValues(alpha: 0.15)
                      : AppTheme.primaryTeal.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == SpotStatus.active
                      ? Icons.circle
                      : Icons.check_circle,
                  color: status == SpotStatus.active
                      ? AppTheme.accentCoral
                      : AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${region.label} · ${status.label}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '创建于 ${dateFormat.format(spot.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (spot.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        spot.note,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'capture') {
                    showAddPhotoOptions(context, spot.id);
                  } else if (value == 'timeline') {
                    context.push('/timeline/${spot.id}');
                  } else if (value == 'heal') {
                    await ref
                        .read(spotRepositoryProvider)
                        .updateSpotStatus(spot.id, SpotStatus.healed);
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('删除痘痘'),
                        content: const Text('将删除该痘痘的所有打卡记录和照片，此操作不可撤销。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(spotRepositoryProvider)
                          .deleteSpot(spot.id);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'capture', child: Text('拍照打卡')),
                  const PopupMenuItem(value: 'timeline', child: Text('查看时间线')),
                  if (status == SpotStatus.active)
                    const PopupMenuItem(value: 'heal', child: Text('标记为已愈合')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
