import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'drivers_screen.dart';
import 'customers_screen.dart';
import 'partners_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem('Drivers', Icons.person, AppColors.mediumBlue, const DriversScreen()),
      _MoreItem('Customers', Icons.business, AppColors.amber, const CustomersScreen()),
      _MoreItem('Partners', Icons.handshake, AppColors.success, const PartnersScreen()),
      _MoreItem('Settings', Icons.settings, Colors.grey.shade700, const SettingsScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: item.color.withOpacity(0.15), child: Icon(item.icon, color: item.color)),
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => item.screen)),
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;
  _MoreItem(this.title, this.icon, this.color, this.screen);
}
