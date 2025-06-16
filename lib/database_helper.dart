import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/models/rifornimento.dart'; // Importa anche il modello Rifornimento
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'scooter_database.db');

    return await openDatabase(
      path,
      version: 1, // Iniziamo con la versione 1, la incrementeremo per migrazioni
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Creazione della tabella scooters
    await db.execute('''
      CREATE TABLE scooters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        modello TEXT NOT NULL,
        cilindrata INTEGER NOT NULL,
        targa TEXT NOT NULL UNIQUE,
        anno INTEGER NOT NULL,
        miscelatore INTEGER NOT NULL,
        imgPath TEXT
      )
    ''');

    // --- AGGIUNGI QUI LA CREAZIONE DELLA TABELLA RIFORNIMENTI ---
    await db.execute('''
      CREATE TABLE rifornimenti(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idScooter INTEGER NOT NULL,
        dataRifornimento INTEGER NOT NULL,
        kmAttuali REAL NOT NULL,
        litriBenzina REAL NOT NULL,
        litriOlio REAL,
        kmPercorsi REAL NOT NULL,
        mediaConsumo REAL,
        percentualeOlio REAL,
        FOREIGN KEY (idScooter) REFERENCES scooters(id) ON DELETE CASCADE
      )
    ''');
    print("Tabelle 'scooters' e 'rifornimenti' create o già esistenti.");
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Esempio di migrazione per aggiungere percentualeOlio se necessario
    // Se la tua app è già in produzione e "percentualeOlio" non esisteva prima,
    // allora dovresti incrementare la 'version' del database a 2 e aggiungere questa logica qui.
    if (oldVersion < 2 && newVersion >= 2) {
      // Per esempio, se hai rilasciato l'app con version:1 e senza percentualeOlio
      // e ora vuoi aggiungerlo, porti la version a 2 e metti questo:
      try {
        await db.execute("ALTER TABLE rifornimenti ADD COLUMN percentualeOlio REAL;");
        print("Colonna 'percentualeOlio' aggiunta alla tabella 'rifornimenti'.");
      } catch (e) {
        print("Errore durante l'aggiunta della colonna 'percentualeOlio' in onUpgrade: $e");
      }
    }
    // Aggiungi qui altre logiche di migrazione per future versioni
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // --- Metodi CRUD per Scooter (già presenti nella tua classe) ---

  Future<int> insertScooter(Scooter scooter) async {
    final db = await database;
    return await db.insert('scooters', scooter.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Scooter>> getScooters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scooters');
    return List.generate(maps.length, (i) {
      return Scooter.fromMap(maps[i]);
    });
  }

  Future<Scooter?> getScooterById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scooters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Scooter.fromMap(maps.first) : null;
  }

  Future<Scooter?> getScooterByTarga(String targa) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scooters',
      where: 'targa = ?',
      whereArgs: [targa],
      limit: 1,
    );
    return maps.isNotEmpty ? Scooter.fromMap(maps.first) : null;
  }

  Future<int> updateScooter(Scooter scooter) async {
    final db = await database;
    if (scooter.id == null) {
      throw Exception("Cannot update Scooter: ID is null.");
    }
    return await db.update(
      'scooters',
      scooter.toMap(),
      where: 'id = ?',
      whereArgs: [scooter.id],
    );
  }

  Future<int> deleteScooter(int id) async {
    final db = await database;
    return await db.delete('scooters', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllScooters() async {
    final db = await database;
    return await db.delete('scooters');
  }

  Future<void> closeDb() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  // --- Metodi CRUD per Rifornimento (NUOVI METODI) ---

  Future<int?> insertRifornimento(Rifornimento rifornimento) async {
    final db = await database;
    try {
      final id = await db.insert(
        'rifornimenti',
        rifornimento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Rifornimento salvato con ID: $id");
      return id;
    } catch (e) {
      print("Errore durante il salvataggio del rifornimento: $e");
      return null;
    }
  }

  Future<List<Rifornimento>> getRifornimenti(int scooterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rifornimenti',
      where: 'idScooter = ?',
      whereArgs: [scooterId],
      orderBy: 'dataRifornimento DESC, kmAttuali ASC',
    );
    return List.generate(maps.length, (i) {
      return Rifornimento.fromMap(maps[i]);
    });
  }

  Future<int> deleteRifornimento(int rifornimentoId) async {
    final db = await database;
    try {
      final changes = await db.delete(
        'rifornimenti',
        where: 'id = ?',
        whereArgs: [rifornimentoId],
      );
      return changes;
    } catch (e) {
      print("Errore durante l'eliminazione del rifornimento con ID $rifornimentoId: $e");
      return 0;
    }
  }

  Future<Rifornimento?> getRifornimentoById(int rifornimentoId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rifornimenti',
      where: 'id = ?',
      whereArgs: [rifornimentoId],
      limit: 1,
    );
    return maps.isNotEmpty ? Rifornimento.fromMap(maps.first) : null;
  }

  Future<bool> updateRifornimento(Rifornimento rifornimento) async {
    final db = await database;
    if (rifornimento.id == null) {
      print("Errore: Impossibile aggiornare un rifornimento senza ID.");
      return false;
    }
    try {
      final changes = await db.update(
        'rifornimenti',
        rifornimento.toMap(),
        where: 'id = ?',
        whereArgs: [rifornimento.id],
      );
      return changes > 0;
    } catch (e) {
      print("Errore durante l'aggiornamento del rifornimento con ID ${rifornimento.id}: $e");
      return false;
    }
  }

  Future<Rifornimento?> getPreviousRifornimento(int scooterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rifornimenti',
      where: 'idScooter = ?',
      whereArgs: [scooterId],
      orderBy: 'dataRifornimento DESC',
      limit: 1,
    );
    return maps.isNotEmpty ? Rifornimento.fromMap(maps.first) : null;
  }

  Future<Rifornimento?> getPreviousRifornimentoExcluding(int scooterId, int? excludingRifornimentoId) async {
    final db = await database;
    String whereClause = 'idScooter = ?';
    List<dynamic> whereArgs = [scooterId];

    if (excludingRifornimentoId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludingRifornimentoId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'rifornimenti',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'dataRifornimento DESC',
      limit: 1,
    );

    return maps.isNotEmpty ? Rifornimento.fromMap(maps.first) : null;
  }
}