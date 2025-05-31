import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meal.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

class NutritionService {
  static const String _dailyNutritionKey = 'daily_nutrition';
  static const String _recentMealsKey = 'recent_meals';
  static const int _maxRecentMeals = 3;
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> getDailyNutrition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nutritionJson = prefs.getString(_dailyNutritionKey);
      
      if (nutritionJson != null) {
        return jsonDecode(nutritionJson);
      }
      
      // Return default values if no data exists
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      Logger.error('Error getting daily nutrition', error: e);
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'date': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<void> updateDailyNutrition(Meal meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nutritionJson = prefs.getString(_dailyNutritionKey);
      final now = DateTime.now();
      
      Map<String, dynamic> nutrition;
      if (nutritionJson != null) {
        nutrition = jsonDecode(nutritionJson);
        final savedDate = DateTime.parse(nutrition['date']);
        
        // Reset values if it's a new day
        if (now.year != savedDate.year || 
            now.month != savedDate.month || 
            now.day != savedDate.day) {
          nutrition = {
            'calories': 0,
            'protein': 0,
            'carbs': 0,
            'fat': 0,
            'date': now.toIso8601String(),
          };
        }
      } else {
        nutrition = {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'date': now.toIso8601String(),
        };
      }

      // Update nutrition values
      nutrition['calories'] += meal.totalCalories;
      nutrition['protein'] += meal.totalProtein;
      nutrition['carbs'] += meal.totalCarbs;
      nutrition['fat'] += meal.totalFat;

      await prefs.setString(_dailyNutritionKey, jsonEncode(nutrition));
      Logger.info('Daily nutrition updated successfully');
    } catch (e) {
      Logger.error('Error updating daily nutrition', error: e);
    }
  }

  Future<List<Meal>> getRecentMeals() async {
    try {
      // Get all meals from storage service
      final allMeals = await _storageService.getAllMeals();
      
      // Sort meals by timestamp in descending order (most recent first)
      allMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Return only the most recent meals, limited to _maxRecentMeals
      return allMeals.take(_maxRecentMeals).toList();
    } catch (e) {
      Logger.error('Error getting recent meals', error: e);
      return [];
    }
  }

  Future<void> addRecentMeal(Meal meal) async {
    try {
      // Save the meal using storage service
      await _storageService.saveMeal(meal);
      
      // Update daily nutrition
      await updateDailyNutrition(meal);
      
      Logger.info('Recent meal added successfully');
    } catch (e) {
      Logger.error('Error adding recent meal', error: e);
    }
  }

  Map<String, double> calculateMacroPercentages(double protein, double carbs, double fat) {
    final total = protein + carbs + fat;
    if (total == 0) return {'protein': 0, 'carbs': 0, 'fat': 0};
    
    return {
      'protein': (protein / total) * 100,
      'carbs': (carbs / total) * 100,
      'fat': (fat / total) * 100,
    };
  }
} 