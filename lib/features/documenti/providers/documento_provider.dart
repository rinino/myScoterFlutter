import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/features/documenti/models/documento.dart';
import 'package:myscooter/features/documenti/repositories/documento_repository.dart';

// Provider family per gestire i documenti di uno specifico scooter
final documentoListProvider = StateNotifierProvider.family<DocumentoListNotifier, AsyncValue<List<Documento>>, int>((ref, scooterId) {
  final repository = ref.read(documentoRepoProvider);
  return DocumentoListNotifier(repository, scooterId);
});

class DocumentoListNotifier extends StateNotifier<AsyncValue<List<Documento>>> {
  final DocumentoRepository _repository;
  final int _scooterId;

  DocumentoListNotifier(this._repository, this._scooterId) : super(const AsyncValue.loading()) {
    loadDocumenti();
  }

  Future<void> loadDocumenti() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getDocumenti(_scooterId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addDocumento(Documento doc) async {
    final result = await _repository.insertDocumento(doc);
    if (result != null) {
      await loadDocumenti();
      return true;
    }
    return false;
  }

  Future<bool> updateDocumento(Documento doc) async {
    final result = await _repository.updateDocumento(doc);
    if (result) {
      await loadDocumenti();
      return true;
    }
    return false;
  }

  Future<bool> deleteDocumento(int id) async {
    final result = await _repository.deleteDocumento(id);
    if (result > 0) {
      await loadDocumenti();
      return true;
    }
    return false;
  }
}