import 'dart:convert';

class Meal {
  final String id;
  final String imagePath;
  final String description;
  final DateTime timestamp;
  final List<FoodItem> foods;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  Meal({
    required this.id,
    required this.imagePath,
    required this.description,
    required this.timestamp,
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'foods': foods.map((food) => food.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      imagePath: json['imagePath'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      foods: (json['foods'] as List).map((food) => FoodItem.fromJson(food)).toList(),
      totalCalories: json['totalCalories'],
      totalProtein: json['totalProtein'],
      totalCarbs: json['totalCarbs'],
      totalFat: json['totalFat'],
    );
  }
}

class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servings;
  final String unit;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servings,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servings': servings,
      'unit': unit,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      servings: json['servings'],
      unit: json['unit'],
    );
  }
} 