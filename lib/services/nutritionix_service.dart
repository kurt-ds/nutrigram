import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NutritionixService {
  static const String _baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';

  Future<Map<String, dynamic>> analyzeFoodDescription(String description) async {
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
        print('Nutritionix NLP Response: $result');
        // Print only the required fields for each food
        if (result['foods'] != null && result['foods'] is List) {
          for (final food in result['foods']) {
            print('Food: ${food['food_name']}, '
                  'Qty: ${food['serving_qty']}, '
                  'Calories: ${food['nf_calories']}, '
                  'Protein: ${food['nf_protein']}, '
                  'Fat: ${food['nf_total_fat']}, '
                  'Carbs: ${food['nf_total_carbohydrate']}');
          }
        }
        return result;
      } else {
        print('Nutritionix error: ${response.body}');
        return {'error': 'Failed to analyze food: ${response.statusCode} - ${response.body}'};
      }
    } catch (e) {
      print('Error in Nutritionix API call: $e');
      return {'error': e.toString()};
    }
  }
} 