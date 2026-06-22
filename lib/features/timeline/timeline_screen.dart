import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/photo/add_photo_flow.dart';
import '../../shared/photo/photo_viewer.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/models/treatment_type.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotAsync = ref.watch(spotProvider(spotId));
    final checkInsAsync = ref.watch(checkInsForSpotProvider(spotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('变化时间线'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: () => showAddPhotoOptions(context, spotId),
            tooltip: '添加照片',
          ),
        ],
      ),
      body: spotAsync.when(
        data: (spot) {
          if (spot == null) {
            return const Center(child: Text('痘痘不存在'));
          }
          final region = FaceRegion.fromId(spot.faceRegion);
          final status = SpotStatus.fromId(spot.status);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SpotHeader(spot: spot, region: region, status: status),
              Expanded(
                child: checkInsAsync.when(
                  data: (checkIns) {
                    if (checkIns.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 64,
                              color: AppTheme.primaryTeal.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('还没有打卡记录'),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () =>
                                  showAddPhotoOptions(context, spotId),
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: const Text('添加第一张照片'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: checkIns.length,
                      itemBuilder: (context, index) {
                        return _CheckInCard(
                          checkIn: checkIns[index],
                          spotId: spotId,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

class _SpotHeader extends StatelessWidget {
  const _SpotHeader({
    required this.spot,
    required this.region,
    required this.status,
  });

  final AcneSpot spot;
  final FaceRegion? region;
  final SpotStatus status;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.cardWhite,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: status == SpotStatus.active
                  ? AppTheme.accentCoral.withValues(alpha: 0.15)
                  : AppTheme.primaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              status == SpotStatus.active ? Icons.circle : Icons.check_circle,
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
                  '${region?.label ?? spot.faceRegion} · ${status.label}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '追踪自 ${dateFormat.format(spot.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends ConsumerWidget {
  const _CheckInCard({required this.checkIn, required this.spotId});

  final CheckInRecord checkIn;
  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return FutureBuilder<({Photo? photo, List<TreatmentItem> treatments})>(
      future: () async {
        final repo = ref.read(checkInRepositoryProvider);
        final photo = await repo.getPhoto(checkIn.id);
        final treatments = await repo.getTreatments(checkIn.id);
        return (photo: photo, treatments: treatments);
      }(),
      builder: (context, snapshot) {
        final photo = snapshot.data?.photo;
        final treatments = snapshot.data?.treatments ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: photo != null
                ? () => showPhotoViewer(context, photo.filePath)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photo.filePath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(checkIn.checkInDate),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (checkIn.phase.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _PhaseChip(phase: AcnePhase.fromId(checkIn.phase)),
                        ],
                        if (checkIn.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            checkIn.note,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (treatments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: treatments
                                .map(
                                  (t) => Chip(
                                    label: Text(
                                      '${TreatmentType.fromId(t.type).label}: ${t.name}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.phase});

  final AcnePhase phase;

  @override
  Widget build(BuildContext context) {
    final color = acnePhaseColor(phase);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        phase.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
