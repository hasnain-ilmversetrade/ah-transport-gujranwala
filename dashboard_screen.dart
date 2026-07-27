import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/stat_card.dart';
import 'trip_form_screen.dart';
import 'vehicle_form_screen.dart';
import 'driver_form_screen.dart';
import 'customer_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> _todaySummary = {'trips': 0, 'income': 0, 'expense': 0, 'profit': 0};
  List<double> _last7DaysProfit = List.filled(7, 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appState = context.read<AppStateProvider>();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final summary = await appState.summary(from: startOfDay, to: now.add(const Duration(days: 1)));

    final profits = <double>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final s = await appState.summary(from: day, to: day.add(const Duration(days: 1)));
      profits.add(s['profit'] ?? 0);
    }

    if (!mounted) return;
    setState(() {
      _todaySummary = summary;
      _last7DaysProfit = profits;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: RefreshIndicator(
        onRefresh: () async {
          await appState.refreshAll();
          await _load();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Today's Summary", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _loading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: [
                      StatCard(
                        title: 'Total Trips',
                        value: _todaySummary['trips']!.toInt().toString(),
                        icon: Icons.route,
                        color: AppColors.mediumBlue,
                      ),
                      StatCard(
                        title: 'Total Income',
                        value: Helpers.formatCurrency(_todaySummary['income']!),
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                      StatCard(
                        title: 'Total Expenses',
                        value: Helpers.formatCurrency(_todaySummary['expense']!),
                        icon: Icons.trending_down,
                        color: AppColors.danger,
                      ),
                      StatCard(
                        title: 'Net Profit',
                        value: Helpers.formatCurrency(_todaySummary['profit']!),
                        icon: Icons.savings,
                        color: AppColors.amber,
                      ),
                    ],
                  ),
            const SizedBox(height: 24),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _quickAction(context, 'New Trip', Icons.add_road, () => _go(const TripFormScreen())),
                _quickAction(context, 'Add Vehicle', Icons.local_shipping, () => _go(const VehicleFormScreen())),
                _quickAction(context, 'Add Driver', Icons.person_add, () => _go(const DriverFormScreen())),
                _quickAction(context, 'Add Customer', Icons.business, () => _go(const CustomerFormScreen())),
              ],
            ),
            const SizedBox(height: 24),
            Text('Last 7 Days Profit', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < _last7DaysProfit.length; i++)
                              FlSpot(i.toDouble(), _last7DaysProfit[i]),
                          ],
                          isCurved: true,
                          color: AppColors.amber,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: AppColors.amber.withOpacity(0.15)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Trips', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (appState.trips.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No trips yet. Tap "New Trip" to add one.'),
              )
            else
              ...appState.trips.take(5).map((t) {
                final vehicle = appState.vehicleById(t.vehicleId);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.profit >= 0 ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
                      child: Icon(Icons.local_shipping, color: t.profit >= 0 ? AppColors.success : AppColors.danger),
                    ),
                    title: Text('${t.tripNumber} • ${vehicle?.vehicleNumber ?? "-"}'),
                    subtitle: Text('${t.loadingPoint} → ${t.unloadingPoint}\n${Helpers.formatDate(t.date)}'),
                    isThreeLine: true,
                    trailing: Text(
                      Helpers.formatCurrency(t.profit),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.profit >= 0 ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen)).then((_) {
      context.read<AppStateProvider>().refreshAll();
      _load();
    });
  }

  Widget _quickAction(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.darkBlue),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
