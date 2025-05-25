import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.eco, color: Colors.green),
          SizedBox(width: 8),
          Text("Nutrigram", style: TextStyle(color: Colors.black)),
          Spacer(),
          CircleAvatar(
            backgroundImage: AssetImage('assets/user.jpg'),
            radius: 18,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
} 