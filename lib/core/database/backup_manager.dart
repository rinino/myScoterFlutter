// lib/core/database/backup_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive_io.dart';
import 'package:myscooter/l10n/app_localizations.dart';

import 'database_helper.dart';

class BackupManager {
  /// Genera un backup ZIP contenente il DB (inclusi i file WAL/SHM) e tutte le immagini salvate
  static Future<void> exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint("📦 [BACKUP] Inizio procedura di esportazione...");

    // 1. Percorsi sorgente
    final dbFolderPath = await getDatabasesPath();
    final docDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(dbFolderPath);

    // 2. Prepara il percorso del file ZIP
    final formatter = DateFormat('yyyy-MM-dd_HH-mm');
    final dateString = formatter.format(DateTime.now());
    final zipFileName = 'MyScooter_Backup_$dateString.zip';
    final zipPath = p.join(docDir.path, zipFileName);

    if (await File(zipPath).exists()) {
      await File(zipPath).delete();
    }

    // BYPASS DEL BUG DI ZipFileEncoder: Usiamo l'Archive in RAM
    final archive = Archive();

    // 3. Aggiunta dei file del Database
    final dbFiles = dbDir.listSync().where((f) => p.basename(f.path).startsWith('scooter_database.db'));

    if (dbFiles.isEmpty) {
      throw Exception("Nessun database trovato da esportare.");
    }

    for (var file in dbFiles) {
      if (file is File) {
        debugPrint("📦 [BACKUP] Lettura DB file: ${p.basename(file.path)}");
        final bytes = await file.readAsBytes(); // Legge il file dal disco
        archive.addFile(ArchiveFile(p.basename(file.path), bytes.length, bytes)); // Lo mette nell'archivio
      }
    }

    // 4. Aggiunta delle Immagini
    final List<FileSystemEntity> docFiles = docDir.listSync();
    int imgCount = 0;
    for (var file in docFiles) {
      if (file is File) {
        final ext = p.extension(file.path).toLowerCase();
        if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') {
          final bytes = await file.readAsBytes(); // Legge la foto
          archive.addFile(ArchiveFile(p.basename(file.path), bytes.length, bytes));
          imgCount++;
        }
      }
    }
    debugPrint("📦 [BACKUP] Aggiunte $imgCount immagini al backup.");

    debugPrint("📦 [BACKUP] Codifica in ZIP e scrittura su disco...");

    // 5. Codifica l'intero archivio e salvalo su disco
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception("Errore critico durante la generazione dello ZIP.");
    }

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipData, flush: true);

    // 6. Controllo finale di sicurezza
    final zipSize = await zipFile.length();
    debugPrint("📦 [BACKUP] Creazione completata. Dimensione ZIP: $zipSize bytes");

    if (zipSize <= 22) {
      throw Exception("Errore critico: Il file ZIP generato è vuoto ($zipSize bytes).");
    }

    debugPrint("📦 [BACKUP] Avvio condivisione...");

    // 7. Condividi lo ZIP
    final xFile = XFile(zipPath, mimeType: 'application/zip');

    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: l10n.backupShareSubject,
        text: l10n.backupShareText,
      ),
    );
  }

  /// Importa l'archivio ZIP, estrae il DB e ripristina le immagini
  static Future<bool> importBackup(DatabaseHelper dbHelper) async {
    debugPrint("🔄 [RESTORE] Inizio procedura di ripristino...");

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        debugPrint("🔄 [RESTORE] Selezione file annullata dall'utente.");
        return false;
      }

      final zipFilePath = result.files.single.path!;
      debugPrint("🔄 [RESTORE] File selezionato: $zipFilePath");

      final dbFolderPath = await getDatabasesPath();
      final docDir = await getApplicationDocumentsDirectory();
      final mainDbPath = p.join(dbFolderPath, 'scooter_database.db');

      debugPrint("🔄 [RESTORE] Chiusura connessione database corrente...");
      await dbHelper.closeDb();

      if (await databaseExists(mainDbPath)) {
        debugPrint("🔄 [RESTORE] Distruzione vecchio database e cache sqlite in corso...");
        await deleteDatabase(mainDbPath);
      }

      debugPrint("🔄 [RESTORE] Lettura file ZIP...");
      final bytes = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      bool dbRipristinato = false;
      int imgCount = 0;

      for (final file in archive) {
        if (!file.isFile) continue;

        final filename = p.basename(file.name);
        final fileData = file.content as List<int>; // Estraiamo i byte

        if (filename.startsWith('scooter_database.db')) {
          final outPath = p.join(dbFolderPath, filename);
          await File(outPath).writeAsBytes(fileData, flush: true);

          if (filename == 'scooter_database.db') dbRipristinato = true;
          debugPrint("🔄 [RESTORE] Ripristinato file DB: $filename");
        }
        else if (filename.toLowerCase().endsWith('.jpg') ||
            filename.toLowerCase().endsWith('.png') ||
            filename.toLowerCase().endsWith('.jpeg')) {
          final outPath = p.join(docDir.path, filename);
          await File(outPath).writeAsBytes(fileData, flush: true);
          imgCount++;
        }
      }

      debugPrint("🔄 [RESTORE] Ripristino completato! File DB trovati: $dbRipristinato, Immagini ripristinate: $imgCount");
      return dbRipristinato;

    } catch (e, stack) {
      debugPrint("❌ [RESTORE ERROR] Errore critico durante il ripristino: $e");
      debugPrint(stack.toString());
      return false;
    }
  }
}