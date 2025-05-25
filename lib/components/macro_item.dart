import 'package:flutter/material.dart';

class MacroItem extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;

  const MacroItem({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$percent%",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
} 