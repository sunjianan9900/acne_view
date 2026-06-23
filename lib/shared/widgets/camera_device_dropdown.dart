import 'package:flutter/material.dart';

import '../../core/camera/camera_service.dart';
import '../../core/theme/app_theme.dart';

/// 摄像头设备下拉选择器，用于拍照/预览界面切换摄像头。
class CameraDeviceDropdown extends StatelessWidget {
  const CameraDeviceDropdown({
    super.key,
    required this.devices,
    required this.selectedId,
    required this.onChanged,
    this.enabled = true,
    this.darkStyle = false,
  });

  final List<CameraDeviceInfo> devices;
  final String? selectedId;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool darkStyle;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveId = selectedId != null && devices.any((d) => d.id == selectedId)
        ? selectedId
        : devices.first.id;

    final textColor = darkStyle ? Colors.white : AppTheme.textPrimary;
    final hintColor = darkStyle ? Colors.white70 : AppTheme.textSecondary;
    final borderColor = darkStyle ? Colors.white38 : AppTheme.panelBorder;
    final fillColor = darkStyle
        ? Colors.white.withValues(alpha: 0.08)
        : AppTheme.softBackground;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: effectiveId,
            isExpanded: true,
            icon: Icon(Icons.expand_more, color: hintColor, size: 20),
            dropdownColor: darkStyle ? const Color(0xFF1E1E1E) : Colors.white,
            style: TextStyle(color: textColor, fontSize: 14),
            items: devices
                .map(
                  (device) => DropdownMenuItem<String>(
                    value: device.id,
                    child: Row(
                      children: [
                        Icon(
                          device.isExternal
                              ? Icons.videocam_outlined
                              : Icons.camera_alt_outlined,
                          size: 16,
                          color: hintColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            device.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: enabled && devices.length > 1
                ? (id) {
                    if (id != null) onChanged?.call(id);
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
