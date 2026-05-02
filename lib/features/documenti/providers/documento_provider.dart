import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/features/documenti/models/documento.dart';
import 'package:myscooter/features/documenti/repositories/documento_repository.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/core/notifications/notification_service.dart';

// FIX: Usiamo String per scooterId
final documentoListProvider = StateNotifierProvider.family<DocumentoListNotifier, AsyncValue<List<Documento>>, String>((ref, scooterId) {
  final repository = ref.read(documentoRepoProvider);
  return DocumentoListNotifier(repository, scooterId);
});

class DocumentoListNotifier extends StateNotifier<AsyncValue<List<Documento>>> {
  final DocumentoRepository _repository;
  final String _scooterId;

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

  Future<bool> addDocumento(Documento doc, AppLocalizations l10n) async {
    final result = await _repository.insertDocumento(doc);
    if (result != null) {
      final savedDoc = Documento(id: result, userId: doc.userId, scooterId: doc.scooterId, tipo: doc.tipo, tipoCustom: doc.tipoCustom, dataScadenza: doc.dataScadenza, note: doc.note, nomeFoto: doc.nomeFoto);
      await NotificationService().scheduleDocumentNotifications(savedDoc, l10n);
      await loadDocumenti();
      return true;
    }
    return false;
  }

  Future<bool> updateDocumento(Documento doc, AppLocalizations l10n) async {
    final result = await _repository.updateDocumento(doc);
    if (result) {
      await NotificationService().scheduleDocumentNotifications(doc, l10n);
      await loadDocumenti();
      return true;
    }
    return false;
  }

  Future<bool> deleteDocumento(String id) async { // FIX: String
    final result = await _repository.deleteDocumento(id);
    if (result > 0) {
      await NotificationService().cancelNotifications(id);
      await loadDocumenti();
      return true;
    }
    return false;
  }
}