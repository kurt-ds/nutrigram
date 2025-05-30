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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Snap
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraCapturePage()),
                );
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
                        children: const [
                          Text(
                            "0",
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          SizedBox(width: 4),
                          Text(
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
                        children: const [
                          Text("P 0g", style: TextStyle(color: Colors.blue)),
                          Text("C 0g", style: TextStyle(color: Colors.orange)),
                          Text("F 0g", style: TextStyle(color: Colors.pink)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0 / 2500,
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
            // Commented out recent meals implementation
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                MealCard(title: "Buddha Bowl", kcal: 450, image: 'assets/bowl.png'),
                MealCard(title: "Grilled Chicken", kcal: 520, image: 'assets/chicken.png'),
                MealCard(title: "Fruit Smoothie", kcal: 160, image: 'assets/smoothie.png'),
              ],
            ),
            */
            // No recent meals message
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
                    children: const [
                      MacroItem(label: "Protein", percent: 0, color: Colors.blue),
                      MacroItem(label: "Carbs", percent: 0, color: Colors.orange),
                      MacroItem(label: "Fat", percent: 0, color: Colors.pink),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
