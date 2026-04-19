import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'preview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
      cameras.first,
      ResolutionPreset.max,
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
          builder: (context) => ProImageEditor.file(
            File(image.path),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                final tempDir = await getTemporaryDirectory();
                final editedFile = File('${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
                await editedFile.writeAsBytes(bytes);
                
                if (!mounted) return;
                
                // Go to PreviewScreen with edited image
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(imagePath: editedFile.path),
                  ),
                );
              },
            ),
            configs: const ProImageEditorConfigs(
              designMode: ImageEditorDesignMode.material,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isInitializing || !_isPermissionGranted || _controller == null || !_controller!.value.isInitialized
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.large(
                onPressed: _takePicture,
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 36),
              ),
            ),
    );
  }

  Widget _buildBody() {
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
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  var scale = _controller!.value.aspectRatio * size.aspectRatio;

                  // to prevent scaling down, use max(1, 1 / scale)
                  if (scale < 1) scale = 1 / scale;

                  return Transform.scale(
                    scale: scale,
                    child: Center(
                      child: CameraPreview(_controller!),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'Camera Access Required',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'To report issues, you need to allow Jan Report to use your camera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('GRANT ACCESS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.no_photography_outlined, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Camera Found',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'We couldn\'t detect a camera on this device. You can use a demo image to test the reporting flow.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreviewScreen(
                        imagePath: 'https://images.unsplash.com/photo-1542601906990-b4d3fb773b09?w=800',
                        isMock: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('USE DEMO IMAGE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
