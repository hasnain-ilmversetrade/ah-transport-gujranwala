import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'trip_form_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final trips = appState.trips.where((t) {
      if (_statusFilter == 'All') return true;
      return t.status == _statusFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', ...AppConstants.tripStatuses].map((s) {
                  final selected = _statusFilter == s;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setState(() => _statusFilter = s),
                      selectedColor: AppColors.amber,
                      labelStyle: TextStyle(color: selected ? Colors.white : null),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const TripFormScreen()))
            .then((_) => appState.refreshAll()),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
      body: trips.isEmpty
          ? const Center(child: Text('No trips found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: trips.length,
              itemBuilder: (context, i) {
                final t = trips[i];
                final vehicle = appState.vehicleById(t.vehicleId);
                final customer = appState.customerById(t.customerId);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.profit >= 0 ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
                      child: Icon(Icons.local_shipping, color: t.profit >= 0 ? AppColors.success : AppColors.danger),
                    ),
                    title: Text('${t.tripNumber} • ${vehicle?.vehicleNumber ?? "-"}'),
                    subtitle: Text(
                      '${t.loadingPoint} → ${t.unloadingPoint}\n'
                      '${customer?.name ?? "-"} • ${Helpers.formatDate(t.date)} • ${t.status}',
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Helpers.formatCurrency(t.profit),
                          style: TextStyle(fontWeight: FontWeight.bold, color: t.profit >= 0 ? AppColors.success : AppColors.danger),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Trip'),
                                content: Text('Delete trip ${t.tripNumber}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                ],
                              ),
                            );
                            if (confirm == true) await appState.deleteTrip(t.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
