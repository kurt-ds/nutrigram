import 'package:flutter/material.dart';
import 'result_screen.dart';
import '../services/gemini_service.dart';
import '../services/nutritionix_service.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final result = await _geminiService.analyzeFoodImage(widget.capturedImagePath);
      if (mounted) {
        setState(() {
          _analysisResult = result;
        });
        
        // Get nutritional information from Nutritionix
        try {
          final nutritionalInfo = await _nutritionixService.analyzeFoodDescription(result);
          print('Nutritional Information:');
        } catch (e) {
          print('Error getting nutritional information: $e');
        }

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
      print('Error in _analyzeImage: $e');
      if (mounted) {
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