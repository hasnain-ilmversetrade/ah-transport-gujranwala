import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode),
              value: appState.themeMode == ThemeMode.dark,
              onChanged: (_) => appState.toggleTheme(),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text(appState.language == 'ur' ? 'اردو (Urdu)' : 'English'),
              trailing: DropdownButton<String>(
                value: appState.language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ur', child: Text('اردو')),
                ],
                onChanged: (v) {
                  if (v != null) appState.setLanguage(v);
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup & Restore'),
              subtitle: const Text('Export data via email (CSV/JSON)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connect a Gmail export flow here (see services/backup_service.dart).')),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('${AppConstants.appName} • v1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
