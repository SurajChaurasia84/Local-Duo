import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart'; // To access the global cameras list
import 'preview_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  CameraController? _controller;
  bool _isPermissionGranted = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _isPermissionGranted = true);
      _initializeCamera();
    } else {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() => _isInitializing = false);
      return;
    }

    _controller = CameraController(
      cameras.first, // Use back camera
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }

    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isPermissionGranted) {
      return _buildPermissionDenied();
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return _buildCameraFallback();
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),

        // Overlay & Capture Button
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Guidance Text
        const Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Align the issue in frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 10, color: Colors.black)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Camera access is required to report issues.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text('Grant Access'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFallback() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'No camera found on this device or emulator.',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          // Mock capture button for testing on emulators
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreviewScreen(
                    imagePath: 'https://images.unsplash.com/photo-1542601906990-b4d3fb773b09?w=800',
                    isMock: true,
                  ),
                ),
              );
            },
            child: const Text('Use Mock Image (Demo)'),
          ),
        ],
      ),
    );
  }
}
