import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showPhotoViewer(BuildContext context, String filePath) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => PhotoViewerScreen(filePath: filePath),
    ),
  );
}

Future<void> showAssetPhotoViewer(
  BuildContext context,
  String assetPath, {
  String? title,
  List<String>? assetPaths,
  int? initialIndex,
}) {
  final paths = assetPaths ?? <String>[assetPath];
  final index = initialIndex ?? paths.indexOf(assetPath);

  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AssetPhotoViewerScreen(
        assetPaths: paths,
        initialIndex: index < 0 ? 0 : index,
        title: title,
      ),
    ),
  );
}

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          Navigator.of(context).pop();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('照片详情'),
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: Image.file(
                File(filePath),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AssetPhotoViewerScreen extends StatefulWidget {
  const AssetPhotoViewerScreen({
    super.key,
    required this.assetPaths,
    required this.initialIndex,
    this.title,
  });

  final List<String> assetPaths;
  final int initialIndex;
  final String? title;

  @override
  State<AssetPhotoViewerScreen> createState() => _AssetPhotoViewerScreenState();
}

class _AssetPhotoViewerScreenState extends State<AssetPhotoViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.assetPaths.length > 1;
    final title = widget.title ?? '图片详情';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(hasMultiple ? '$title (${_currentIndex + 1}/${widget.assetPaths.length})' : title),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.assetPaths.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: Image.asset(
                widget.assetPaths[index],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
