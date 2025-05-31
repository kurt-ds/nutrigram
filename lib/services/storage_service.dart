import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/meal.dart';
import '../utils/logger.dart';

class StorageService {
  static const String _mealsKey = 'saved_meals';
  final _uuid = const Uuid();

  Future<String> saveImage(String sourcePath) async {
    try {
      // Check if source file exists
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source image file does not exist at path: $sourcePath');
      }

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/meal_images');
      
      // Create the images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename
      final fileName = '${_uuid.v4()}.jpg';
      final destinationPath = '${imagesDir.path}/$fileName';
      
      // Copy the file
      try {
        await sourceFile.copy(destinationPath);
        Logger.info('Image saved successfully to: $destinationPath');
        return destinationPath;
      } catch (e) {
        Logger.error('Error copying image file', error: e);
        throw Exception('Failed to copy image file: $e');
      }
    } catch (e) {
      Logger.error('Error saving image', error: e);
      rethrow;
    }
  }

  Future<void> saveMeal(Meal meal) async {
    try {
      // Verify the image exists before saving the meal
      final imageFile = File(meal.imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Saved image file does not exist at path: ${meal.imagePath}');
      }

      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      
      mealsJson.add(jsonEncode(meal.toJson()));
      await prefs.setStringList(_mealsKey, mealsJson);
      
      Logger.info('Meal saved successfully');
    } catch (e) {
      Logger.error('Error saving meal', error: e);
      rethrow;
    }
  }

  Future<List<Meal>> loadMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      
      return mealsJson.map((json) => Meal.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      Logger.error('Error loading meals', error: e);
      return [];
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      
      // Find the meal to delete
      Meal? mealToDelete;
      final updatedMeals = mealsJson.where((json) {
        final meal = Meal.fromJson(jsonDecode(json));
        if (meal.id == mealId) {
          mealToDelete = meal;
          return false;
        }
        return true;
      }).toList();
      
      // Delete the meal's image file if it exists
      if (mealToDelete != null) {
        final imageFile = File(mealToDelete!.imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          Logger.info('Deleted meal image: ${mealToDelete!.imagePath}');
        }
      }
      
      await prefs.setStringList(_mealsKey, updatedMeals);
      Logger.info('Meal deleted successfully');
    } catch (e) {
      Logger.error('Error deleting meal', error: e);
      rethrow;
    }
  }
} 