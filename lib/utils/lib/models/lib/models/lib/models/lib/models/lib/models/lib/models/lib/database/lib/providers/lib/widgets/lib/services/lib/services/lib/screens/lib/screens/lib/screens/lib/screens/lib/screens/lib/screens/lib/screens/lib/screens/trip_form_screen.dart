import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/custom_textfield.dart';

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _ExpenseRow {
  String category = AppConstants.expenseCategories.first;
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  int? _vehicleId, _driverId, _customerId;
  final _loadingCtrl = TextEditingController();
  final _unloadingCtrl = TextEditingController();
  final _goodsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _freightCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final List<_ExpenseRow> _expenses = [_ExpenseRow()];

  double get _totalExpenses {
    double total = 0;
    for (final e in _expenses) {
      total += double.tryParse(e.amountCtrl.text) ?? 0;
    }
    return total;
  }

  double get _freight => double.tryParse(_freightCtrl.text) ?? 0;
  double get _profit => _freight - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('New Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(Helpers.formatDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            DropdownButtonFormField<int>(
              value: _vehicleId,
              decoration: InputDecoration(labelText: 'Vehicle *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: appState.vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.vehicleNumber))).toList(),
              onChanged: (v) => setState(() => _vehicleId = v),
              validator: (v) => v == null ? 'Select a vehicle' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _driverId,
              decoration: InputDecoration(labelText: 'Driver *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: appState.drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
              onChanged: (v) => setState(() => _driverId = v),
              validator: (v) => v == null ? 'Select a driver' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _customerId,
              decoration: InputDecoration(labelText: 'Customer *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: appState.customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _customerId = v),
              validator: (v) => v == null ? 'Select a customer' : null,
            ),
            CustomTextField(label: 'Loading Point', controller: _loadingCtrl, required: true),
            CustomTextField(label: 'Unloading Point', controller: _unloadingCtrl, required: true),
            CustomTextField(label: 'Goods Type', controller: _goodsCtrl),
            CustomTextField(label: 'Weight (kg/tons)', controller: _weightCtrl, keyboardType: TextInputType.number),
            CustomTextField(label: 'Freight Amount', controller: _freightCtrl, required: true, keyboardType: TextInputType.number),
            CustomTextField(label: 'Advance Payment', controller: _advanceCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => setState(() => _expenses.add(_ExpenseRow())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            ..._expenses.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: row.category,
                              decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              items: AppConstants.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => row.category = v!),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                            onPressed: _expenses.length > 1 ? () => setState(() => _expenses.removeAt(i)) : null,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: row.amountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Amount', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: row.descCtrl,
                              decoration: InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            CustomTextField(label: 'Notes', controller: _notesCtrl, maxLines: 2),
            const SizedBox(height: 16),
            Card(
              color: AppColors.darkBlue.withOpacity(0.06),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _summaryRow('Freight', Helpers.formatCurrency(_freight)),
                    _summaryRow('Total Expenses', Helpers.formatCurrency(_totalExpenses)),
                    const Divider(),
                    _summaryRow('Estimated Profit', Helpers.formatCurrency(_profit), bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: _save,
              child: const Text('Save Trip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppStateProvider>();
    final tripNumber = await appState.nextTripNumber();

    final trip = Trip(
      tripNumber: tripNumber,
      date: _date,
      vehicleId: _vehicleId!,
      driverId: _driverId!,
      customerId: _customerId!,
      loadingPoint: _loadingCtrl.text.trim(),
      unloadingPoint: _unloadingCtrl.text.trim(),
      goodsType: _goodsCtrl.text.trim(),
      weight: double.tryParse(_weightCtrl.text) ?? 0,
      freightAmount: _freight,
      advancePayment: double.tryParse(_advanceCtrl.text) ?? 0,
      notes: _notesCtrl.text.trim(),
    );

    final expenses = _expenses
        .where((e) => (double.tryParse(e.amountCtrl.text) ?? 0) > 0)
        .map((e) => TripExpense(
              tripId: 0,
              category: e.category,
              amount: double.tryParse(e.amountCtrl.text) ?? 0,
              description: e.descCtrl.text.trim(),
            ))
        .toList();

    await appState.addTrip(trip, expenses);
    if (mounted) Navigator.pop(context);
  }
}
