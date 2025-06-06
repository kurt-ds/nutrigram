import 'package:flutter/material.dart';
import 'components/custom_app_bar.dart';
import 'components/custom_bottom_nav.dart';
import 'components/meal_card.dart';
import 'components/macro_item.dart';
import 'screens/camera_capture_page.dart';
import 'screens/loading_screen.dart';
import 'screens/result_screen.dart';
import 'screens/log_history_screen.dart';
import 'screens/profile_screen.dart';
import '../services/nutrition_service.dart';
import '../models/meal.dart';
import '../utils/logger.dart';
import 'dart:io';

void main() {
  runApp(const NutrigramApp());
}

class NutrigramApp extends StatelessWidget {
  const NutrigramApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrigram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Inter, Helvetica',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardScreen(),
          LogHistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final NutritionService _nutritionService = NutritionService();
  Map<String, dynamic> _dailyNutrition = {
    'calories': 0,
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };
  List<Meal> _recentMeals = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final nutrition = await _nutritionService.getDailyNutrition();
      final meals = await _nutritionService.getRecentMeals();
      
      if (mounted) {
        setState(() {
          _dailyNutrition = nutrition;
          _recentMeals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Error loading dashboard data', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final macroPercentages = _nutritionService.calculateMacroPercentages(
      _dailyNutrition['protein'].toDouble(),
      _dailyNutrition['carbs'].toDouble(),
      _dailyNutrition['fat'].toDouble(),
    );

    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Quick Snap
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraCapturePage()),
                  );
                  _loadData(); // Reload data when returning from camera
                },
                child: Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.camera_alt, size: 32, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text("Tap to capture your meal"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Today's Intake
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Intake", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "${_dailyNutrition['calories'].toStringAsFixed(0)}",
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "kcal",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Container(
                          height: 60,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("P ${_dailyNutrition['protein'].toStringAsFixed(0)}g", 
                                style: const TextStyle(color: Colors.blue)),
                            Text("C ${_dailyNutrition['carbs'].toStringAsFixed(0)}g", 
                                style: const TextStyle(color: Colors.orange)),
                            Text("F ${_dailyNutrition['fat'].toStringAsFixed(0)}g", 
                                style: const TextStyle(color: Colors.pink)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _dailyNutrition['calories'] / 2500,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Recent Meals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Recent Meals", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              if (_recentMeals.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No recent meals',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by capturing your first meal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _recentMeals.map((meal) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: MealCard(
                        title: meal.description.split(',').first,
                        kcal: meal.totalCalories.toInt(),
                        image: meal.imagePath,
                      ),
                    )).toList(),
                  ),
                ),
              const SizedBox(height: 24),
              // Macros Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.pie_chart, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Macros Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MacroItem(
                          label: "Protein", 
                          percent: (macroPercentages['protein'] ?? 0).toInt(), 
                          color: Colors.blue
                        ),
                        MacroItem(
                          label: "Carbs", 
                          percent: (macroPercentages['carbs'] ?? 0).toInt(), 
                          color: Colors.orange
                        ),
                        MacroItem(
                          label: "Fat", 
                          percent: (macroPercentages['fat'] ?? 0).toInt(), 
                          color: Colors.pink
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
