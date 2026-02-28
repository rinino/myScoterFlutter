import '../../../core/database/database_helper.dart';
import '../model/scooter.dart';

class ScooterRepository {
  // 1. Variabile per il DatabaseHelper che verrà iniettata
  final DatabaseHelper _dbHelper;

  // 2. Costruttore che richiede il DatabaseHelper
  ScooterRepository(this._dbHelper);

  // --- Implementazione dei Metodi CRUD ---
  // (Lascia tutto il resto identico, i metodi useranno _dbHelper normalmente!)

  Future<int> insertScooter(Scooter scooter) async {
    try {
      final id = await _dbHelper.insertScooter(scooter);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  /// Recupera tutti gli scooter dal database.
  Future<List<Scooter>> getAllScooters() async {
    try {
      final scooters = await _dbHelper.getScooters();
      return scooters;
    } catch (e) {
      rethrow;
    }
  }

  /// Recupera un singolo scooter per ID.
  /// Ritorna null se lo scooter non viene trovato.
  Future<Scooter?> getScooterById(int id) async {
    try {
      final scooter = await _dbHelper.getScooterById(id);
      return scooter;
    } catch (e) {
      rethrow;
    }
  }

  /// Recupera un singolo scooter per targa.
  /// Ritorna null se lo scooter non viene trovato.
  Future<Scooter?> getScooterByTarga(String targa) async {
    try {
      final scooter = await _dbHelper.getScooterByTarga(targa);
      return scooter;
    } catch (e) {
      rethrow;
    }
  }

  /// Aggiorna uno scooter esistente nel database.
  /// Ritorna il numero di righe aggiornate (normalmente 1 se l'update ha successo).
  Future<int> updateScooter(Scooter scooter) async {
    try {
      final rowsAffected = await _dbHelper.updateScooter(scooter);
      return rowsAffected;
    } catch (e) {
      rethrow;
    }
  }

  /// Cancella uno scooter dal database dato il suo ID.
  /// Ritorna il numero di righe eliminate (normalmente 1 se la cancellazione ha successo).
  Future<int> deleteScooter(int id) async {
    try {
      final rowsAffected = await _dbHelper.deleteScooter(id);
      return rowsAffected;
    } catch (e) {
      rethrow;
    }
  }

  /// Cancella tutti gli scooter dalla tabella.
  /// Ritorna il numero di righe eliminate.
  Future<int> deleteAllScooters() async {
    try {
      final rowsAffected = await _dbHelper.deleteAllScooters();
      return rowsAffected;
    } catch (e) {
      rethrow;
    }
  }
}
