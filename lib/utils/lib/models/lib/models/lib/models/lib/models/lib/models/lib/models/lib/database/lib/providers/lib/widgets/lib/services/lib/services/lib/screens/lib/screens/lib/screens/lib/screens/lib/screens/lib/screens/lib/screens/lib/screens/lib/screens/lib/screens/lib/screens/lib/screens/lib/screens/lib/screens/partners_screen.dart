import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/partner_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_textfield.dart';

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final partners = appState.partners;

    return Scaffold(
      appBar: AppBar(title: const Text('Partners')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Partner'),
      ),
      body: partners.isEmpty
          ? const Center(child: Text('No partners found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: partners.length,
              itemBuilder: (context, i) {
                final p = partners[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.success.withOpacity(0.15), child: const Icon(Icons.handshake, color: AppColors.success)),
                    title: Text(p.name),
                    subtitle: Text('${p.phone}\nDefault Share: ${p.defaultSharePercent.toStringAsFixed(0)}%'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final shareCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Partner'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Name', controller: nameCtrl, required: true),
              CustomTextField(label: 'Phone', controller: phoneCtrl, required: true),
              CustomTextField(label: 'CNIC', controller: cnicCtrl),
              CustomTextField(label: 'Default Share %', controller: shareCtrl, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              await ctx.read<AppStateProvider>().addPartner(Partner(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    cnic: cnicCtrl.text.trim(),
                    defaultSharePercent: double.tryParse(shareCtrl.text) ?? 0,
                  ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
