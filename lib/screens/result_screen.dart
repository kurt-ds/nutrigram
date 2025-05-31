import 'package:flutter/material.dart';
import 'dart:io';
import '../components/custom_app_bar.dart';
import '../utils/logger.dart';
import '../services/storage_service.dart';
import '../models/meal.dart';
import 'package:uuid/uuid.dart';

class ResultScreen extends StatefulWidget {
  final String capturedImagePath;
  final String analysisResult;
  final Map<String, dynamic>? nutritionalInfo;
  
  const ResultScreen({
    super.key,
    required this.capturedImagePath,
    required this.analysisResult,
    this.nutritionalInfo,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();
  bool _isSaving = false;
  ImageProvider? _imageProvider;
  bool _isDisposed = false;
  File? _imageFile;
  List<Map<String, dynamic>> foods = [];
  String? _savedImagePath;
  bool _isImageSaved = false;

  double get totalKcal => foods.fold(0, (sum, item) => sum + (item['calories']));
  double get totalProtein => foods.fold(0, (sum, item) => sum + (item['protein']));
  double get totalCarbs => foods.fold(0, (sum, item) => sum + (item['carbs']));
  double get totalFat => foods.fold(0, (sum, item) => sum + (item['fat']));

  @override
  void initState() {
    super.initState();
    Logger.info('Initializing ResultScreen');
    _initializeImage();
    _initializeFoods();
    _logAnalysisResults();
  }

  void _initializeImage() {
    if (widget.capturedImagePath.isNotEmpty) {
      try {
        Logger.info('Initializing image from path: ${widget.capturedImagePath}');
        
        // Check if the path is a direct file path
        _imageFile = File(widget.capturedImagePath);
        if (_imageFile!.existsSync()) {
          _imageProvider = FileImage(_imageFile!);
          Logger.info('Image file exists and initialized successfully');
          Logger.info('Image file size: ${_imageFile!.lengthSync()} bytes');
          return;
        }

        // If not found, try to find it in the temp_images directory
        final tempDir = Directory('/data/user/0/com.example.nutrigram/app_flutter/temp_images');
        if (tempDir.existsSync()) {
          Logger.info('Searching in temp directory: ${tempDir.path}');
          final tempFiles = tempDir.listSync();
          Logger.info('Found ${tempFiles.length} files in temp directory');
          
          // Try to find the most recent image file
          File? mostRecentFile;
          DateTime? mostRecentTime;
          
          for (var file in tempFiles) {
            if (file is File && file.path.endsWith('.jpg')) {
              final stat = file.statSync();
              if (mostRecentTime == null || stat.modified.isAfter(mostRecentTime)) {
                mostRecentFile = file;
                mostRecentTime = stat.modified;
              }
            }
          }
          
          if (mostRecentFile != null) {
            _imageFile = mostRecentFile;
            _imageProvider = FileImage(_imageFile!);
            Logger.info('Found and using most recent image: ${_imageFile!.path}');
            return;
          }
        }

        Logger.error('Could not find image file at path: ${widget.capturedImagePath}');
      } catch (e) {
        Logger.error('Error initializing image', error: e);
      }
    } else {
      Logger.error('No image path provided');
    }
  }

  void _initializeFoods() {
    if (widget.nutritionalInfo != null && widget.nutritionalInfo!['foods'] != null) {
      foods = (widget.nutritionalInfo!['foods'] as List).map((food) {
        return {
          'name': food['food_name'],
          'calories': food['nf_calories']?.toDouble() ?? 0.0,
          'protein': food['nf_protein']?.toDouble() ?? 0.0,
          'carbs': food['nf_total_carbohydrate']?.toDouble() ?? 0.0,
          'fat': food['nf_total_fat']?.toDouble() ?? 0.0,
          'servings': food['serving_qty']?.toDouble() ?? 1.0,
          'unit': food['serving_unit'] ?? 'serving',
        };
      }).toList();
    }
  }

  void _logAnalysisResults() {
    Logger.info('Analysis Results:');
    Logger.info('Food Description: ${widget.analysisResult}');
    
    if (widget.nutritionalInfo != null) {
      Logger.info('Nutritional Information:');
      if (widget.nutritionalInfo!['foods'] != null) {
        for (var food in widget.nutritionalInfo!['foods']) {
          Logger.info('Food: ${food['food_name']}');
          Logger.info('  Quantity: ${food['serving_qty']} ${food['serving_unit']}');
          Logger.info('  Calories: ${food['nf_calories']} kcal');
          Logger.info('  Protein: ${food['nf_protein']}g');
          Logger.info('  Fat: ${food['nf_total_fat']}g');
          Logger.info('  Carbs: ${food['nf_total_carbohydrate']}g');
        }
      } else {
        Logger.warning('No food items found in nutritional information');
      }
    } else {
      Logger.warning('No nutritional information available');
    }
  }

  @override
  void dispose() {
    Logger.info('Disposing ResultScreen');
    _isDisposed = true;
    
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Only delete the temporary image if it hasn't been saved
    if (_imageFile != null && !_isImageSaved) {
      try {
        if (_imageFile!.existsSync()) {
          _imageFile!.deleteSync();
          Logger.image('Deleted temporary image file: ${_imageFile!.path}');
        }
      } catch (e) {
        Logger.error('Error deleting temporary image file', error: e);
      }
    }
    
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Verify image file exists and log its details
      if (_imageFile == null) {
        throw Exception('No image file available');
      }

      Logger.info('Checking image file before save:');
      Logger.info('Image path: ${_imageFile!.path}');
      Logger.info('File exists: ${_imageFile!.existsSync()}');
      
      if (!_imageFile!.existsSync()) {
        throw Exception('Image file does not exist');
      }

      if (_imageFile!.existsSync()) {
        Logger.info('File size: ${_imageFile!.lengthSync()} bytes');
      }

      // Save the image first
      _savedImagePath = await _storageService.saveImage(_imageFile!.path);
      Logger.info('Image saved successfully to: $_savedImagePath');
      _isImageSaved = true;

      // Create food items from the foods list
      final foodItems = foods.map((food) => FoodItem(
        name: food['name'],
        calories: food['calories'],
        protein: food['protein'],
        carbs: food['carbs'],
        fat: food['fat'],
        servings: food['servings'],
        unit: food['unit'],
      )).toList();

      // Create and save the meal
      final meal = Meal(
        id: _uuid.v4(),
        imagePath: _savedImagePath!,
        description: widget.analysisResult,
        timestamp: DateTime.now(),
        foods: foodItems,
        totalCalories: totalKcal,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
      );

      await _storageService.saveMeal(meal);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal saved successfully')),
      );

      // Navigate back to home page
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      Logger.error('Error saving meal', error: e);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving meal: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNoFood = widget.analysisResult.toLowerCase().contains('no food items visible') ||
                          widget.analysisResult.toLowerCase().contains('no food found') ||
                          foods.isEmpty;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CustomAppBar(showBackButton: false),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Result',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Photo Detected Section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _imageProvider != null
                            ? Image(
                                image: _imageProvider!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error_outline, color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error_outline, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text('Photo detected', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Detected Foods Section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.restaurant, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Detected Foods', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 24),
                      if (hasNoFood)
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.no_food, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No food items detected',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please try taking another photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.home_outlined, color: Colors.white),
                                  label: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: foods.length,
                          itemBuilder: (context, index) {
                            final food = foods[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Text('Servings', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                            const SizedBox(width: 4),
                                            SizedBox(
                                              width: 50,
                                              height: 32,
                                              child: TextField(
                                                controller: TextEditingController(text: food['servings'].toString()),
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    double? v = double.tryParse(val);
                                                    foods[index]['servings'] = v ?? 0.0;
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(food['unit'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text('${food['calories']} kcal', 
                                        style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nutrition Facts Section
              if (!hasNoFood) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.apple, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Nutrition Facts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const Divider(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _macroItem('Calories', '${totalKcal.toStringAsFixed(0)} kcal'),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _macroItem('Protein', '${totalProtein.toStringAsFixed(1)} g'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _macroItem('Carbs', '${totalCarbs.toStringAsFixed(1)} g'),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _macroItem('Fat', '${totalFat.toStringAsFixed(1)} g'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Approximate values based on servings',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.close, color: Colors.black87),
                        label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: _isSaving 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Meal',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        onPressed: _isSaving ? null : _saveMeal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
} 