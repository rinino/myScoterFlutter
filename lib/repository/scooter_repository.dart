// lib/repositories/scooter_repository.dart
import 'package:myscoterflutter/database_helper.dart';
import 'package:myscoterflutter/models/scooter.dart';

class ScooterRepository {
  // --- Singleton Pattern per il Repository ---
  static final ScooterRepository _instance = ScooterRepository._internal();
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  factory ScooterRepository() {
    return _instance;
  }

  ScooterRepository._internal();

  // --- Implementazione dei Metodi CRUD ---

  /// Inserisce un nuovo scooter nel database.
  /// Ritorna l'ID dello scooter inserito.
  Future<int> insertScooter(Scooter scooter) async {
    try {
      final id = await _dbHelper.insertScooter(scooter);
      return id;
    } catch (e) {
      // Gestione degli errori, ad esempio loggare l'errore o lanciare un'eccezione specifica
      print('Errore durante l\'inserimento dello scooter: $e');
      rethrow; // Rilancia l'eccezione per la gestione a un livello superiore
    }
  }

  /// Recupera tutti gli scooter dal database.
  Future<List<Scooter>> getAllScooters() async {
    try {
      final scooters = await _dbHelper.getScooters();
      return scooters;
    } catch (e) {
      print('Errore durante il recupero degli scooter: $e');
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
      print('Errore durante il recupero dello scooter con ID $id: $e');
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
      print('Errore durante il recupero dello scooter con targa $targa: $e');
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
      print('Errore durante l\'aggiornamento dello scooter con ID ${scooter.id}: $e');
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
      print('Errore durante l\'eliminazione dello scooter con ID $id: $e');
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
      print('Errore durante l\'eliminazione di tutti gli scooter: $e');
      rethrow;
    }
  }
}