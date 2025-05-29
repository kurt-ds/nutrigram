import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiConfig.geminiApiKey,
    );
  }

  Future<String> analyzeFoodImage(String imagePath) async {
    try {
      // Read the image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // Create the content for the model
      final content = [
        Content.multi([
          TextPart('Analyze this food image and provide:\n'
              '1. A detailed description of the food\n'
              '2. Estimated serving size\n'
              '3. Main ingredients visible\n'
              '4. Any notable nutritional aspects'),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate content
      final response = await _model.generateContent(content);
      return response.text ?? 'No analysis available';
    } catch (e) {
      print('Error analyzing image: $e');
      return 'Error analyzing the image. Please try again.';
    }
  }
} 