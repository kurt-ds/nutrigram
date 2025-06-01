import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/meal.dart';
import '../utils/logger.dart';
import 'package:flutter/rendering.dart';

class StorageService {
  static const String _mealsKey = 'saved_meals';
  final _uuid = const Uuid();

  Future<String> saveImage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/meal_images');
      
      if (!imagesDir.existsSync()) {
        imagesDir.createSync(recursive: true);
      }

      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        throw Exception('Source image file does not exist');
      }

      final fileName = '${_uuid.v4()}.jpg';
      final targetPath = '${imagesDir.path}/$fileName';
      final targetFile = File(targetPath);

      await sourceFile.copy(targetPath);
      Logger.info('Image saved successfully to: $targetPath');
      return targetPath;
    } catch (e) {
      Logger.error('Error saving image', error: e);
      rethrow;
    }
  }

  Future<void> saveMeal(Meal meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      
      // Add new meal
      mealsJson.add(jsonEncode(meal.toJson()));
      
      await prefs.setStringList(_mealsKey, mealsJson);
      Logger.info('Meal saved successfully');
    } catch (e) {
      Logger.error('Error saving meal', error: e);
      rethrow;
    }
  }

  Future<List<Meal>> getAllMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      
      return mealsJson
          .map((json) => Meal.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      Logger.error('Error getting all meals', error: e);
      return [];
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      
      // Find and remove the meal
      final updatedMeals = mealsJson.where((json) {
        final meal = Meal.fromJson(jsonDecode(json));
        return meal.id != mealId;
      }).toList();
      
      await prefs.setStringList(_mealsKey, updatedMeals);
      Logger.info('Meal deleted successfully');
    } catch (e) {
      Logger.error('Error deleting meal', error: e);
      rethrow;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        await file.delete();
        Logger.info('Image deleted successfully: $imagePath');
      }
    } catch (e) {
      Logger.error('Error deleting image', error: e);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      // Clear meals from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mealsKey);
      
      // Clear daily nutrition data
      await prefs.remove('daily_nutrition');
      
      // Clear all images from the meal_images directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/meal_images');
      
      if (imagesDir.existsSync()) {
        await imagesDir.delete(recursive: true);
        Logger.info('Cleared all saved images');
      }
      
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      Logger.info('Cleared all saved meals, nutrition data, and images');
    } catch (e) {
      Logger.error('Error clearing data', error: e);
      rethrow;
    }
  }
} 