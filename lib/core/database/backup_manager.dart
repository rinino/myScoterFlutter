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

  // ESPORTAZIONE BACKUP DA FIRESTORE A JSON + ZIP
  static Future<void> exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = currentUserId;
    if (userId == null) throw Exception("Utente non autenticato");

    // 1. Lettura Dati dal Cloud
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

    // 2. Aggiunta Foto Locali
    Map<String, String> imagesData = {};
    final docsDir = await getApplicationDocumentsDirectory();

    void addImage(String? imgName) {
      // FIX CRITICO: Se è un link al cloud, ignoriamo perché il dato è già al sicuro online
      if (imgName != null && !imgName.startsWith('http')) {
        final f = File(p.join(docsDir.path, imgName));
        if (f.existsSync()) imagesData[imgName] = base64Encode(f.readAsBytesSync());
      }
    }

    for (var s in scooters) { addImage(s['imgName'] as String?); }
    for (var m in manutenzioni) { addImage(m['nomeFoto'] as String?); }
    for (var d in documenti) { addImage(d['nomeFoto'] as String?); }

    // 3. Creazione JSON
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

    await File(zipPath).writeAsBytes(zipData!);
    final xFile = XFile(zipPath, mimeType: 'application/octet-stream');
    await SharePlus.instance.share(ShareParams(files: [xFile], subject: l10n.backupShareSubject, text: l10n.backupShareText));
  }

  // RIPRISTINO BACKUP: DA JSON A FIRESTORE
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

    // 1. WIPING DATI VECCHI SUL CLOUD
    final collections = ["scooters", "rifornimenti", "manutenzioni", "documenti"];
    for (var coll in collections) {
      final snap = await db.collection(coll).where("userId", isEqualTo: userId).get();
      for (var doc in snap.docs) {
        final data = doc.data();
        final fileName = data["nomeFoto"] as String? ?? data["imgName"] as String?;
        // FIX CRITICO: Eliminiamo solo se era un file locale convertito in storage (senza http)
        if (fileName != null && !fileName.startsWith('http')) {
          try { await storage.ref("images/$userId/$fileName").delete(); } catch(_) {}
        }
        await doc.reference.delete();
      }
    }

    // 2. BATCH WRITING SU FIRESTORE
    WriteBatch batch = db.batch();
    int count = 0;

    Future<void> commitIfNeed() async {
      count++;
      if (count >= 490) {
        await batch.commit();
        batch = db.batch();
        count = 0;
      }
    }

    void restoreTimestamps(Map<String, dynamic> data, String dateField) {
      if (data[dateField] != null) {
        data[dateField] = Timestamp.fromDate(DateTime.parse(data[dateField]));
      }
    }

    for (var s in map['scooters']) {
      s['userId'] = userId;
      final docId = s['id'] ?? db.collection('scooters').doc().id;
      s.remove('id');
      batch.set(db.collection('scooters').doc(docId), s);
      await commitIfNeed();
    }

    for (var r in map['rifornimenti']) {
      r['userId'] = userId;
      restoreTimestamps(r, 'dataRifornimento');
      final docId = r['id'] ?? db.collection('rifornimenti').doc().id;
      r.remove('id');
      batch.set(db.collection('rifornimenti').doc(docId), r);
      await commitIfNeed();
    }

    if (map['manutenzioni'] != null) {
      for (var m in map['manutenzioni']) {
        m['userId'] = userId;
        restoreTimestamps(m, 'data');
        final docId = m['id'] ?? db.collection('manutenzioni').doc().id;
        m.remove('id');
        batch.set(db.collection('manutenzioni').doc(docId), m);
        await commitIfNeed();
      }
    }

    if (map['documenti'] != null) {
      for (var d in map['documenti']) {
        d['userId'] = userId;
        restoreTimestamps(d, 'dataScadenza');
        final docId = d['id'] ?? db.collection('documenti').doc().id;
        d.remove('id');
        batch.set(db.collection('documenti').doc(docId), d);
        await commitIfNeed();
      }
    }

    await batch.commit();

    // 3. RIPRISTINO FOTO IN LOCALE E CLOUD
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesMap = map['images'] as Map<String, dynamic>? ?? {};

    for (var entry in imagesMap.entries) {
      final imgData = base64Decode(entry.value);
      final fileURL = File(p.join(docsDir.path, entry.key));
      await fileURL.writeAsBytes(imgData);

      final storageRef = storage.ref().child("images/$userId/${entry.key}");
      storageRef.putData(imgData);
    }

    return true;
  }
}