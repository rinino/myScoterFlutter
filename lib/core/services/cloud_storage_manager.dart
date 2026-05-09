import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CloudStorageManager {
  // Singleton
  static final CloudStorageManager shared = CloudStorageManager._internal();
  CloudStorageManager._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Carica l'immagine in background in modo silente
  void uploadImageSilently({required String fileName, required File localFile}) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final storageRef = _storage.ref().child("images/$userId/$fileName");
      final metadata = SettableMetadata(contentType: "image/jpeg");

      storageRef.putFile(localFile, metadata).then((_) {
        debugPrint("ADR: ☁️ Immagine caricata con successo su Storage: $fileName");
      }).catchError((error) {
        debugPrint("ADR: ❌ Errore caricamento Storage: $error");
      });
    } catch (e) {
      debugPrint("ADR: ❌ Errore caricamento Storage: $e");
    }
  }

  // Elimina l'immagine vecchia dal Cloud in background
  void deleteImageSilently({required String fileName}) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final storageRef = _storage.ref().child("images/$userId/$fileName");
      storageRef.delete().then((_) {
        debugPrint("ADR: 🗑️ Immagine orfana eliminata dal Cloud: $fileName");
      }).catchError((error) {
        debugPrint("ADR: ❌ Errore eliminazione Storage: $error");
      });
    } catch (e) {
      debugPrint("ADR: ❌ Errore eliminazione Storage: $e");
    }
  }
}