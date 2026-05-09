import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myscooter/features/documenti/models/documento.dart';

class DocumentoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'documenti';

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // NUOVO: Stream in tempo reale con ordinamento
  Stream<List<Documento>> streamDocumenti(String scooterId) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _db
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('scooterId', isEqualTo: scooterId)
        .snapshots()
        .map((snapshot) {
      var docs = snapshot.docs.map((doc) => Documento.fromMap(doc.data(), doc.id)).toList();

      // Manteniamo il tuo ordinamento personalizzato per le scadenze
      docs.sort((a, b) {
        if (a.dataScadenza == null && b.dataScadenza == null) return 0;
        if (a.dataScadenza == null) return 1;
        if (b.dataScadenza == null) return -1;
        return a.dataScadenza!.compareTo(b.dataScadenza!);
      });

      return docs;
    });
  }

  Future<String?> insertDocumento(Documento documento) async {
    final userId = _currentUserId;
    if (userId == null) return null;
    documento.userId = userId;
    final ref = await _db.collection(_collectionName).add(documento.toMap());
    return ref.id;
  }

  Future<List<Documento>> getDocumenti(String scooterId) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _db
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('scooterId', isEqualTo: scooterId)
        .get();

    var docs = snapshot.docs.map((doc) => Documento.fromMap(doc.data(), doc.id)).toList();

    docs.sort((a, b) {
      if (a.dataScadenza == null && b.dataScadenza == null) return 0;
      if (a.dataScadenza == null) return 1;
      if (b.dataScadenza == null) return -1;
      return a.dataScadenza!.compareTo(b.dataScadenza!);
    });

    return docs;
  }

  Future<bool> updateDocumento(Documento documento) async {
    if (documento.id == null || _currentUserId == null) return false;
    try {
      await _db.collection(_collectionName).doc(documento.id).set(documento.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> deleteDocumento(String id) async {
    try {
      await _db.collection(_collectionName).doc(id).delete();
      return 1;
    } catch (e) {
      return 0;
    }
  }
}