import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_bottom_nav.dart';
import '../screens/log_history_screen.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const ProfileScreen({super.key, this.onBackToHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _clearData(BuildContext context) async {
    try {
      final storageService = StorageService();
      
      // Show confirmation dialog
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text('This will delete all saved meals and images. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear Data'),
            ),
          ],
        ),
      );

      if (shouldClear == true) {
        await storageService.clearAllData();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully')),
          );
          // Navigate back to home screen and force reload
          if (context.mounted) {
            // Pop all routes until we reach the home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
            // Force rebuild of the current route
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        }
      }
    } catch (e) {
      Logger.error('Error clearing data', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: AssetImage('assets/user.jpg'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Alice Williams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text('Premium Member', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _MetricItem(label: 'Weight', value: '54kg'),
                          _MetricItem(label: 'Height', value: '166cm'),
                          _MetricItem(label: 'Age', value: '26'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Your Goals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        child: Column(
                          children: const [
                            Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                            SizedBox(height: 8),
                            Text('1,800 kcal/day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('Calorie Goal', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        child: Column(
                          children: const [
                            Icon(Icons.monitor_weight, color: Colors.blue, size: 28),
                            SizedBox(height: 8),
                            Text('Lose 2kg/mo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('Weight Goal', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Preferences Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    _PrefItem(icon: Icons.notifications, label: 'Notifications', onTap: () {}),
                    _PrefItem(icon: Icons.lock, label: 'Privacy & Security', onTap: () {}),
                    _PrefItem(icon: Icons.nightlight_round, label: 'App Theme', onTap: () {}),
                    _PrefItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
                  ],
                ),
              ),
            ),
            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
            ),
            // Clear Data Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text('Clear All Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => _clearData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetricItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _PrefItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrefItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
} 