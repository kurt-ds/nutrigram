import 'package:flutter/material.dart';
import 'components/custom_app_bar.dart';
import 'components/custom_bottom_nav.dart';
import 'components/meal_card.dart';
import 'components/macro_item.dart';

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
        fontFamily: 'Helvetica',
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
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Snap
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.camera_alt, size: 32, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text("Tap to capture your meal"),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Today's Intake
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Intake", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "1330",
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
                      SizedBox(width: 32),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      SizedBox(width: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("P 62g", style: TextStyle(color: Colors.blue)),
                          Text("C 138g", style: TextStyle(color: Colors.orange)),
                          Text("F 38g", style: TextStyle(color: Colors.pink)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 1330 / 2000,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Recent Meals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Meals", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("See All", style: TextStyle(color: Colors.green)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MealCard(title: "Buddha Bowl", kcal: 450, image: 'assets/bowl.png'),
                MealCard(title: "Grilled Chicken", kcal: 520, image: 'assets/chicken.png'),
                MealCard(title: "Fruit Smoothie", kcal: 160, image: 'assets/smoothie.png'),
              ],
            ),
            SizedBox(height: 24),

            // Macros Breakdown
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Macros Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MacroItem(label: "Protein", percent: 21, color: Colors.blue),
                      MacroItem(label: "Carbs", percent: 65, color: Colors.orange),
                      MacroItem(label: "Fat", percent: 14, color: Colors.pink),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
