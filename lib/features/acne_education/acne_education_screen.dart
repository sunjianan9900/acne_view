import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/photo/photo_viewer.dart';
import '../../shared/widgets/douji_shell.dart';

/// 科普图原始图片
const _educationImages = <String>[
  'assets/ance/01.jpeg',
  'assets/ance/02.jpeg',
  'assets/ance/03.jpeg',
  'assets/ance/04.jpeg',
  'assets/ance/05.jpeg',
];

class AcneEducationScreen extends StatelessWidget {
  const AcneEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DoujiShell(
      title: '痘痘科普',
      subtitle: '了解不同类型痘痘的特征与护理要点',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _educationImages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final assetPath = _educationImages[index];
          return _EducationImageCard(
            assetPath: assetPath,
            index: index + 1,
            onTap: () => showAssetPhotoViewer(
              context,
              assetPath,
              title: '痘痘科普 ${index + 1}',
              initialIndex: index,
              assetPaths: _educationImages,
            ),
          );
        },
      ),
    );
  }
}

class _EducationImageCard extends StatelessWidget {
  const _EducationImageCard({
    required this.assetPath,
    required this.index,
    required this.onTap,
  });

  final String assetPath;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.panelBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppTheme.textSecondary,
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.zoom_in_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '点击查看',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.softRose,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$index',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.brandPink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '科普图 $index',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
