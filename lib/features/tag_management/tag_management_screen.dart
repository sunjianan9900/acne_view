import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences/custom_phase_labels.dart';
import '../../core/preferences/custom_treatment_tags.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/acne_phase.dart';
import '../../shared/models/treatment_type.dart';
import '../../shared/widgets/douji_shell.dart';

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DoujiShell(
      title: '标签管理',
      subtitle: '管理痘痘时期与药物/护理快捷标签',
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _PhaseTagsSection(),
          SizedBox(height: 20),
          _MedicationTagsSection(),
        ],
      ),
    );
  }
}

class _PhaseTagsSection extends ConsumerWidget {
  const _PhaseTagsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customLabels = ref.watch(phaseLabelsProvider);

    return _SectionCard(
      title: '痘痘时期',
      subtitle: '自定义各时期的显示名称，打卡与时间线将同步更新',
      icon: Icons.timeline_outlined,
      child: Column(
        children: [
          for (var i = 0; i < AcnePhase.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _PhaseTagRow(
              phase: AcnePhase.values[i],
              displayLabel: phaseDisplayLabel(AcnePhase.values[i], customLabels),
              isCustomized: customLabels.containsKey(AcnePhase.values[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhaseTagRow extends ConsumerWidget {
  const _PhaseTagRow({
    required this.phase,
    required this.displayLabel,
    required this.isCustomized,
  });

  final AcnePhase phase;
  final String displayLabel;
  final bool isCustomized;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = acnePhaseColor(phase);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isCustomized)
                  Text(
                    '默认：${phase.label}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: '编辑名称',
            onPressed: () => _showEditDialog(context, ref),
            icon: const Icon(Icons.edit_outlined, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          if (isCustomized)
            IconButton(
              tooltip: '恢复默认',
              onPressed: () => ref
                  .read(customPhaseLabelsProvider.notifier)
                  .resetLabel(phase.id),
              icon: const Icon(Icons.undo_outlined, size: 18),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: displayLabel);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('编辑「${phase.label}」'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '显示名称',
            hintText: '例如：红肿期、爆发期',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (saved == true && context.mounted) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        await ref
            .read(customPhaseLabelsProvider.notifier)
            .setLabel(phase.id, name);
      }
    }
    controller.dispose();
  }
}

class _MedicationTagsSection extends ConsumerWidget {
  const _MedicationTagsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customTags = ref.watch(customTreatmentTagsProvider).value ?? [];

    return _SectionCard(
      title: '药物 / 护理标签',
      subtitle: '打卡时可快速选用的药物与护理项目',
      icon: Icons.medication_outlined,
      trailing: FilledButton.icon(
        onPressed: () => _showAddTagDialog(context, ref),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('添加标签'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '预设标签',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in commonTreatmentTags)
                _PresetTagChip(label: tag),
            ],
          ),
          if (customTags.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              '自定义标签',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in customTags)
                  _CustomTagChip(
                    label: tag,
                    onDelete: () => ref
                        .read(customTreatmentTagsProvider.notifier)
                        .removeTag(tag),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddTagDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '标签名称',
            hintText: '例如：异维A酸、芦荟胶',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (added == true && context.mounted) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        await ref.read(customTreatmentTagsProvider.notifier).addTag(name);
      }
    }
    controller.dispose();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.softBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.softRose,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppTheme.brandPink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _PresetTagChip extends StatelessWidget {
  const _PresetTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppTheme.panelBorder),
      avatar: Icon(
        Icons.lock_outline,
        size: 14,
        color: AppTheme.textSecondary.withValues(alpha: 0.7),
      ),
    );
  }
}

class _CustomTagChip extends StatelessWidget {
  const _CustomTagChip({required this.label, required this.onDelete});

  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.softRose,
      side: BorderSide(color: AppTheme.brandPink.withValues(alpha: 0.3)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDelete,
      labelStyle: const TextStyle(color: AppTheme.brandPink),
    );
  }
}
