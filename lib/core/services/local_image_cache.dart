import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;

class LocalImageCache {
  // Singleton
  static final LocalImageCache shared = LocalImageCache._internal();
  LocalImageCache._internal();

  Future<File?> getImage(String imageName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(docsDir.path, imageName));

    // 1. Controllo sul Disco Rigido (Veloce, Flutter gestisce la RAM automaticamente tramite Image.file)
    if (await file.exists()) {
      return file;
    }

    // 2. Fallback Cloud: L'utente ha cambiato telefono! Scarichiamo da Firebase
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child("images/$userId/$imageName");

      // Limite 10MB per il download di sicurezza come su iOS
      final data = await storageRef.getData(10 * 1024 * 1024);

      if (data != null) {
        // Salva sul Disco per evitare di riscaricarla al prossimo avvio!
        await file.writeAsBytes(data);
        debugPrint("ADR: Immagine recuperata dal Cloud e salvata in locale: $imageName");
        return file;
      }
    } catch (e) {
      debugPrint("ADR: Immagine non trovata né in locale né sul cloud: $e");
    }

    return null;
  }
}