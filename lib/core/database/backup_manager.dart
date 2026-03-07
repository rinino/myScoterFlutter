// lib/core/database/backup_manager.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class BackupManager {

  /// Genera il backup esportando il file .db
  static Future<void> exportBackup() async {
    final dbPath = join(await getDatabasesPath(), 'scooter_database.db');
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception("Database inesistente.");
    }

    // Copiamo il db in una cartella temporanea rinominandolo per renderlo riconoscibile
    final tempDir = await getTemporaryDirectory();
    final backupPath = join(tempDir.path, 'myscooter_backup_${DateTime.now().millisecondsSinceEpoch}.scooterbackup');
    final backupFile = await dbFile.copy(backupPath);

    // Apriamo la tendina di condivisione nativa (WhatsApp, Drive, File, ecc.)
    await Share.shareXFiles([XFile(backupFile.path)], text: 'Backup MyScooter Data');
  }

  /// Importa il file scelto dall'utente e sovrascrive il database attuale
  static Future<bool> importBackup(DatabaseHelper dbHelper) async {
    // Apriamo il file picker (gestisce lui iCloud e Drive nativamente!)
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final importPath = result.files.single.path!;
      final importedFile = File(importPath);

      // 1. Chiudiamo il database corrente per evitare blocchi o corruzioni
      await dbHelper.closeDb();

      // 2. Otteniamo il percorso in cui deve stare il database vero
      final dbPath = join(await getDatabasesPath(), 'scooter_database.db');

      // 3. Sovrascriviamo brutalmente
      await importedFile.copy(dbPath);

      return true; // Successo!
    }

    return false; // Utente ha annullato
  }
}