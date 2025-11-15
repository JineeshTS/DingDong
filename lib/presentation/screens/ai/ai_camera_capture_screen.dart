import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/theme/design_system.dart';
import '../../../domain/entities/ai_extraction_result.dart';
import '../../common/widgets/widgets.dart';

/// AI Camera Capture Screen
///
/// Flagship feature screen for capturing images to extract tasks
class AiCameraCaptureScreen extends ConsumerStatefulWidget {
  const AiCameraCaptureScreen({super.key});

  @override
  ConsumerState<AiCameraCaptureScreen> createState() =>
      _AiCameraCaptureScreenState();
}

class _AiCameraCaptureScreenState
    extends ConsumerState<AiCameraCaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  ExtractionMode _selectedMode = ExtractionMode.auto;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera found on this device')),
          );
        }
        return;
      }

      final camera = cameras.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _cameraController!.takePicture();

      if (!mounted) return;

      // Navigate to review screen
      context.push(
        '/ai-review',
        extra: {
          'imagePath': image.path,
          'mode': _selectedMode,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      if (!mounted) return;

      // Navigate to review screen
      context.push(
        '/ai-review',
        extra: {
          'imagePath': image.path,
          'mode': _selectedMode,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Task Capture'),
        subtitle: const Text('Capture tasks from images'),
        actions: [
          AppIconButton(
            icon: Icons.photo_library,
            onPressed: _pickFromGallery,
            tooltip: 'Choose from gallery',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode selector
          _buildModeSelector(),

          // Camera preview
          Expanded(
            child: _buildCameraPreview(),
          ),

          // Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: AppSpacing.pagePadding,
      color: AppColors.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extraction Mode',
            style: AppTypography.labelMedium,
          ),
          AppSpacing.verticalSpaceXS,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ExtractionMode.values.map((mode) {
                final isSelected = mode == _selectedMode;
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: Text(mode.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMode = mode);
                      }
                    },
                    backgroundColor: AppColors.gray100,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.gray700,
                      fontWeight: isSelected
                          ? AppTypography.semiBold
                          : AppTypography.regular,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_selectedMode != ExtractionMode.auto) ...[
            AppSpacing.verticalSpaceXS,
            Text(
              _selectedMode.description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),

        // Overlay guides
        CustomPaint(
          painter: _CameraGuidePainter(),
        ),

        // Tips
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keep text clear and well-lit for best results',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        color: AppColors.gray900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            IconButton(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library, size: 32),
              color: Colors.white,
            ),

            // Capture button
            GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: _isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),

            // Placeholder for symmetry
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

/// Camera guide painter for overlay
class _CameraGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw corner guides
    const cornerLength = 30.0;
    const margin = 40.0;

    // Top-left
    canvas
      ..drawLine(
        const Offset(margin, margin),
        const Offset(margin + cornerLength, margin),
        paint,
      )
      ..drawLine(
        const Offset(margin, margin),
        const Offset(margin, margin + cornerLength),
        paint,
      );

    // Top-right
    canvas
      ..drawLine(
        Offset(size.width - margin, margin),
        Offset(size.width - margin - cornerLength, margin),
        paint,
      )
      ..drawLine(
        Offset(size.width - margin, margin),
        Offset(size.width - margin, margin + cornerLength),
        paint,
      );

    // Bottom-left
    canvas
      ..drawLine(
        Offset(margin, size.height - margin),
        Offset(margin + cornerLength, size.height - margin),
        paint,
      )
      ..drawLine(
        Offset(margin, size.height - margin),
        Offset(margin, size.height - margin - cornerLength),
        paint,
      );

    // Bottom-right
    canvas
      ..drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin - cornerLength, size.height - margin),
        paint,
      )
      ..drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin, size.height - margin - cornerLength),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
