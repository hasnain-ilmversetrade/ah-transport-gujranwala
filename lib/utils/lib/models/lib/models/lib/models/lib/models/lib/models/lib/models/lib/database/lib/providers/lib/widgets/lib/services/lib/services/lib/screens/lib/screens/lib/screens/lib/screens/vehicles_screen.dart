import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'vehicle_form_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final vehicles = appState.vehicles.where((v) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return v.vehicleNumber.toLowerCase().contains(q) || v.type.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search vehicle number or type...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const VehicleFormScreen()))
            .then((_) => appState.refreshAll()),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
      body: vehicles.isEmpty
          ? const Center(child: Text('No vehicles found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vehicles.length,
              itemBuilder: (context, i) {
                final v = vehicles[i];
                final insuranceDays = v.insuranceExpiry != null ? Helpers.daysUntil(v.insuranceExpiry!) : null;
                final expiringSoon = insuranceDays != null && insuranceDays <= 30 && insuranceDays >= 0;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.mediumBlue.withOpacity(0.15),
                      child: const Icon(Icons.local_shipping, color: AppColors.mediumBlue),
                    ),
                    title: Text(v.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${v.type} • ${v.model}\n${v.ownershipType}'
                        '${expiringSoon ? "\n⚠ Insurance expires in $insuranceDays days" : ""}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: v)))
                              .then((_) => appState.refreshAll());
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Vehicle'),
                              content: Text('Delete ${v.vehicleNumber}? This cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await appState.deleteVehicle(v.id!);
                          }
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
