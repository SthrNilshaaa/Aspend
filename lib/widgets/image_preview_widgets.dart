import 'dart:io';
import 'package:flutter/material.dart';
import '../const/app_dimensions.dart';

class ImagePreviewWithInteraction extends StatefulWidget {
  final String imagePath;
  const ImagePreviewWithInteraction({super.key, required this.imagePath});

  @override
  State<ImagePreviewWithInteraction> createState() =>
      _ImagePreviewWithInteractionState();
}

class _ImagePreviewWithInteractionState
    extends State<ImagePreviewWithInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) =>
                FullScreenImageDialog(imagePath: widget.imagePath),
          );
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Hero(
            tag: widget.imagePath,
            child: Container(
              margin: const EdgeInsets.only(right: AppDimensions.paddingSmall),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath)),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImageDialog extends StatelessWidget {
  final String imagePath;
  const FullScreenImageDialog({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: imagePath,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close,
                  color: Colors.white, size: AppDimensions.iconSizeXLarge + 2),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
