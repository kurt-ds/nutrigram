import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/logger.dart';

class NutritionixService {
  static const String _baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';

  Future<Map<String, dynamic>> analyzeFoodDescription(String description) async {
    Logger.info('Starting Nutritionix analysis for: $description');
    
    final headers = {
      'x-app-id': ApiConfig.nutritionixAppId,
      'x-app-key': ApiConfig.nutritionixApiKey,
      'Content-Type': 'application/json',
    };

    final body = json.encode({'query': description});

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        Logger.info('Nutritionix analysis completed: $result');
        return result;
      } else {
        Logger.error('Nutritionix API error: ${response.body}');
        return {'error': 'Failed to analyze food: ${response.statusCode} - ${response.body}'};
      }
    } catch (e) {
      Logger.error('Error in Nutritionix API call', error: e);
      return {'error': e.toString()};
    }
  }
} 