import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/custom_app_bar.dart';
import '../utils/logger.dart';
import 'loading_screen.dart';
import 'result_screen.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isDisposed = false;
  File? _lastCapturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _disposeCamera() async {
    if (_controller != null) {
      Logger.camera('Disposing camera controller');
      await _controller!.dispose();
      _controller = null;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    Logger.info('Disposing CameraCapturePage');
    _isDisposed = true;
    _disposeCamera();
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Clean up any captured images
    if (_lastCapturedImage != null) {
      try {
        if (_lastCapturedImage!.existsSync()) {
          _lastCapturedImage!.deleteSync();
          Logger.image('Deleted captured image: ${_lastCapturedImage!.path}');
        }
      } catch (e) {
        Logger.error('Error deleting captured image', error: e);
      }
    }
    
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed) return;
    
    try {
      Logger.camera('Initializing camera');
      // Dispose existing controller if any
      await _disposeCamera();
      
      cameras = await availableCameras();
      if (cameras.isEmpty || _isDisposed) {
        Logger.warning('No cameras available or screen disposed');
        return;
      }
      
      _controller = CameraController(
        cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isCameraInitialized = true;
        });
        Logger.camera('Camera initialized successfully');
      }
    } catch (e) {
      Logger.error('Error initializing camera', error: e);
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_isCameraInitialized || _isDisposed) return;

    try {
      Logger.camera('Capturing image');
      // Capture the image
      final XFile image = await _controller!.takePicture();
      
      // Store the captured image path
      _lastCapturedImage = File(image.path);
      Logger.image('Image captured: ${image.path}');
      
      // Set state to prevent any further camera operations
      if (mounted && !_isDisposed) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
      
      // Dispose camera before navigating
      await _disposeCamera();
      
      // Show loading screen with the captured image path
      if (mounted && !_isDisposed) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreen(
              capturedImagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error('Error capturing image', error: e);
      // Reinitialize camera on error
      if (mounted && !_isDisposed) {
        await _initializeCamera();
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized || _isDisposed) return;
    
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
        Logger.camera('Flash turned off');
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        Logger.camera('Flash turned on');
      }
      if (mounted && !_isDisposed) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } catch (e) {
      Logger.error('Error toggling flash', error: e);
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2 || _isDisposed) return;
    
    Logger.camera('Switching camera');
    setState(() {
      _isCameraInitialized = false;
    });
    
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    await _initializeCamera();
  }

  Future<void> _openGallery() async {
    if (_isDisposed) return;
    
    try {
      Logger.info('Opening gallery');
      // Dispose camera before opening gallery
      await _disposeCamera();
      
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted && !_isDisposed) {
        _lastCapturedImage = File(image.path);
        Logger.image('Image selected from gallery: ${image.path}');
        // Navigate to loading screen with the selected image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreen(
              capturedImagePath: image.path,
            ),
          ),
        );
      } else {
        Logger.info('Gallery selection cancelled');
        // Reinitialize camera if gallery was cancelled
        await _initializeCamera();
      }
    } catch (e) {
      Logger.error('Error picking image from gallery', error: e);
      // Reinitialize camera on error
      await _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true),
      body: Column(
        children: [
          // Camera preview section (expanded to fill available space)
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                if (_isCameraInitialized && _controller != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.previewSize!.height,
                        height: _controller!.value.previewSize!.width,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/preview_placeholder.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                // Square frame overlay
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                // Alignment text
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black54,
                    child: Text(
                      'Align your food inside the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom panel
          Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              children: [
                // Camera controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      'Flash',
                      onTap: _toggleFlash,
                    ),
                    _buildControlButton(
                      Icons.flip_camera_ios,
                      'Flip',
                      onTap: _switchCamera,
                    ),
                    _buildControlButton(
                      Icons.photo_library,
                      'Gallery',
                      onTap: _openGallery,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Capture button
                GestureDetector(
                  onTap: _captureImage,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Tap to capture your meal',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Powered by Nutrigram AI',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
} 