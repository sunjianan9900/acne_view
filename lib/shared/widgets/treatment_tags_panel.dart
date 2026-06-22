import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences/custom_treatment_tags.dart';
import '../../core/theme/app_theme.dart';

class TreatmentTagsPanel extends ConsumerWidget {
  const TreatmentTagsPanel({super.key, required this.onTagSelected});

  final ValueChanged<String> onTagSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(allTreatmentTagsProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          ActionChip(
            label: Text(tag),
            onPressed: () => onTagSelected(tag),
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppTheme.panelBorder),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 16, color: AppTheme.brandPink),
          label: const Text('自定义'),
          onPressed: () => _showAddCustomTagDialog(context, ref),
          backgroundColor: AppTheme.softRose,
          side: BorderSide(color: AppTheme.brandPink.withValues(alpha: 0.3)),
          labelStyle: const TextStyle(color: AppTheme.brandPink),
        ),
      ],
    );
  }

  Future<void> _showAddCustomTagDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加护理项目'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '项目名称',
            hintText: '例如：痘痘贴、芦荟胶',
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
        if (context.mounted) onTagSelected(name);
      }
    }
    controller.dispose();
  }
}
