import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myscooter/core/database/database_helper.dart';
import 'package:myscooter/core/services/cloud_storage_manager.dart';

class MigrationManager {
  static final MigrationManager shared = MigrationManager._internal();
  MigrationManager._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> eseguiMigrazioneSeNecessario({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final isMigrated = prefs.getBool('isMigratedToCloud_$userId') ?? false;

    // Se abbiamo già migrato, usciamo subito!
    if (isMigrated) return;

    debugPrint("ADR: 🚀 INIZIO MIGRAZIONE DA SQLITE A FIRESTORE...");

    try {
      final vecchiScooters = await DatabaseHelper.shared.getAllScootersRaw();
      final vecchiRifornimenti = await DatabaseHelper.shared.getAllRifornimentiRaw();
      final vecchieManutenzioni = await DatabaseHelper.shared.getAllManutenzioniRaw();
      final vecchiDocumenti = await DatabaseHelper.shared.getAllDocumentiRaw();

      // Se non c'è nulla in SQLite, segniamo come migrato e usciamo
      if (vecchiScooters.isEmpty) {
        await prefs.setBool('isMigratedToCloud_$userId', true);
        debugPrint("ADR: 🏁 Nessun dato locale trovato. Migrazione saltata.");
        return;
      }

      WriteBatch batch = _db.batch();

      // MAPPA CRITICA: Collega i vecchi ID (int) ai nuovi ID (String di Firebase)
      Map<int, String> mappaIdScooter = {};

      // 1. MIGRAZIONE SCOOTERS
      for (var s in vecchiScooters) {
        final docRef = _db.collection('scooters').doc();
        final vecchioId = s['id'] as int;
        mappaIdScooter[vecchioId] = docRef.id;

        final newScooterData = Map<String, dynamic>.from(s);
        newScooterData.remove('id');
        newScooterData['userId'] = userId;

        // Rinominare imgPath in imgName per allineamento
        if (newScooterData.containsKey('imgPath')) {
          newScooterData['imgName'] = newScooterData['imgPath'];
          newScooterData.remove('imgPath');
        }

        // Upload immagine
        if (newScooterData['imgName'] != null) {
          final file = File(newScooterData['imgName']);
          if (file.existsSync()) {
            CloudStorageManager.shared.uploadImageSilently(fileName: file.path.split('/').last, localFile: file);
          }
        }

        batch.set(docRef, newScooterData);
      }

      // 2. MIGRAZIONE RIFORNIMENTI
      for (var r in vecchiRifornimenti) {
        final vecchioScooterId = r['idScooter'] as int;
        final nuovoScooterId = mappaIdScooter[vecchioScooterId];
        if (nuovoScooterId == null) continue;

        final docRef = _db.collection('rifornimenti').doc();
        final newRifData = Map<String, dynamic>.from(r);
        newRifData.remove('id');
        newRifData['userId'] = userId;
        newRifData['idScooter'] = nuovoScooterId;

        // Convertire int in Timestamp per la data
        if (newRifData['dataRifornimento'] != null) {
          final ms = newRifData['dataRifornimento'] as int;
          newRifData['dataRifornimento'] = Timestamp.fromMillisecondsSinceEpoch(ms);
        }

        batch.set(docRef, newRifData);
      }

      // 3. MIGRAZIONE MANUTENZIONI
      for (var m in vecchieManutenzioni) {
        final vecchioScooterId = m['scooterId'] ?? m['idScooter']; // Gestione retrocompatibilità
        if (vecchioScooterId == null) continue;

        final nuovoScooterId = mappaIdScooter[vecchioScooterId as int];
        if (nuovoScooterId == null) continue;

        final docRef = _db.collection('manutenzioni').doc();
        final newManData = Map<String, dynamic>.from(m);
        newManData.remove('id');
        newManData.remove('idScooter');
        newManData['userId'] = userId;
        newManData['scooterId'] = nuovoScooterId;

        if (newManData['data'] != null) {
          newManData['data'] = Timestamp.fromMillisecondsSinceEpoch(newManData['data'] as int);
        }

        // Upload immagine
        if (newManData['nomeFoto'] != null) {
          final file = File(newManData['nomeFoto']);
          if (file.existsSync()) CloudStorageManager.shared.uploadImageSilently(fileName: file.path.split('/').last, localFile: file);
        }

        batch.set(docRef, newManData);
      }

      // 4. MIGRAZIONE DOCUMENTI
      for (var d in vecchiDocumenti) {
        final vecchioScooterId = d['scooterId'] ?? d['idScooter'];
        if (vecchioScooterId == null) continue;

        final nuovoScooterId = mappaIdScooter[vecchioScooterId as int];
        if (nuovoScooterId == null) continue;

        final docRef = _db.collection('documenti').doc();
        final newDocData = Map<String, dynamic>.from(d);
        newDocData.remove('id');
        newDocData.remove('idScooter');
        newDocData['userId'] = userId;
        newDocData['scooterId'] = nuovoScooterId;

        if (newDocData['dataScadenza'] != null) {
          newDocData['dataScadenza'] = Timestamp.fromMillisecondsSinceEpoch(newDocData['dataScadenza'] as int);
        }

        if (newDocData['nomeFoto'] != null) {
          final file = File(newDocData['nomeFoto']);
          if (file.existsSync()) CloudStorageManager.shared.uploadImageSilently(fileName: file.path.split('/').last, localFile: file);
        }

        batch.set(docRef, newDocData);
      }

      // COMMIT FINALE
      await batch.commit();

      // Impostiamo il flag per non ripetere MAI PIÙ questa operazione
      await prefs.setBool('isMigratedToCloud_$userId', true);
      debugPrint("ADR: ✅ MIGRAZIONE COMPLETATA CON SUCCESSO!");

    } catch (e) {
      debugPrint("ADR: ❌ ERRORE DURANTE LA MIGRAZIONE: $e");
    }
  }
}