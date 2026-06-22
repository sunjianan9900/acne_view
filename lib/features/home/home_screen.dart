import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/spot_display.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/photo/add_photo_flow.dart';
import '../../shared/widgets/douji_shell.dart';
import '../face_map/add_spot_dialog.dart';
import 'spot_detail_dialog.dart';

Future<void> _addSpotFromHome(BuildContext context, WidgetRef ref) async {
  final spotId = await showAddSpotDialog(context, ref);
  if (spotId == null || !context.mounted) return;

  ref.read(selectedHomeSpotIdProvider.notifier).state = spotId;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('痘痘已创建')));
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotsAsync = ref.watch(allSpotsProvider);
    final selectedId = ref.watch(selectedHomeSpotIdProvider);

    ref.listen<AsyncValue<List<AcneSpot>>>(allSpotsProvider, (previous, next) {
      next.whenData((spots) {
        final current = ref.read(selectedHomeSpotIdProvider);
        final resolved = _resolveSelectedId(spots, current);
        if (resolved != current) {
          ref.read(selectedHomeSpotIdProvider.notifier).state = resolved;
        }
      });
    });

    return spotsAsync.when(
      data: (spots) {
        final effectiveId = _resolveSelectedId(spots, selectedId);
        final selectedSpot = _resolveSelectedSpot(spots, effectiveId);
        if (effectiveId != selectedId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedHomeSpotIdProvider.notifier).state = effectiveId;
          });
        }

        final isDesktop = MediaQuery.of(context).size.width >= 1080;
        return DoujiShell(
          title: '我的痘痘',
          subtitle: '记录每次变化，看到真实进展',
          showHeader: !isDesktop,
          actions: [
            FilledButton.icon(
              onPressed: () => _addSpotFromHome(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('新增痘痘'),
            ),
          ],
          rightPanel: isDesktop
              ? _SpotDetailPanel(spot: selectedSpot)
              : null,
          child: HomeBody(
            spots: spots,
            selectedSpot: selectedSpot,
            isDesktop: isDesktop,
          ),
        );
      },
      loading: () => const DoujiShell(
        title: '我的痘痘',
        subtitle: '加载中…',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => DoujiShell(
        title: '我的痘痘',
        subtitle: '加载失败',
        child: Center(child: Text('加载失败: $e')),
      ),
    );
  }

  String? _resolveSelectedId(List<AcneSpot> spots, String? selectedId) {
    if (spots.isEmpty) return null;
    if (selectedId != null && spots.any((s) => s.id == selectedId)) {
      return selectedId;
    }
    return spots.first.id;
  }

  AcneSpot? _resolveSelectedSpot(List<AcneSpot> spots, String? selectedId) {
    if (selectedId == null) return null;
    for (final spot in spots) {
      if (spot.id == selectedId) return spot;
    }
    return null;
  }
}

class HomeBody extends ConsumerWidget {
  const HomeBody({
    super.key,
    required this.spots,
    required this.selectedSpot,
    required this.isDesktop,
  });

  final List<AcneSpot> spots;
  final AcneSpot? selectedSpot;
  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 250,
            child: _SpotListPanel(spots: spots, selectedSpot: selectedSpot),
          ),
          const VerticalDivider(width: 1, color: AppTheme.panelBorder),
          const SizedBox(width: 20),
          Expanded(
            child: selectedSpot == null
                ? const _EmptySpotDetail()
                : _SpotTimelinePanel(spot: selectedSpot!),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: spots.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final spot = spots[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.panelBorder),
          ),
          title: Text(spotDisplayTitle(spot)),
          subtitle: Text(
            '区域 ${spotRegionLabel(spot)} · ${DateFormat('yyyy-MM-dd').format(spot.createdAt)}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showSpotDetailDialog(
            context,
            ref,
            initialSpotId: spot.id,
          ),
        );
      },
    );
  }
}

class _SpotListPanel extends ConsumerWidget {
  const _SpotListPanel({required this.spots, required this.selectedSpot});

  final List<AcneSpot> spots;
  final AcneSpot? selectedSpot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '我的痘痘',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: spots.isEmpty
              ? Center(
                  child: Text(
                    '还没有痘痘记录',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: spots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final spot = spots[index];
                    final selected = spot.id == selectedSpot?.id;
                    return _SpotListTile(
                      spot: spot,
                      selected: selected,
                      onTap: () =>
                          ref.read(selectedHomeSpotIdProvider.notifier).state =
                              spot.id,
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _addSpotFromHome(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('新建痘痘'),
        ),
      ],
    );
  }
}

class _SpotListTile extends ConsumerWidget {
  const _SpotListTile({
    required this.spot,
    required this.selected,
    required this.onTap,
  });

  final AcneSpot spot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnail = ref.watch(spotThumbnailProvider(spot.id));
    final dateFormat = DateFormat('yyyy-MM-dd');

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.softRose : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppTheme.brandPink.withValues(alpha: 0.35)
                : AppTheme.panelBorder,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: thumbnail.when(
                data: (photo) => _SpotThumbnail(photoPath: photo?.filePath),
                loading: () => const _SpotThumbnail(),
                error: (_, _) => const _SpotThumbnail(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spotDisplayTitle(spot),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '区域 ${spotRegionLabel(spot)} · ${dateFormat.format(spot.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
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

class _SpotThumbnail extends StatelessWidget {
  const _SpotThumbnail({this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    if (photoPath != null && File(photoPath!).existsSync()) {
      return Image.file(
        File(photoPath!),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 40,
      height: 40,
      color: AppTheme.softRose,
      child: const Icon(
        Icons.face_retouching_natural,
        size: 20,
        color: AppTheme.brandPink,
      ),
    );
  }
}

class _SpotTimelinePanel extends ConsumerWidget {
  const _SpotTimelinePanel({required this.spot});

  final AcneSpot spot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(spotTimelineProvider(spot.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '变化时间线',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: timeline.when(
            data: (items) => items.isEmpty
                ? const _EmptySpotDetail()
                : Center(
                    child: Text(
                      '请在详情弹窗中查看该痘痘的完整变化记录',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败: $e')),
          ),
        ),
      ],
    );
  }
}

class _SpotDetailPanel extends ConsumerStatefulWidget {
  const _SpotDetailPanel({required this.spot});

  final AcneSpot? spot;

  @override
  ConsumerState<_SpotDetailPanel> createState() => _SpotDetailPanelState();
}

class _SpotDetailPanelState extends ConsumerState<_SpotDetailPanel> {
  late final TextEditingController _noteController;
  bool _savingNote = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.spot?.note ?? '');
  }

  @override
  void didUpdateWidget(covariant _SpotDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spot?.id != widget.spot?.id) {
      _noteController.text = widget.spot?.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final spot = widget.spot;
    if (spot == null) return;

    setState(() => _savingNote = true);
    try {
      await ref
          .read(spotRepositoryProvider)
          .updateSpotNote(spot.id, _noteController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('备注已保存')));
      }
    } finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    if (spot == null) {
      return const _EmptySpotDetail();
    }

    final status = SpotStatus.fromId(spot.status);
    final timeline = ref.watch(spotTimelineProvider(spot.id));
    final dateFormat = DateFormat('yyyy-MM-dd');
    final phaseLabel = timeline.maybeWhen(
      data: (items) {
        if (items.isNotEmpty) {
          final phase = AcnePhase.fromIdOrNull(items.first.checkIn.phase);
          if (phase != null) return '当前阶段 ${phase.label}';
        }
        return '当前状态 ${status.label}';
      },
      orElse: () => '当前状态 ${status.label}',
    );
    final phaseColor = timeline.maybeWhen(
      data: (items) {
        if (items.isNotEmpty) {
          final phase = AcnePhase.fromIdOrNull(items.first.checkIn.phase);
          if (phase != null) return acnePhaseColor(phase);
        }
        return status == SpotStatus.active
            ? AppTheme.accentCoral
            : AppTheme.primaryTeal;
      },
      orElse: () => status == SpotStatus.active
          ? AppTheme.accentCoral
          : AppTheme.primaryTeal,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spotDisplayTitle(spot),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetaChip(
                        icon: Icons.event_outlined,
                        label: '首次记录 ${dateFormat.format(spot.createdAt)}',
                      ),
                      _MetaChip(
                        icon: Icons.fiber_manual_record,
                        label: phaseLabel,
                        iconColor: phaseColor,
                      ),
                      _MetaChip(
                        icon: Icons.trending_up,
                        label: timeline.maybeWhen(
                          data: (items) => items.length > 1
                              ? '总体趋势 好转'
                              : '总体趋势 追踪中',
                          orElse: () => '总体趋势 追踪中',
                        ),
                        iconColor: AppTheme.primaryTeal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => showAddPhotoOptions(context, spot.id),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('添加照片'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '备注日志',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _noteController,
          minLines: 8,
          maxLines: 12,
          decoration: const InputDecoration(
            hintText: '记录这颗痘痘的变化、观察、用药和任何想保留的日志',
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _savingNote ? null : _saveNote,
            child: _savingNote
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存备注'),
          ),
        ),
      ],
    );
  }
}

class _EmptySpotDetail extends StatelessWidget {
  const _EmptySpotDetail();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '还没有选择痘痘',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor ?? AppTheme.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
