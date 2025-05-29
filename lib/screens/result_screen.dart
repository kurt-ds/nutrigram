import 'package:flutter/material.dart';
import 'dart:io';
import '../components/custom_app_bar.dart';

class ResultScreen extends StatefulWidget {
  final String capturedImagePath;
  final String analysisResult;
  
  const ResultScreen({
    super.key,
    required this.capturedImagePath,
    required this.analysisResult,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> foods = [
    {
      'name': 'Boiled Egg',
      'icon': Icons.egg,
      'color': Colors.amber,
      'kcal': 68,
      'servings': 1.0,
    },
    {
      'name': 'Whole Wheat Toast',
      'icon': Icons.bakery_dining,
      'color': Colors.orange,
      'kcal': 160,
      'servings': 2.0,
    },
    {
      'name': 'Avocado Slices',
      'icon': Icons.eco,
      'color': Colors.green,
      'kcal': 80,
      'servings': 0.5,
    },
  ];

  double get totalKcal => foods.fold(0, (sum, item) => sum + item['kcal'] * item['servings']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(showBackButton: true),
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
                      child: Image.file(
                        File(widget.capturedImagePath),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
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
                                decoration: BoxDecoration(
                                  color: food['color'].withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Icon(food['icon'], color: food['color'], size: 22),
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text('${(food['kcal'] * food['servings']).toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        foods.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        label: const Text('Add food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Nutrition Facts Section
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
                    Row(
                      children: [
                        Expanded(child: _macroItem('Calories', '${totalKcal.toStringAsFixed(0)} kcal')),
                        SizedBox(width: 16),
                        Expanded(child: _macroItem('Protein', '13 g')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _macroItem('Carbs', '27 g')),
                        SizedBox(width: 16),
                        Expanded(child: _macroItem('Fat', '16 g')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Save Meal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                onPressed: () {
                  // TODO: Implement save functionality
                },
              ),
            ),
          ],
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