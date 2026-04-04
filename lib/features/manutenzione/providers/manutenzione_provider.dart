import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/features/manutenzione/repositories/manutenzione_repository.dart';

// Provider che gestisce la lista delle manutenzioni per un dato scooter (tramite family)
final manutenzioneListProvider = StateNotifierProvider.family<ManutenzioneListNotifier, AsyncValue<List<Manutenzione>>, int>((ref, scooterId) {
  final repository = ref.read(manutenzioneRepoProvider);
  return ManutenzioneListNotifier(repository, scooterId);
});

class ManutenzioneListNotifier extends StateNotifier<AsyncValue<List<Manutenzione>>> {
  final ManutenzioneRepository _repository;
  final int _scooterId;

  ManutenzioneListNotifier(this._repository, this._scooterId) : super(const AsyncValue.loading()) {
    loadManutenzioni();
  }

  // Carica i dati dal DB
  Future<void> loadManutenzioni() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getManutenzioni(_scooterId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Aggiunge una manutenzione e ricarica
  Future<bool> addManutenzione(Manutenzione m) async {
    final result = await _repository.insertManutenzione(m);
    if (result != null) {
      await loadManutenzioni();
      return true;
    }
    return false;
  }

  // Aggiorna una manutenzione e ricarica
  Future<bool> updateManutenzione(Manutenzione m) async {
    final result = await _repository.updateManutenzione(m);
    if (result) {
      await loadManutenzioni();
      return true;
    }
    return false;
  }

  // Elimina una manutenzione e ricarica
  Future<bool> deleteManutenzione(int id) async {
    final result = await _repository.deleteManutenzione(id);
    if (result > 0) {
      await loadManutenzioni();
      return true;
    }
    return false;
  }
}