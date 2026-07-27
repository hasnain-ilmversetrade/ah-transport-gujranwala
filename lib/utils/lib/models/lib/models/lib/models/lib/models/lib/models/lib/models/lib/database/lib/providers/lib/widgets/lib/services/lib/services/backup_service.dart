import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

/// Exports all app data to a JSON file the user can share via email,
/// WhatsApp, Google Drive, etc. using the OS share sheet (share_plus).
///
/// Extend this with a scheduled/automatic backup by calling
/// `BackupService.exportAll()` from a background task or on app close.
class BackupService {
  static Future<void> exportAll() async {
    final db = DatabaseHelper.instance;

    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'vehicles': (await db.getVehicles()).map((v) => v.toMap()).toList(),
      'partners': (await db.getPartners()).map((p) => p.toMap()).toList(),
      'drivers': (await db.getDrivers()).map((d) => d.toMap()).toList(),
      'customers': (await db.getCustomers()).map((c) => c.toMap()).toList(),
      'trips': (await db.getTrips()).map((t) => t.toMap()).toList(),
    };

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ah_transport_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(data));

    await Share.shareXFiles([XFile(file.path)], text: 'AH Transport Gujranwala - Data Backup');
  }

  // TODO: Implement restoreFromFile(File jsonFile) to re-insert records
  // by parsing the same structure produced above. Wire it up in
  // SettingsScreen once you're ready to support restore-from-backup.
}
