import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String title;
  final int kcal;
  final String image;

  const MealCard({
    super.key,
    required this.title,
    required this.kcal,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Image.asset(image, fit: BoxFit.cover),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12)),
        Text("$kcal kcal", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
} 