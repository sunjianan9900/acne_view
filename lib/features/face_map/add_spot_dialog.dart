import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repositories.dart';
import '../../shared/models/face_region.dart';

/// 以 macOS 风格弹窗新增痘痘，返回新建记录的 ID；取消时返回 null。
Future<String?> showAddSpotDialog(
  BuildContext context,
  WidgetRef ref, {
  FaceRegion? initialRegion,
}) {
  return showDialog<String?>(
    context: context,
    builder: (ctx) => AddSpotDialog(initialRegion: initialRegion),
  );
}

class AddSpotDialog extends ConsumerStatefulWidget {
  const AddSpotDialog({super.key, this.initialRegion});

  final FaceRegion? initialRegion;

  @override
  ConsumerState<AddSpotDialog> createState() => _AddSpotDialogState();
}

class _AddSpotDialogState extends ConsumerState<AddSpotDialog> {
  late FaceRegion _selected;
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialRegion ?? FaceRegion.forehead;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      final spotId = await ref
          .read(spotRepositoryProvider)
          .createSpot(region: _selected, note: _noteController.text);
      if (mounted) {
        Navigator.of(context).pop(spotId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '新增痘痘',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<FaceRegion>(
                initialValue: _selected,
                decoration: const InputDecoration(labelText: '面部区域'),
                items: FaceRegion.values
                    .map(
                      (r) => DropdownMenuItem(value: r, child: Text(r.label)),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (v) {
                        if (v != null) setState(() => _selected = v);
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                  hintText: '例如：红肿型',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _create,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('创建'),
                    ),
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
