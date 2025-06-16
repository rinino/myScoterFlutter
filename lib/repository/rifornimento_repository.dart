import 'package:myscoterflutter/database_helper.dart';
import 'package:myscoterflutter/models/rifornimento.dart'; // Importa il modello Rifornimento

class RifornimentoRepository {
  // --- Singleton Pattern per il Repository ---
  static final RifornimentoRepository _instance = RifornimentoRepository._internal();
  static final DatabaseHelper _dbHelper = DatabaseHelper(); // Utilizza l'unica istanza di DatabaseHelper

  factory RifornimentoRepository() {
    return _instance;
  }

  RifornimentoRepository._internal();

  // --- Implementazione dei Metodi CRUD per Rifornimento ---

  /// Inserisce un nuovo rifornimento nel database.
  /// Ritorna l'ID del rifornimento inserito, o null in caso di errore.
  Future<int?> insertRifornimento(Rifornimento rifornimento) async {
    try {
      final id = await _dbHelper.insertRifornimento(rifornimento);
      return id;
    } catch (e) {
      print('Errore durante l\'inserimento del rifornimento: $e');
      rethrow;
    }
  }

  /// Recupera tutti i rifornimenti per uno specifico ID scooter.
  Future<List<Rifornimento>> getRifornimentiForScooter(int scooterId) async {
    try {
      final rifornimenti = await _dbHelper.getRifornimenti(scooterId);
      return rifornimenti;
    } catch (e) {
      print('Errore durante il recupero dei rifornimenti per scooter ID $scooterId: $e');
      rethrow;
    }
  }

  /// Recupera un singolo rifornimento tramite il suo ID.
  /// Ritorna null se il rifornimento non viene trovato.
  Future<Rifornimento?> getRifornimentoById(int rifornimentoId) async {
    try {
      final rifornimento = await _dbHelper.getRifornimentoById(rifornimentoId);
      return rifornimento;
    } catch (e) {
      print('Errore durante il recupero del rifornimento con ID $rifornimentoId: $e');
      rethrow;
    }
  }

  /// Aggiorna un rifornimento esistente nel database.
  /// Ritorna true se l'aggiornamento ha avuto successo, false altrimenti.
  Future<bool> updateRifornimento(Rifornimento rifornimento) async {
    try {
      final success = await _dbHelper.updateRifornimento(rifornimento);
      return success;
    } catch (e) {
      print('Errore durante l\'aggiornamento del rifornimento con ID ${rifornimento.id}: $e');
      rethrow;
    }
  }

  /// Cancella un rifornimento dal database dato il suo ID.
  /// Ritorna il numero di righe eliminate (normalmente 1 se la cancellazione ha successo).
  Future<int> deleteRifornimento(int rifornimentoId) async {
    try {
      final rowsAffected = await _dbHelper.deleteRifornimento(rifornimentoId);
      return rowsAffected;
    } catch (e) {
      print('Errore durante l\'eliminazione del rifornimento con ID $rifornimentoId: $e');
      rethrow;
    }
  }

  /// Recupera l'ultimo rifornimento per un dato scooter ID.
  /// Ritorna null se non ci sono rifornimenti per quello scooter.
  Future<Rifornimento?> getPreviousRifornimento(int scooterId) async {
    try {
      final rifornimento = await _dbHelper.getPreviousRifornimento(scooterId);
      return rifornimento;
    } catch (e) {
      print('Errore durante il recupero dell\'ultimo rifornimento per scooter ID $scooterId: $e');
      rethrow;
    }
  }

  /// Recupera l'ultimo rifornimento per un dato scooter ID, escludendo uno specifico rifornimento.
  /// Utile per calcoli che non devono includere il rifornimento che si sta modificando/eliminando.
  /// Ritorna null se non ci sono rifornimenti validi.
  Future<Rifornimento?> getPreviousRifornimentoExcluding(int scooterId, int? excludingRifornimentoId) async {
    try {
      final rifornimento = await _dbHelper.getPreviousRifornimentoExcluding(scooterId, excludingRifornimentoId);
      return rifornimento;
    } catch (e) {
      print('Errore durante il recupero dell\'ultimo rifornimento per scooter ID $scooterId (escludendo $excludingRifornimentoId): $e');
      rethrow;
    }
  }
}