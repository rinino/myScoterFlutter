import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper shared = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'myscooter.db');

    // Apriamo il database esistente senza tentare di crearne uno nuovo
    // (ci basta la lettura per la migrazione)
    return await openDatabase(path, version: 3);
  }

  // --- METODI DI ESTRAZIONE GREZZA PER LA MIGRAZIONE ---

  Future<List<Map<String, dynamic>>> getAllScootersRaw() async {
    final db = await database;
    try {
      return await db.query('scooters');
    } catch (e) {
      return []; // Se la tabella non esiste, ritorna vuoto
    }
  }

  Future<List<Map<String, dynamic>>> getAllRifornimentiRaw() async {
    final db = await database;
    try {
      return await db.query('rifornimenti');
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllManutenzioniRaw() async {
    final db = await database;
    try {
      return await db.query('manutenzioni');
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllDocumentiRaw() async {
    final db = await database;
    try {
      return await db.query('documenti');
    } catch (e) {
      return [];
    }
  }
}