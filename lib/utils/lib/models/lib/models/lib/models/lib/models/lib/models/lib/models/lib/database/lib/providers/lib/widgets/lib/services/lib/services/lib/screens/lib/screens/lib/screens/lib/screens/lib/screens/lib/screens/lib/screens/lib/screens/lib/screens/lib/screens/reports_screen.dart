import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/trip_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/pdf_service.dart';

enum ReportRange { daily, weekly, monthly, yearly, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportRange _range = ReportRange.daily;
  DateTime _customFrom = DateTime.now().subtract(const Duration(days: 7));
  DateTime _customTo = DateTime.now();
  int? _vehicleFilter;

  DateTimeRange _resolveRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_range) {
      case ReportRange.daily:
        return DateTimeRange(start: today, end: today.add(const Duration(days: 1)));
      case ReportRange.weekly:
        return DateTimeRange(start: today.subtract(Duration(days: today.weekday - 1)), end: today.add(const Duration(days: 1)));
      case ReportRange.monthly:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: today.add(const Duration(days: 1)));
      case ReportRange.yearly:
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: today.add(const Duration(days: 1)));
      case ReportRange.custom:
        return DateTimeRange(start: _customFrom, end: _customTo.add(const Duration(days: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final range = _resolveRange();

    var trips = appState.trips.where((t) => t.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && t.date.isBefore(range.end)).toList();
    if (_vehicleFilter != null) {
      trips = trips.where((t) => t.vehicleId == _vehicleFilter).toList();
    }

    double totalFreight = 0, totalExpense = 0;
    for (final t in trips) {
      totalFreight += t.freightAmount;
      totalExpense += t.totalExpenses;
    }
    final profit = totalFreight - totalExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: ReportRange.values.map((r) {
              final label = {
                ReportRange.daily: 'Daily',
                ReportRange.weekly: 'Weekly',
                ReportRange.monthly: 'Monthly',
                ReportRange.yearly: 'Yearly',
                ReportRange.custom: 'Custom',
              }[r]!;
              return ChoiceChip(
                label: Text(label),
                selected: _range == r,
                onSelected: (_) async {
                  if (r == ReportRange.custom) {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDateRange: DateTimeRange(start: _customFrom, end: _customTo),
                    );
                    if (picked != null) {
                      setState(() {
                        _customFrom = picked.start;
                        _customTo = picked.end;
                        _range = r;
                      });
                    }
                  } else {
                    setState(() => _range = r);
                  }
                },
                selectedColor: AppColors.amber,
                labelStyle: TextStyle(color: _range == r ? Colors.white : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            value: _vehicleFilter,
            decoration: InputDecoration(labelText: 'Filter by Vehicle (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('All Vehicles')),
              ...appState.vehicles.map((v) => DropdownMenuItem<int?>(value: v.id, child: Text(v.vehicleNumber))),
            ],
            onChanged: (v) => setState(() => _vehicleFilter = v),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Total Trips', trips.length.toString()),
                  _row('Total Freight (Income)', Helpers.formatCurrency(totalFreight)),
                  _row('Total Expenses', Helpers.formatCurrency(totalExpense)),
                  const Divider(),
                  _row('Net Profit', Helpers.formatCurrency(profit), bold: true, color: profit >= 0 ? AppColors.success : AppColors.danger),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
            onPressed: trips.isEmpty
                ? null
                : () {
                    final vehicleNames = {for (final v in appState.vehicles) v.id!: v.vehicleNumber};
                    final customerNames = {for (final c in appState.customers) c.id!: c.name};
                    PdfService.exportTripsReport(
                      title: '${_range.name.toUpperCase()} REPORT',
                      trips: trips,
                      vehicleNames: vehicleNames,
                      customerNames: customerNames,
                    );
                  },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF Report'),
          ),
          const SizedBox(height: 20),
          Text('Trips in Range (${trips.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...trips.map((t) => _tripTile(appState, t)),
        ],
      ),
    );
  }

  Widget _tripTile(AppStateProvider appState, Trip t) {
    final vehicle = appState.vehicleById(t.vehicleId);
    return Card(
      child: ListTile(
        title: Text('${t.tripNumber} • ${vehicle?.vehicleNumber ?? "-"}'),
        subtitle: Text('${Helpers.formatDate(t.date)} • ${t.loadingPoint} → ${t.unloadingPoint}'),
        trailing: Text(
          Helpers.formatCurrency(t.profit),
          style: TextStyle(fontWeight: FontWeight.bold, color: t.profit >= 0 ? AppColors.success : AppColors.danger),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color, fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }
}
