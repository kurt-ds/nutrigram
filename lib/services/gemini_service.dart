import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/logger.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiConfig.geminiApiKey,
    );
    Logger.info('GeminiService initialized');
  }

  Future<String> analyzeFoodImage(String imagePath) async {
    try {
      Logger.info('Starting Gemini image analysis');
      // Read the image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // Create the content for the model
      final content = [
        Content.multi([
          TextPart('Analyze this food image and output a list of ingredients, one per line, in the style of a recipe. '
              'For each item, include a quantity and unit if possible (e.g., "1 slice whole wheat bread", "2 tablespoons peanut butter", "1 medium apple"). '
              'Do not include any explanations, just the list.\n'
              'Example:\n'
              '1 slice whole wheat bread\n'
              '2 tablespoons peanut butter\n'
              '1 medium apple\n'
              'Only include clearly visible food items.'),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate content
      final response = await _model.generateContent(content);
      Logger.info('Gemini analysis completed: ${response.text}');
      return response.text ?? 'No analysis available';
    } catch (e) {
      Logger.error('Error analyzing image with Gemini', error: e);
      return 'Error analyzing the image. Please try again.';
    }
  }
} 