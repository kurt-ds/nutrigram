import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../services/gemini_service.dart';
import '../services/nutritionix_service.dart';
import '../utils/logger.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';

class LoadingScreen extends StatefulWidget {
  final String capturedImagePath;
  
  const LoadingScreen({
    super.key,
    required this.capturedImagePath,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final GeminiService _geminiService = GeminiService();
  final NutritionixService _nutritionixService = NutritionixService();
  String _analysisResult = '';
  bool _isDisposed = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    Logger.info('Initializing LoadingScreen');
    _initializeImage();
    _analyzeImage();
  }

  void _initializeImage() {
    if (widget.capturedImagePath.isNotEmpty) {
      _imageFile = File(widget.capturedImagePath);
      Logger.image('Image initialized: ${widget.capturedImagePath}');
    }
  }

  @override
  void dispose() {
    Logger.info('Disposing LoadingScreen');
    _isDisposed = true;
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Clean up the image file if it exists
    if (_imageFile != null) {
      try {
        _imageFile!.deleteSync();
        Logger.image('Deleted image file: ${_imageFile!.path}');
      } catch (e) {
        Logger.error('Error deleting image file', error: e);
      }
    }
    
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (_isDisposed) return;

    try {
      Logger.info('Starting image analysis');
      final result = await _geminiService.analyzeFoodImage(widget.capturedImagePath);
      if (mounted && !_isDisposed) {
        setState(() {
          _analysisResult = result;
        });
        Logger.info('Image analysis completed');
        
        // Get nutritional information from Nutritionix
        try {
          Logger.info('Fetching nutritional information');
          final nutritionalInfo = await _nutritionixService.analyzeFoodDescription(result);
          Logger.info('Nutritional information received');
        } catch (e) {
          Logger.error('Error getting nutritional information', error: e);
        }

        Logger.info('Navigating to ResultScreen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              capturedImagePath: widget.capturedImagePath,
              analysisResult: result,
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error('Error in _analyzeImage', error: e);
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error analyzing image. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            Text(
              'Analyzing your food...',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait while we detect the ingredients.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 