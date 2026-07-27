import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import 'driver_form_screen.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final drivers = appState.drivers;

    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const DriverFormScreen()))
            .then((_) => appState.refreshAll()),
        icon: const Icon(Icons.add),
        label: const Text('Add Driver'),
      ),
      body: drivers.isEmpty
          ? const Center(child: Text('No drivers found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: drivers.length,
              itemBuilder: (context, i) {
                final d = drivers[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.mediumBlue.withOpacity(0.15), child: const Icon(Icons.person, color: AppColors.mediumBlue)),
                    title: Text(d.name),
                    subtitle: Text('${d.phone}\n${d.salaryType}: ${d.salaryAmount.toStringAsFixed(0)}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => DriverFormScreen(driver: d)))
                              .then((_) => appState.refreshAll());
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Driver'),
                              content: Text('Delete ${d.name}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) await appState.deleteDriver(d.id!);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
