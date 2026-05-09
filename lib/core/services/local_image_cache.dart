import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;

class LocalImageCache {
  static final LocalImageCache shared = LocalImageCache._internal();
  LocalImageCache._internal();

  Future<File?> getImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http')) return null;

    final fileName = imagePath.split('/').last;
    final docsDir = await getApplicationDocumentsDirectory();
    final localFile = File(p.join(docsDir.path, fileName));

    // 1. OTTIMIZZAZIONE CACHE: Se il file esiste già, caricalo istantaneamente!
    if (await localFile.exists()) {
      return localFile;
    }

    // 2. SE NON ESISTE (Telefono nuovo o foto aggiornata da un altro dispositivo) -> Scarica dal Cloud!
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child("images/$userId/$fileName");
      final data = await storageRef.getData(10 * 1024 * 1024); // max 10MB

      if (data != null) {
        await localFile.writeAsBytes(data, flush: true);
        debugPrint("ADR: ✅ Immagine scaricata e cachata da Firebase: $fileName");
        return localFile;
      }
    } catch (e) {
      debugPrint("ADR: ❌ Immagine non trovata su Firebase Storage: $fileName");
    }

    return null;
  }

  // Chiamato solo al Logout o Cambio Account
  Future<void> clearCache() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final files = docsDir.listSync();
    for (var file in files) {
      if (file is File && (file.path.toLowerCase().endsWith('.jpg') || file.path.toLowerCase().endsWith('.png'))) {
        await file.delete();
      }
    }
    debugPrint("ADR: 🧹 Cache locale svuotata.");
  }
}

class CloudSyncImage extends StatelessWidget {
  final String? imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CloudSyncImage({super.key, required this.imagePath, this.fit = BoxFit.cover, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) return _placeholder();
    if (imagePath!.startsWith('http')) {
      return Image.network(imagePath!, fit: fit, width: width, height: height, errorBuilder: (c,e,s) => _placeholder());
    }

    return FutureBuilder<File?>(
      future: LocalImageCache.shared.getImage(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (snapshot.hasData && snapshot.data != null) {
          // Usiamo ValueKey per forzare il refresh visivo se il path cambia
          return Image.file(snapshot.data!, fit: fit, width: width, height: height, key: ValueKey(snapshot.data!.path));
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() => Container(color: Colors.grey[200], width: width, height: height, child: const Icon(Icons.broken_image, color: Colors.grey));
}