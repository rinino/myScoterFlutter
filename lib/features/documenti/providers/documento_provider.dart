import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/features/documenti/models/documento.dart';
import 'package:myscooter/features/documenti/repositories/documento_repository.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/core/notifications/notification_service.dart';

// 1. STREAM PROVIDER: Gestisce il tempo reale
final documentiStreamProvider = StreamProvider.autoDispose.family<List<Documento>, String>((ref, scooterId) {
  final repository = ref.read(documentoRepoProvider);
  return repository.streamDocumenti(scooterId);
});

// 2. ACTIONS PROVIDER: Gestisce salvataggi e notifiche locali
final documentoActionsProvider = Provider<DocumentoActions>((ref) {
  final repository = ref.read(documentoRepoProvider);
  return DocumentoActions(repository);
});

class DocumentoActions {
  final DocumentoRepository _repository;
  DocumentoActions(this._repository);

  Future<bool> addDocumento(Documento doc, AppLocalizations l10n) async {
    final result = await _repository.insertDocumento(doc);
    if (result != null) {
      final savedDoc = Documento(
          id: result,
          userId: doc.userId,
          scooterId: doc.scooterId,
          tipo: doc.tipo,
          tipoCustom: doc.tipoCustom,
          dataScadenza: doc.dataScadenza,
          note: doc.note,
          nomeFoto: doc.nomeFoto
      );
      await NotificationService().scheduleDocumentNotifications(savedDoc, l10n);
      return true;
    }
    return false;
  }

  Future<bool> updateDocumento(Documento doc, AppLocalizations l10n) async {
    final result = await _repository.updateDocumento(doc);
    if (result) {
      await NotificationService().scheduleDocumentNotifications(doc, l10n);
      return true;
    }
    return false;
  }

  Future<bool> deleteDocumento(String id) async {
    final result = await _repository.deleteDocumento(id);
    if (result > 0) {
      await NotificationService().cancelNotifications(id);
      return true;
    }
    return false;
  }
}