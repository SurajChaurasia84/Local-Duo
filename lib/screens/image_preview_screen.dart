import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String heroTag;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TransformationController _transformationController = TransformationController();
  double _dragOffset = 0;
  double _dragOpacity = 1.0;
  bool _isDragging = false;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Only allow drag-to-dismiss if current scale is 1.0
    if (_transformationController.value.getMaxScaleOnAxis() > 1.0) return;

    setState(() {
      _isDragging = true;
      _dragOffset += details.primaryDelta!;
      // Prevent dragging upwards
      if (_dragOffset < 0) _dragOffset = 0;
      
      // Calculate opacity based on drag distance (fade out at 200px)
      _dragOpacity = (1 - (_dragOffset / 300)).clamp(0.5, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    if (_dragOffset > 150 || details.primaryVelocity! > 500) {
      // Dismiss the screen
      Navigator.pop(context);
    } else {
      // Snap back to original position
      setState(() {
        _isDragging = false;
        _dragOffset = 0;
        _dragOpacity = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = widget.imagePath.startsWith('http') || widget.imagePath.startsWith('https');

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _dragOpacity),
      body: Stack(
        children: [
          // Main Image Viewer with Drag and Hero Support
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: AnimatedContainer(
                duration: _isDragging ? Duration.zero : const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _dragOffset, 0),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 4.0,
                  boundaryMargin: EdgeInsets.zero,
                  child: Center(
                    child: Hero(
                      tag: widget.heroTag,
                      child: isNetworkImage
                          ? Image.network(
                              widget.imagePath,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 50,
                              ),
                            )
                          : Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Back Button (Fade out during drag)
          if (!_isDragging)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
