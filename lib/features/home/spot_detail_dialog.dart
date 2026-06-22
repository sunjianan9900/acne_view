import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/preferences/custom_phase_labels.dart';
import '../../core/providers/repositories.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/spot_display.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/photo/photo_viewer.dart';

Future<void> showSpotDetailDialog(
  BuildContext context,
  WidgetRef ref, {
  required String initialSpotId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (ctx) => SpotDetailDialog(initialSpotId: initialSpotId),
  );
}

class SpotDetailDialog extends ConsumerStatefulWidget {
  const SpotDetailDialog({super.key, required this.initialSpotId});

  final String initialSpotId;

  @override
  ConsumerState<SpotDetailDialog> createState() => _SpotDetailDialogState();
}

class _SpotDetailDialogState extends ConsumerState<SpotDetailDialog> {
  String? _currentSpotId;
  int _pageDirection = 1;

  @override
  void initState() {
    super.initState();
    _currentSpotId = widget.initialSpotId;
  }

  @override
  void didUpdateWidget(covariant SpotDetailDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSpotId != widget.initialSpotId) {
      _currentSpotId = widget.initialSpotId;
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

  int _resolveIndex(List<AcneSpot> spots) {
    final currentId = _currentSpotId;
    if (currentId == null) return 0;
    final index = spots.indexWhere((spot) => spot.id == currentId);
    return index >= 0 ? index : 0;
  }

  void _selectSpot(String spotId, {required int direction}) {
    setState(() {
      _currentSpotId = spotId;
      _pageDirection = direction;
    });
  }

  void _showEditNoteDialog(AcneSpot spot) {
    final controller = TextEditingController(text: spot.note);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑备注'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '记录这颗痘痘的变化、观察、用药和任何想保留的日志',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveNote(spot.id, controller.text);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _saveNote(String spotId, String note) async {
    try {
      await ref.read(spotRepositoryProvider).updateSpotNote(spotId, note.trim());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('备注已保存')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  Future<void> _deleteCurrentSpot(AcneSpot spot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除痘痘'),
        content: const Text('将删除该痘痘的所有记录和照片，此操作不可撤销。'),
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
      await ref.read(spotRepositoryProvider).deleteSpot(spot.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('痘痘已删除')));
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
          final resolvedIndex = _resolveIndex(spots);
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
                          final content = _buildBody(
                            context,
                            current,
                            spots,
                            resolvedIndex,
                          );
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
      child: Text(
        '暂无痘痘记录',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
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
          onPressed: () => _deleteCurrentSpot(spot),
        ),
        const SizedBox(width: 12),
        _TopActionButton(
          icon: Icons.edit_outlined,
          label: '编辑',
          color: AppTheme.primaryTeal,
          onPressed: () => _showEditNoteDialog(spot),
        ),
        const SizedBox(width: 12),
        _RoundIconButton(
          icon: Icons.close_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    AcneSpot spot,
    List<AcneSpot> spots,
    int currentIndex,
  ) {
    final photoAsync = ref.watch(spotThumbnailProvider(spot.id));
    final timelineAsync = ref.watch(spotTimelineProvider(spot.id));

    return Column(
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
                        photoAsync: photoAsync,
                        timelineAsync: timelineAsync,
                        onPrevious: currentIndex > 0
                            ? () => _selectSpot(
                                spots[currentIndex - 1].id,
                                direction: -1,
                              )
                            : null,
                        onNext: currentIndex < spots.length - 1
                            ? () => _selectSpot(
                                spots[currentIndex + 1].id,
                                direction: 1,
                              )
                            : null,
                        onOpenImage: () {
                          final filePath = photoAsync.valueOrNull?.filePath;
                          if (filePath == null) return;
                          showPhotoViewer(context, filePath);
                        },
                        direction: _pageDirection,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SpotStrip(
                      spots: spots,
                      currentIndex: currentIndex,
                      onPrevious: currentIndex > 0
                          ? () => _selectSpot(
                              spots[currentIndex - 1].id,
                              direction: -1,
                            )
                          : null,
                      onNext: currentIndex < spots.length - 1
                          ? () => _selectSpot(
                              spots[currentIndex + 1].id,
                              direction: 1,
                            )
                          : null,
                      onSpotTap: (spotId, index) {
                        _selectSpot(
                          spotId,
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
                  timelineAsync: timelineAsync,
                  onEditNote: () => _showEditNoteDialog(spot),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroPhotoPanel extends StatelessWidget {
  const _HeroPhotoPanel({
    required this.spot,
    required this.photoAsync,
    required this.timelineAsync,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenImage,
    required this.direction,
  });

  final AcneSpot spot;
  final AsyncValue<Photo?> photoAsync;
  final AsyncValue<List<SpotCheckInPhoto>> timelineAsync;
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
        key: ValueKey(spot.id),
        spot: spot,
        photoAsync: photoAsync,
        timelineAsync: timelineAsync,
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
    required this.photoAsync,
    required this.timelineAsync,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenImage,
  });

  final AcneSpot spot;
  final AsyncValue<Photo?> photoAsync;
  final AsyncValue<List<SpotCheckInPhoto>> timelineAsync;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onOpenImage;

  @override
  Widget build(BuildContext context) {
    final status = SpotStatus.fromId(spot.status);
    final latest = timelineAsync.valueOrNull?.isNotEmpty == true
        ? timelineAsync.valueOrNull!.first
        : null;
    final phase = latest != null
        ? AcnePhase.fromIdOrNull(latest.checkIn.phase)
        : null;
    final photoPath = photoAsync.valueOrNull?.filePath;

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
            Positioned(
              left: 18,
              top: 18,
              child: _StatusPill(status: status),
            ),
            Positioned(
              left: 18,
              top: 66,
              child: _PhasePill(phase: phase),
            ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotStrip extends StatelessWidget {
  const _SpotStrip({
    required this.spots,
    required this.currentIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onSpotTap,
  });

  final List<AcneSpot> spots;
  final int currentIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final void Function(String spotId, int index) onSpotTap;

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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: spots.length,
                separatorBuilder: (context, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final spot = spots[index];
                  return _SpotStripTile(
                    spot: spot,
                    selected: index == currentIndex,
                    onTap: () => onSpotTap(spot.id, index),
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

class _SpotStripTile extends ConsumerWidget {
  const _SpotStripTile({
    required this.spot,
    required this.selected,
    required this.onTap,
  });

  final AcneSpot spot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailAsync = ref.watch(spotThumbnailProvider(spot.id));
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
                child: thumbnailAsync.when(
                  data: (photo) => _SpotPreviewPhoto(photoPath: photo?.filePath),
                  loading: () => const _SpotPreviewPhoto(),
                  error: (error, stackTrace) => const _SpotPreviewPhoto(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateFormat.format(spot.createdAt),
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
    required this.timelineAsync,
    required this.onEditNote,
  });

  final AcneSpot spot;
  final AsyncValue<List<SpotCheckInPhoto>> timelineAsync;
  final VoidCallback onEditNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = SpotStatus.fromId(spot.status);
    final phaseLabels = ref.watch(phaseLabelsProvider);
    final latest = timelineAsync.valueOrNull?.isNotEmpty == true
        ? timelineAsync.valueOrNull!.first
        : null;
    final phase = latest != null
        ? AcnePhase.fromIdOrNull(latest.checkIn.phase)
        : null;
    final latestDate = latest?.checkIn.checkInDate ?? spot.createdAt;
    final note = spot.note.trim();
    final medication = _medicationText(latest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(
          icon: Icons.event_note_rounded,
          title: '记录时间',
          child: Text(
            DateFormat('yyyy-MM-dd HH:mm').format(latestDate),
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
          badge: phase != null
              ? phaseDisplayLabel(phase, phaseLabels)
              : status.label,
          badgeColor: phase != null
              ? acnePhaseColor(phase)
              : (status == SpotStatus.active
                    ? AppTheme.accentCoral
                    : AppTheme.primaryTeal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _phaseDescription(phase ?? _fallbackPhase(status)),
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
          onAction: onEditNote,
          child: Text(
            note.isEmpty ? '无' : note,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: note.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
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
        _TipCard(
          title: '温馨提示',
          text: _tipForPhase(phase ?? _fallbackPhase(status)),
        ),
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

  AcnePhase _fallbackPhase(SpotStatus status) {
    return status == SpotStatus.active ? AcnePhase.swollen : AcnePhase.receding;
  }

  String _phaseDescription(AcnePhase phase) {
    return switch (phase) {
      AcnePhase.swollen =>
        '红肿明显，可能伴有疼痛或触痛，建议避免挤压，注意消炎护理。',
      AcnePhase.inflammatory =>
        '炎症仍在恢复中，建议继续观察皮肤状态，减少刺激和摩擦。',
      AcnePhase.stable =>
        '状态相对稳定，重点是维持清洁和规律护理，避免反复刺激。',
      AcnePhase.receding =>
        '正在逐步消退，保持温和护理并持续记录变化，有助于观察恢复趋势。',
    };
  }

  String _tipForPhase(AcnePhase phase) {
    return switch (phase) {
      AcnePhase.swollen =>
        '保持皮肤清洁，避免辛辣刺激食物和熬夜，多喝水有助于皮肤恢复。',
      AcnePhase.inflammatory =>
        '继续观察红肿范围，减少外部摩擦，保持作息稳定更有利于恢复。',
      AcnePhase.stable =>
        '维持当前护理节奏，按需补充保湿与防晒，防止状态再次波动。',
      AcnePhase.receding =>
        '恢复期也要坚持记录，后续对比会更清楚地看到变化轨迹。',
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
              if (badge != null) _Badge(text: badge!, color: badgeColor ?? color),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
          if (child is! SizedBox) ...[
            const SizedBox(height: 14),
            child,
          ],
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
              Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryTeal),
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
        textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
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
  const _PhasePill({required this.phase});

  final AcnePhase? phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (phase == null) return const SizedBox.shrink();
    final phaseLabels = ref.watch(phaseLabelsProvider);
    final color = acnePhaseColor(phase!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        phaseDisplayLabel(phase!, phaseLabels),
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
