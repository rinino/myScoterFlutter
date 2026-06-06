import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class BackupManager {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // =========================================================================
  // 1. ESPORTAZIONE (Nessuna modifica sostanziale alla tua logica perfetta)
  // =========================================================================
  static Future<void> exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = currentUserId;
    if (userId == null) throw Exception("Utente non autenticato");

    final scootersSnap = await db.collection("scooters").where("userId", isEqualTo: userId).get();
    final scooters = scootersSnap.docs.map((d) => d.data()..['id'] = d.id).toList();

    void convertTimestamps(Map<String, dynamic> map, String dateField) {
      if (map[dateField] is Timestamp) {
        map[dateField] = (map[dateField] as Timestamp).toDate().toIso8601String();
      }
    }

    final rifSnap = await db.collection("rifornimenti").where("userId", isEqualTo: userId).get();
    final rifornimenti = rifSnap.docs.map((d) {
      final data = d.data()..['id'] = d.id;
      convertTimestamps(data, 'dataRifornimento');
      return data;
    }).toList();

    final manSnap = await db.collection("manutenzioni").where("userId", isEqualTo: userId).get();
    final manutenzioni = manSnap.docs.map((d) {
      final data = d.data()..['id'] = d.id;
      convertTimestamps(data, 'data');
      return data;
    }).toList();

    final docSnap = await db.collection("documenti").where("userId", isEqualTo: userId).get();
    final documenti = docSnap.docs.map((d) {
      final data = d.data()..['id'] = d.id;
      convertTimestamps(data, 'dataScadenza');
      return data;
    }).toList();

    Map<String, String> imagesData = {};
    final docsDir = await getApplicationDocumentsDirectory();

    void addImage(String? imgName) {
      if (imgName != null && !imgName.startsWith('http')) {
        final fileName = p.basename(imgName);
        final f = File(p.join(docsDir.path, fileName));
        if (f.existsSync()) imagesData[fileName] = base64Encode(f.readAsBytesSync());
      }
    }

    for (var s in scooters) { addImage(s['imgName'] as String?); }
    for (var m in manutenzioni) { addImage(m['nomeFoto'] as String?); }
    for (var d in documenti) { addImage(d['nomeFoto'] as String?); }

    final backupMap = {
      'version': 3,
      'scooters': scooters,
      'rifornimenti': rifornimenti,
      'manutenzioni': manutenzioni,
      'documenti': documenti,
      'images': imagesData,
    };

    final jsonString = jsonEncode(backupMap);
    var archive = Archive();
    archive.addFile(ArchiveFile('backup.json', jsonString.length, utf8.encode(jsonString)));
    final zipData = ZipEncoder().encode(archive);

    final formatter = DateFormat('yyyyMMdd_HHmm');
    final dateString = formatter.format(DateTime.now());
    final zipPath = p.join(docsDir.path, 'MyScooter_CloudBackup_$dateString.scooterbackup');

    await File(zipPath).writeAsBytes(zipData);
    final xFile = XFile(zipPath, mimeType: 'application/octet-stream');
    await SharePlus.instance.share(ShareParams(files: [xFile], subject: l10n.backupShareSubject, text: l10n.backupShareText));
  }

  // =========================================================================
  // 2. RIPRISTINO (Completamente riscritto per Efficienza e Batch Firebase)
  // =========================================================================
  static Future<bool> importBackup() async {
    final userId = currentUserId;
    if (userId == null) return false;

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return false;

    final bytes = await File(result.files.single.path!).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? jsonFile;
    for (final file in archive) {
      if (file.name == 'backup.json') {
        jsonFile = file;
        break;
      }
    }
    if (jsonFile == null) return false;

    final jsonString = utf8.decode(jsonFile.content as List<int>);
    final map = jsonDecode(jsonString);

    // =========================================================
    // FASE A: WIPE DEL DATABASE ESISTENTE (Tramite Batch)
    // =========================================================
    WriteBatch wipeBatch = db.batch();
    int wipeCount = 0;

    Future<void> commitWipeIfNeed() async {
      wipeCount++;
      if (wipeCount >= 490) { // Limite massimo di Firestore per singolo batch
        await wipeBatch.commit();
        wipeBatch = db.batch();
        wipeCount = 0;
      }
    }

    final collections = ["scooters", "rifornimenti", "manutenzioni", "documenti"];
    for (var coll in collections) {
      // Purtroppo per cancellare dobbiamo leggere i doc ID. È l'unica via su Firebase.
      final snap = await db.collection(coll).where("userId", isEqualTo: userId).get();
      for (var doc in snap.docs) {
        final data = doc.data();
        final fileNameRaw = data["nomeFoto"] as String? ?? data["imgName"] as String?;

        // Cancellazione Immagini Vecchie in BACKGROUND (fire-and-forget, non blocca l'app)
        if (fileNameRaw != null && !fileNameRaw.startsWith('http')) {
          final fileName = p.basename(fileNameRaw);
          storage.ref("images/$userId/$fileName").delete().catchError((_) {});
        }

        // Accoda la cancellazione del documento al Batch
        wipeBatch.delete(doc.reference);
        await commitWipeIfNeed();
      }
    }
    // Eseguiamo il rimanente del batch di wipe
    if (wipeCount > 0) {
      await wipeBatch.commit();
    }

    // =========================================================
    // FASE B: INSERIMENTO DEI DATI DEL BACKUP (Tramite Batch)
    // =========================================================
    WriteBatch insertBatch = db.batch();
    int insertCount = 0;

    Future<void> commitInsertIfNeed() async {
      insertCount++;
      if (insertCount >= 490) {
        await insertBatch.commit();
        insertBatch = db.batch();
        insertCount = 0;
      }
    }

    void restoreTimestamps(Map<String, dynamic> data, String dateField) {
      if (data[dateField] != null) {
        data[dateField] = Timestamp.fromDate(DateTime.parse(data[dateField]));
      }
    }

    // --- Scooter ---
    for (var s in map['scooters']) {
      s['userId'] = userId;
      final docId = s['id'] ?? db.collection('scooters').doc().id;
      s.remove('id');
      insertBatch.set(db.collection('scooters').doc(docId), s);
      await commitInsertIfNeed();
    }

    // --- Rifornimenti ---
    for (var r in map['rifornimenti']) {
      r['userId'] = userId;
      restoreTimestamps(r, 'dataRifornimento');
      final docId = r['id'] ?? db.collection('rifornimenti').doc().id;
      r.remove('id');
      insertBatch.set(db.collection('rifornimenti').doc(docId), r);
      await commitInsertIfNeed();
    }

    // --- Manutenzioni ---
    if (map['manutenzioni'] != null) {
      for (var m in map['manutenzioni']) {
        m['userId'] = userId;
        restoreTimestamps(m, 'data');
        final docId = m['id'] ?? db.collection('manutenzioni').doc().id;
        m.remove('id');
        insertBatch.set(db.collection('manutenzioni').doc(docId), m);
        await commitInsertIfNeed();
      }
    }

    // --- Documenti ---
    if (map['documenti'] != null) {
      for (var d in map['documenti']) {
        d['userId'] = userId;
        restoreTimestamps(d, 'dataScadenza');
        final docId = d['id'] ?? db.collection('documenti').doc().id;
        d.remove('id');
        insertBatch.set(db.collection('documenti').doc(docId), d);
        await commitInsertIfNeed();
      }
    }

    // Eseguiamo il rimanente del batch di inserimento in un solo colpo di rete!
    if (insertCount > 0) {
      await insertBatch.commit();
    }

    // =========================================================
    // FASE C: RIPRISTINO DELLE IMMAGINI (File System + Storage)
    // =========================================================
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesMap = map['images'] as Map<String, dynamic>? ?? {};

    for (var entry in imagesMap.entries) {
      final imgData = base64Decode(entry.value);

      // 1. Salviamo in locale (immediato per la UI)
      final localFile = File(p.join(docsDir.path, entry.key));
      await localFile.writeAsBytes(imgData);

      // 2. Carichiamo sul Cloud Storage in BACKGROUND (non blocchiamo il caricamento UI)
      final storageRef = storage.ref().child("images/$userId/${entry.key}");
      final metadata = SettableMetadata(contentType: "image/jpeg");
      storageRef.putData(imgData, metadata).catchError((_) {}); // Fire and forget!
    }

    return true; // Il ripristino è completato, la UI si sblocca subito!
  }
}