import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/preferences/custom_phases.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/spot_display.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/photo/photo_viewer.dart';
import '../check_in/check_in_detail_dialog.dart';

Future<void> showSpotDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required String initialSpotId,
  String? initialCheckInId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (ctx) => SpotDetailDialog(
      initialSpotId: initialSpotId,
      initialCheckInId: initialCheckInId,
    ),
  );
}

class SpotDetailDialog extends ConsumerStatefulWidget {
  const SpotDetailDialog({
    super.key,
    required this.initialSpotId,
    this.initialCheckInId,
  });

  final String initialSpotId;
  final String? initialCheckInId;

  @override
  ConsumerState<SpotDetailDialog> createState() => _SpotDetailDialogState();
}

class _SpotDetailDialogState extends ConsumerState<SpotDetailDialog> {
  String? _currentSpotId;
  String? _currentCheckInId;
  int _pageDirection = 1;

  @override
  void initState() {
    super.initState();
    _currentSpotId = widget.initialSpotId;
    _currentCheckInId = widget.initialCheckInId;
  }

  @override
  void didUpdateWidget(covariant SpotDetailDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSpotId != widget.initialSpotId) {
      _currentSpotId = widget.initialSpotId;
      _currentCheckInId = widget.initialCheckInId;
    } else if (oldWidget.initialCheckInId != widget.initialCheckInId) {
      _currentCheckInId = widget.initialCheckInId;
    }
  }

  AcneSpot? _resolveCurrentSpot(List<AcneSpot> spots) {
    if (spots.isEmpty) return null;
    final currentId = _currentSpotId;
    if (currentId != null) {
      for (final spot in spots) {
        if (spot.id == currentId) return spot;
      }
    }
    return spots.first;
  }

  void _selectCheckIn(String checkInId, {required int direction}) {
    setState(() {
      _currentCheckInId = checkInId;
      _pageDirection = direction;
    });
  }

  int _resolveTimelineIndex(List<SpotCheckInPhoto> items) {
    if (items.isEmpty) return 0;
    final checkInId = _currentCheckInId;
    if (checkInId != null) {
      final index = items.indexWhere((item) => item.checkIn.id == checkInId);
      if (index >= 0) return index;
    }
    return 0;
  }

  SpotCheckInPhoto? _resolveSelectedItem(List<SpotCheckInPhoto> items) {
    if (items.isEmpty) return null;
    final checkInId = _currentCheckInId;
    if (checkInId != null) {
      for (final item in items) {
        if (item.checkIn.id == checkInId) return item;
      }
    }
    return items.first;
  }

  Future<void> _showEditCurrentRecord(AcneSpot spot) async {
    final items = await ref.read(spotTimelineProvider(spot.id).future);
    final selectedItem = _resolveSelectedItem(items);
    if (selectedItem == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('暂无打卡记录可编辑')));
      }
      return;
    }

    if (!mounted) return;

    await showCheckInDetailDialog(
      context,
      ref,
      checkInId: selectedItem.checkIn.id,
      initialEditing: true,
    );
    if (mounted) {
      ref.invalidate(spotTimelineProvider(spot.id));
    }
  }

  Future<void> _deleteCurrentCheckIn(AcneSpot spot) async {
    final items = await ref.read(spotTimelineProvider(spot.id).future);
    final selectedItem = _resolveSelectedItem(items);
    if (selectedItem == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('暂无打卡记录可删除')));
      }
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除打卡记录'),
        content: const Text('将删除该条打卡的照片、用药和备注信息，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final deletedId = selectedItem.checkIn.id;
      await ref.read(checkInRepositoryProvider).deleteCheckIn(deletedId);
      ref.invalidate(spotTimelineProvider(spot.id));
      ref.invalidate(spotThumbnailProvider(spot.id));

      if (!mounted) return;

      final remaining = await ref.read(spotTimelineProvider(spot.id).future);
      if (mounted) {
        setState(() {
          if (_currentCheckInId == deletedId) {
            _currentCheckInId = remaining.isNotEmpty
                ? remaining.first.checkIn.id
                : null;
          }
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('记录已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotsAsync = ref.watch(allSpotsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: spotsAsync.when(
        data: (spots) {
          final current = _resolveCurrentSpot(spots);
          if (current == null) {
            return _buildEmptyState(context);
          }
          if (_currentSpotId != current.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _currentSpotId = current.id);
              }
            });
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1520, maxHeight: 900),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFDFBFC),
                    Color(0xFFF8F4F3),
                    Color(0xFFFFF7F8),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 40,
                    offset: Offset(0, 24),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 22, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, current),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 1100;
                          final content = _buildBody(context, current);
                          if (isWide) return content;
                          return SingleChildScrollView(child: content);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 520,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => SizedBox(
          width: 520,
          height: 320,
          child: _buildErrorState(context, e.toString()),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: 520,
      height: 320,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text('暂无痘痘记录', style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text('加载失败: $message'),
    );
  }

  Widget _buildHeader(BuildContext context, AcneSpot spot) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '痘痘详情',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
        ),
        _TopActionButton(
          icon: Icons.delete_outline_rounded,
          label: '删除',
          color: Colors.red,
          onPressed: () => _deleteCurrentCheckIn(spot),
        ),
        const SizedBox(width: 12),
        _TopActionButton(
          icon: Icons.edit_outlined,
          label: '编辑',
          color: AppTheme.primaryTeal,
          onPressed: () => _showEditCurrentRecord(spot),
        ),
        const SizedBox(width: 12),
        _RoundIconButton(
          icon: Icons.close_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AcneSpot spot) {
    final timelineAsync = ref.watch(spotTimelineProvider(spot.id));

    return timelineAsync.when(
      data: (items) {
        final selectedItem = _resolveSelectedItem(items);
        final currentIndex = _resolveTimelineIndex(items);

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
              if (currentIndex > 0) {
                _selectCheckIn(
                  items[currentIndex - 1].checkIn.id,
                  direction: -1,
                );
              }
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight): () {
              if (currentIndex < items.length - 1) {
                _selectCheckIn(
                  items[currentIndex + 1].checkIn.id,
                  direction: 1,
                );
              }
            },
            const SingleActivator(LogicalKeyboardKey.space): () {
              final filePath = selectedItem?.photo?.filePath;
              if (filePath == null) return;
              showPhotoViewer(context, filePath);
            },
          },
          child: Focus(
            autofocus: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 62,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _HeroPhotoPanel(
                                spot: spot,
                                selectedItem: selectedItem,
                                onPrevious: currentIndex > 0
                                    ? () => _selectCheckIn(
                                        items[currentIndex - 1].checkIn.id,
                                        direction: -1,
                                      )
                                    : null,
                                onNext: currentIndex < items.length - 1
                                    ? () => _selectCheckIn(
                                        items[currentIndex + 1].checkIn.id,
                                        direction: 1,
                                      )
                                    : null,
                                onOpenImage: () {
                                  final filePath =
                                      selectedItem?.photo?.filePath;
                                  if (filePath == null) return;
                                  showPhotoViewer(context, filePath);
                                },
                                direction: _pageDirection,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _TimelineStrip(
                              items: items,
                              currentIndex: currentIndex,
                              onPrevious: currentIndex > 0
                                  ? () => _selectCheckIn(
                                      items[currentIndex - 1].checkIn.id,
                                      direction: -1,
                                    )
                                  : null,
                              onNext: currentIndex < items.length - 1
                                  ? () => _selectCheckIn(
                                      items[currentIndex + 1].checkIn.id,
                                      direction: 1,
                                    )
                                  : null,
                              onItemTap: (checkInId, index) {
                                _selectCheckIn(
                                  checkInId,
                                  direction: index > currentIndex ? 1 : -1,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        flex: 38,
                        child: _DetailStack(
                          spot: spot,
                          selectedItem: selectedItem,
                          onEditRecord: () => _showEditCurrentRecord(spot),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
    );
  }
}

class _HeroPhotoPanel extends StatelessWidget {
  const _HeroPhotoPanel({
    required this.spot,
    required this.selectedItem,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenImage,
    required this.direction,
  });

  final AcneSpot spot;
  final SpotCheckInPhoto? selectedItem;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onOpenImage;
  final int direction;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, animation) {
        final offsetTween = Tween<Offset>(
          begin: Offset(0.04 * direction, 0),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetTween.animate(animation),
            child: child,
          ),
        );
      },
      child: _HeroPhotoContent(
        key: ValueKey('${spot.id}-${selectedItem?.checkIn.id ?? 'latest'}'),
        spot: spot,
        selectedItem: selectedItem,
        onPrevious: onPrevious,
        onNext: onNext,
        onOpenImage: onOpenImage,
      ),
    );
  }
}

class _HeroPhotoContent extends StatelessWidget {
  const _HeroPhotoContent({
    super.key,
    required this.spot,
    required this.selectedItem,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenImage,
  });

  final AcneSpot spot;
  final SpotCheckInPhoto? selectedItem;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onOpenImage;

  @override
  Widget build(BuildContext context) {
    final status = SpotStatus.fromId(spot.status);
    final phaseId = selectedItem?.checkIn.phase ?? '';
    final photoPath = selectedItem?.photo?.filePath;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.panelBorder),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: photoPath != null && File(photoPath).existsSync()
                    ? Image.file(
                        File(photoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _heroPlaceholder(context),
                      )
                    : _heroPlaceholder(context),
              ),
            ),
            Positioned(
              left: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: _FloatingArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onPressed: onPrevious,
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: _FloatingArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onPressed: onNext,
                ),
              ),
            ),
            Positioned(left: 18, top: 18, child: _StatusPill(status: status)),
            Positioned(left: 18, top: 66, child: _PhasePill(phaseId: phaseId)),
            Positioned(
              right: 18,
              bottom: 18,
              child: _ZoomButton(onPressed: onOpenImage),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: _CaptionChip(
                text: '${spotRegionLabel(spot)} · ${spotDisplayTitle(spot)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPlaceholder(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F6F5), Color(0xFFFCEEEF)],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 54,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            '暂无照片',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TimelineStrip extends StatelessWidget {
  const _TimelineStrip({
    required this.items,
    required this.currentIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onItemTap,
  });

  final List<SpotCheckInPhoto> items;
  final int currentIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(String checkInId, int index) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Row(
        children: [
          _StripArrow(onPressed: onPrevious, icon: Icons.chevron_left_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 142,
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        '暂无打卡记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _TimelineStripTile(
                          item: item,
                          selected: index == currentIndex,
                          onTap: () => onItemTap(item.checkIn.id, index),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 12),
          _StripArrow(onPressed: onNext, icon: Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _TimelineStripTile extends StatelessWidget {
  const _TimelineStripTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final SpotCheckInPhoto item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM-dd HH:mm');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 132,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.softRose.withValues(alpha: 0.78)
              : const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppTheme.primaryTeal.withValues(alpha: 0.65)
                : AppTheme.panelBorder,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _SpotPreviewPhoto(photoPath: item.photo?.filePath),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(item.checkIn.checkInDate),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotPreviewPhoto extends StatelessWidget {
  const _SpotPreviewPhoto({this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    if (photoPath != null && File(photoPath!).existsSync()) {
      return Image.file(File(photoPath!), fit: BoxFit.cover);
    }
    return Container(
      color: AppTheme.softRose,
      alignment: Alignment.center,
      child: Icon(
        Icons.face_retouching_natural_rounded,
        color: AppTheme.brandPink.withValues(alpha: 0.74),
        size: 28,
      ),
    );
  }
}

class _DetailStack extends ConsumerWidget {
  const _DetailStack({
    required this.spot,
    required this.selectedItem,
    required this.onEditRecord,
  });

  final AcneSpot spot;
  final SpotCheckInPhoto? selectedItem;
  final VoidCallback onEditRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = SpotStatus.fromId(spot.status);
    final allPhases = ref.watch(allPhasesProvider);
    final phaseInfo = selectedItem != null
        ? findPhaseInfo(selectedItem!.checkIn.phase, allPhases)
        : null;
    final recordDate = selectedItem?.checkIn.checkInDate ?? spot.createdAt;
    final note = selectedItem?.checkIn.note.trim() ?? '';
    final medication = _medicationText(selectedItem);
    final fallback = _fallbackPhaseInfo(status, allPhases);
    final displayPhase = phaseInfo ?? fallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          icon: Icons.event_note_rounded,
          title: '记录时间',
          child: Text(
            DateFormat('yyyy-MM-dd HH:mm').format(recordDate),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.sick_outlined,
          title: '痘痘阶段',
          badge: phaseInfo?.label ?? status.label,
          badgeColor:
              phaseInfo?.color ??
              (status == SpotStatus.active
                  ? AppTheme.accentCoral
                  : AppTheme.primaryTeal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _phaseDescription(displayPhase),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: AppTheme.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.notes_rounded,
          title: '备注',
          actionLabel: '编辑',
          onAction: onEditRecord,
          child: Text(
            note.isEmpty ? '无' : note,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: note.isEmpty
                  ? AppTheme.textSecondary
                  : AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.medication_outlined,
          title: '用药记录',
          accentColor: AppTheme.primaryTeal,
          child: _CalloutBox(text: medication),
        ),
        const SizedBox(height: 14),
        _TipCard(title: '温馨提示', text: _tipForPhase(displayPhase)),
      ],
    );
  }

  String _medicationText(SpotCheckInPhoto? latest) {
    if (latest == null) return '暂无用药记录';
    final medications = latest.treatments
        .where((t) => TreatmentType.fromId(t.type) == TreatmentType.medication)
        .map((t) => t.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (medications.isEmpty) return '暂无用药记录';
    return medications.join(' · ');
  }

  PhaseInfo _fallbackPhaseInfo(SpotStatus status, List<PhaseInfo> allPhases) {
    final fallbackId = status == SpotStatus.active
        ? AcnePhase.inflammatory.id
        : AcnePhase.repairing.id;
    return findPhaseInfo(fallbackId, allPhases) ?? allPhases.first;
  }

  String _phaseDescription(PhaseInfo phase) {
    final builtin = phase.builtinPhase;
    if (builtin == null) {
      return '当前处于「${phase.label}」阶段，建议持续记录皮肤变化并坚持温和护理。';
    }
    return switch (builtin) {
      AcnePhase.mildComedone =>
        '皮肤表面出现轻微粉刺，尚未明显红肿，重点是保持清洁，避免过度护肤刺激。',
      AcnePhase.closedComedone =>
        '闭口粉刺已形成，毛孔堵塞但未发炎，建议温和去角质，不要用手挤压。',
      AcnePhase.inflammatory =>
        '痘痘进入炎症阶段，局部可能出现发红发热，需减少摩擦并注意观察变化。',
      AcnePhase.swollen =>
        '红肿明显，可能伴有疼痛或触痛，建议避免挤压，注意消炎护理。',
      AcnePhase.pustule =>
        '脓包已形成，炎症较为明显，切勿自行挑破，保持创面清洁防止感染。',
      AcnePhase.broken =>
        '痘痘已破损，皮肤屏障受损，重点是防感染与温和修护，避免化妆遮盖刺激。',
      AcnePhase.receding =>
        '正在逐步消退，红肿减轻，保持温和护理并持续记录变化，有助于观察恢复趋势。',
      AcnePhase.repairing =>
        '处于修复阶段，重点是舒缓修护与防晒保湿，帮助皮肤恢复健康状态。',
    };
  }

  String _tipForPhase(PhaseInfo phase) {
    final builtin = phase.builtinPhase;
    if (builtin == null) {
      return '保持皮肤清洁与规律作息，持续记录有助于观察恢复趋势。';
    }
    return switch (builtin) {
      AcnePhase.mildComedone =>
        '使用温和洁面产品，控制油脂分泌，少吃高糖高脂食物有助于预防加重。',
      AcnePhase.closedComedone =>
        '可适当使用含水杨酸或果酸的护肤品，循序渐进，避免一次性高强度处理。',
      AcnePhase.inflammatory =>
        '继续观察红肿范围，减少外部摩擦，保持作息稳定更有利于恢复。',
      AcnePhase.swollen =>
        '保持皮肤清洁，避免辛辣刺激食物和熬夜，多喝水有助于皮肤恢复。',
      AcnePhase.pustule =>
        '不要自行挤脓，可使用干净医用棉签轻柔处理，并遵医嘱使用外用药物。',
      AcnePhase.broken =>
        '破损处保持干燥清洁，暂停刺激性护肤品，可考虑使用修复类乳液加速愈合。',
      AcnePhase.receding =>
        '消退期也要坚持记录，后续对比会更清楚地看到变化轨迹。',
      AcnePhase.repairing =>
        '加强防晒与保湿，避免在修复期使用强效焕肤产品，给皮肤足够恢复时间。',
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.badge,
    this.badgeColor,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final String? badge;
  final Color? badgeColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primaryTeal;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.panelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CardIcon(icon: icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge != null)
                _Badge(text: badge!, color: badgeColor ?? color),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
          if (child is! SizedBox) ...[const SizedBox(height: 14), child],
        ],
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalloutBox extends StatelessWidget {
  const _CalloutBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF6F1), Color(0xFFF8FFFD)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppTheme.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingArrowButton extends StatelessWidget {
  const _FloatingArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: onPressed == null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: onPressed == null ? 0.28 : 1,
        child: Material(
          color: Colors.black.withValues(alpha: 0.22),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _StripArrow extends StatelessWidget {
  const _StripArrow({required this.onPressed, required this.icon});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryTeal,
        disabledBackgroundColor: Colors.white,
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: AppTheme.panelBorder),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SpotStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == SpotStatus.active
        ? AppTheme.accentCoral
        : AppTheme.primaryTeal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PhasePill extends ConsumerWidget {
  const _PhasePill({required this.phaseId});

  final String phaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (phaseId.isEmpty) return const SizedBox.shrink();
    final allPhases = ref.watch(allPhasesProvider);
    final phase = findPhaseInfo(phaseId, allPhases);
    if (phase == null) return const SizedBox.shrink();
    final color = phase.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        phase.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CaptionChip extends StatelessWidget {
  const _CaptionChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: const Icon(Icons.zoom_in_rounded, size: 18),
      label: const Text('点击放大'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
