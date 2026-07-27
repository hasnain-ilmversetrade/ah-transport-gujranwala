import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'customer_form_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final customers = appState.customers;

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CustomerFormScreen()))
            .then((_) => appState.refreshAll()),
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
      body: customers.isEmpty
          ? const Center(child: Text('No customers found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: customers.length,
              itemBuilder: (context, i) {
                final c = customers[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.amber.withOpacity(0.15), child: const Icon(Icons.business, color: AppColors.amber)),
                    title: Text(c.name),
                    subtitle: Text('${c.phone}\nOutstanding: ${Helpers.formatCurrency(c.outstandingBalance)}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: c)))
                              .then((_) => appState.refreshAll());
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Customer'),
                              content: Text('Delete ${c.name}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) await appState.deleteCustomer(c.id!);
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
