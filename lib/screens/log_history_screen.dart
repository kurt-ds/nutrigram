import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_bottom_nav.dart';
import '../screens/profile_screen.dart';

class LogHistoryScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const LogHistoryScreen({super.key, this.onBackToHome});

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen> {
  int selectedView = 0; // 0: List, 1: Calendar
  DateTime selectedDate = DateTime.now();
  final List<Map<String, dynamic>> logs = [
    {
      'mealType': 'Breakfast',
      'desc': 'Oatmeal, banana, almonds',
      'kcal': 320,
      'image': 'assets/breakfast.jpg',
      'photo': true,
      'time': '08:15 AM',
    },
    {
      'mealType': 'Lunch',
      'desc': 'Chicken salad, brown rice, avocado',
      'kcal': 520,
      'image': 'assets/lunch.jpg',
      'photo': true,
      'time': '12:45 PM',
    },
    {
      'mealType': 'Snack',
      'desc': 'Greek yogurt, berries',
      'kcal': 180,
      'image': 'assets/snack.jpg',
      'photo': false,
      'time': '15:30 PM',
    },
    {
      'mealType': 'Dinner',
      'desc': 'Grilled salmon, veggies',
      'kcal': 410,
      'image': 'assets/dinner.jpg',
      'photo': true,
      'time': '19:10 PM',
    },
  ];

  void _changeMonth(int delta) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + delta, selectedDate.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final firstDayOfWeek = DateTime(selectedDate.year, selectedDate.month, 1).weekday;
    final today = DateTime.now();
    final isCurrentMonth = today.year == selectedDate.year && today.month == selectedDate.month;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(showBackButton: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Log History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // View Toggle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedView = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedView == 0 ? Colors.green : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Center(
                            child: Text('List View', style: TextStyle(
                              color: selectedView == 0 ? Colors.white : Colors.green,
                              fontWeight: FontWeight.bold,
                            )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedView = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedView == 1 ? Colors.green : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Center(
                            child: Text('Calendar View', style: TextStyle(
                              color: selectedView == 1 ? Colors.white : Colors.green,
                              fontWeight: FontWeight.bold,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Month Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      '${_monthName(selectedDate.month)} ${selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              // Calendar Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) => Text(_weekdayShort(i), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 4),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: daysInMonth + firstDayOfWeek - 1,
                      itemBuilder: (context, i) {
                        if (i < firstDayOfWeek - 1) return const SizedBox();
                        final day = i - firstDayOfWeek + 2;
                        final isToday = isCurrentMonth && day == today.day;
                        return GestureDetector(
                          onTap: () => setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month, day)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isToday ? Colors.green : (selectedDate.day == day ? Colors.green[100] : Colors.white),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isToday ? Colors.green : Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text('$day', style: TextStyle(
                                color: isToday ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => selectedDate = today),
                          child: const Text('Today', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Food Log Entries (List View)
              if (selectedView == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    children: logs.map((log) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(log['image']),
                          radius: 24,
                        ),
                        title: Text(log['mealType'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(log['desc']),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                                const SizedBox(width: 2),
                                Text('${log['kcal']} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (log['photo']) const Icon(Icons.photo_camera, size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(log['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _weekdayShort(int i) {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days[i];
  }
} 