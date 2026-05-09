import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/features/manutenzione/repositories/manutenzione_repository.dart';

// 1. STREAM PROVIDER: Rimane in ascolto di Firebase
final manutenzioniStreamProvider = StreamProvider.autoDispose.family<List<Manutenzione>, String>((ref, scooterId) {
  final repository = ref.read(manutenzioneRepoProvider);
  return repository.streamManutenzioni(scooterId);
});

// 2. ACTIONS PROVIDER: Gestisce i salvataggi
final manutenzioneActionsProvider = Provider<ManutenzioneActions>((ref) {
  final repository = ref.read(manutenzioneRepoProvider);
  return ManutenzioneActions(repository);
});

class ManutenzioneActions {
  final ManutenzioneRepository _repository;
  ManutenzioneActions(this._repository);

  Future<bool> addManutenzione(Manutenzione m) async {
    final result = await _repository.insertManutenzione(m);
    return result != null;
  }

  Future<bool> updateManutenzione(Manutenzione m) async {
    return await _repository.updateManutenzione(m);
  }

  Future<bool> deleteManutenzione(String id) async {
    final result = await _repository.deleteManutenzione(id);
    return result > 0;
  }
}