import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用帮助')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: '关于痘迹',
            content: '痘迹是一款痘痘打卡观察 App，帮助你每天记录痘痘变化，追踪护理措施的效果。',
          ),
          _Section(
            title: '如何使用',
            bullets: [
              '在面部地图上选择区域，创建痘痘点位',
              '每天对同一颗痘痘拍照打卡',
              '记录使用的药物、护肤品和护理措施',
              '在时间线中查看变化趋势',
            ],
          ),
          _Section(
            title: '模拟器说明',
            content:
                'iOS 模拟器无法使用 Mac 上通过 USB 连接的外接显微摄像头（如 WTM-W1-1）。'
                '模拟器只能使用 Mac 内置摄像头进行功能体验。'
                '要测试外接显微摄像头，请使用真机 iPad（USB-C）连接设备后运行 App。',
          ),
          _Section(
            title: '关于外接显微摄像头',
            content:
                'iPhone 受系统限制，无法直连 USB 显微摄像头（如 WTM-W1-1）。'
                '这是 Apple 平台限制，并非 App 缺陷。',
          ),
          _Section(
            title: '显微拍摄方案',
            bullets: [
              '方案 A：使用 iPhone 内置摄像头做日常远距记录',
              '方案 B：使用 iPad（USB-C，iPadOS 17+）连接 WTM-W1-1 做显微级观察',
              '方案 C：使用 MacBook 连接摄像头（macOS 版后续支持）',
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryTeal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '内置摄像头适合日常记录；如需毛孔级观察，请使用 iPad 外接摄像头模式。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.content, this.bullets});

  final String title;
  final String? content;
  final List<String>? bullets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (content != null)
            Text(
              content!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          if (bullets != null)
            ...bullets!.map(
              (b) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        b,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
