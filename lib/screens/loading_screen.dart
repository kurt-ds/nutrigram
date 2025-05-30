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
    _initializeImage();
    _analyzeImage();
  }

  void _initializeImage() {
    if (widget.capturedImagePath.isNotEmpty) {
      _imageFile = File(widget.capturedImagePath);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Clean up the image file if it exists
    if (_imageFile != null) {
      try {
        _imageFile!.deleteSync();
      } catch (e) {
        Logger.error('Error deleting image file', error: e);
      }
    }
    
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    try {
      Logger.debug('Image path: ${widget.capturedImagePath}');
      
      final geminiService = GeminiService();
      final nutritionixService = NutritionixService();

      // Analyze image with Gemini
      final response = await geminiService.analyzeFoodImage(widget.capturedImagePath);

      // Get nutritional information from Nutritionix
      final nutritionData = await nutritionixService.analyzeFoodDescription(response);

      if (!mounted) return;

      // Navigate to result screen with the data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            capturedImagePath: widget.capturedImagePath,
            analysisResult: response,
            nutritionalInfo: nutritionData,
          ),
        ),
      );
    } catch (e) {
      Logger.error('Error in image analysis', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e')),
      );
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