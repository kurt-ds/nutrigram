import 'package:flutter/material.dart';
import 'dart:io';

class MealCard extends StatelessWidget {
  final String title;
  final int kcal;
  final String? image;

  const MealCard({
    super.key,
    required this.title,
    required this.kcal,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image != null
                ? Image(
                    image: FileImage(File(image!)),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text('$kcal kcal', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
} 