import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/features/documenti/models/documento.dart'; // <-- Nuovo import
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {

  Database? _database;

  // Costruttore semplice
  DatabaseHelper();

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
      version: 5, // *** INCREMENTATO A VERSIONE 5 ***
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

    // Creazione della tabella rifornimenti
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
        costo REAL,
        note TEXT,
        latitudine REAL,
        longitudine REAL,
        FOREIGN KEY (idScooter) REFERENCES scooters(id) ON DELETE CASCADE
      )
    ''');

    // Creazione della tabella manutenzioni
    await _createManutenzioniTable(db);

    // Creazione della tabella documenti
    await _createDocumentiTable(db);
  }

  Future _createManutenzioniTable(Database db) async {
    await db.execute('''
      CREATE TABLE manutenzioni(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idScooter INTEGER NOT NULL,
        data INTEGER NOT NULL,
        km REAL NOT NULL,
        categoria TEXT NOT NULL,
        categoriaCustom TEXT,
        titolo TEXT NOT NULL,
        costo REAL,
        note TEXT,
        nomeFoto TEXT,
        FOREIGN KEY (idScooter) REFERENCES scooters(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _createDocumentiTable(Database db) async {
    await db.execute('''
      CREATE TABLE documenti(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idScooter INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        tipoCustom TEXT,
        dataScadenza INTEGER,
        note TEXT,
        nomeFoto TEXT,
        FOREIGN KEY (idScooter) REFERENCES scooters(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrazione da v1 a v2
    if (oldVersion < 2) {
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
    }

    // Migrazione da v2 a v3
    if (oldVersion < 3) {
      await db.transaction((txn) async {
        await txn.execute("ALTER TABLE rifornimenti ADD COLUMN costo REAL;");
        await txn.execute("ALTER TABLE rifornimenti ADD COLUMN note TEXT;");
        await txn.execute("ALTER TABLE rifornimenti ADD COLUMN latitudine REAL;");
        await txn.execute("ALTER TABLE rifornimenti ADD COLUMN longitudine REAL;");
      });
      print("Migrazione a V3 completata.");
    }

    // Migrazione da v3 a v4
    if (oldVersion < 4) {
      await _createManutenzioniTable(db);
      print("Migrazione a V4 completata: creata tabella manutenzioni.");
    }

    // Migrazione da v4 a v5
    if (oldVersion < 5) {
      await _createDocumentiTable(db);
      print("Migrazione a V5 completata: creata tabella documenti.");
    }
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ==========================================
  // --- Metodi CRUD per Scooter ---
  // ==========================================
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
    if (_database != null) {
      final db = _database!;
      _database = null; // Fondamentale!
      await db.close();
      print("Database chiuso in sicurezza.");
    }
  }

  // ==========================================
  // --- Metodi CRUD per Rifornimento ---
  // ==========================================
  Future<int?> insertRifornimento(Rifornimento rifornimento) async {
    final db = await database;
    try {
      final id = await db.insert(
        'rifornimenti',
        rifornimento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
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

  // ==========================================
  // --- Metodi CRUD per Manutenzione ---
  // ==========================================
  Future<int?> insertManutenzione(Manutenzione manutenzione) async {
    final db = await database;
    try {
      return await db.insert(
        'manutenzioni',
        manutenzione.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Manutenzione>> getManutenzioni(int scooterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'manutenzioni',
      where: 'idScooter = ?',
      whereArgs: [scooterId],
      orderBy: 'data DESC',
    );
    return List.generate(maps.length, (i) {
      return Manutenzione.fromMap(maps[i]);
    });
  }

  Future<bool> updateManutenzione(Manutenzione manutenzione) async {
    final db = await database;
    if (manutenzione.id == null) return false;
    try {
      final changes = await db.update(
        'manutenzioni',
        manutenzione.toMap(),
        where: 'id = ?',
        whereArgs: [manutenzione.id],
      );
      return changes > 0;
    } catch (e) {
      return false;
    }
  }

  Future<int> deleteManutenzione(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'manutenzioni',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }

  // ==========================================
  // --- Metodi CRUD per Documenti ---
  // ==========================================
  Future<int?> insertDocumento(Documento documento) async {
    final db = await database;
    try {
      return await db.insert(
        'documenti',
        documento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Documento>> getDocumenti(int scooterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documenti',
      where: 'idScooter = ?',
      whereArgs: [scooterId],
      orderBy: 'dataScadenza ASC', // I più imminenti per primi
    );

    // Ordiniamo a mano per mettere quelli senza scadenza in fondo
    var docs = List.generate(maps.length, (i) => Documento.fromMap(maps[i]));
    docs.sort((a, b) {
      if (a.dataScadenza == null && b.dataScadenza == null) return 0;
      if (a.dataScadenza == null) return 1;
      if (b.dataScadenza == null) return -1;
      return a.dataScadenza!.compareTo(b.dataScadenza!);
    });

    return docs;
  }

  Future<bool> updateDocumento(Documento documento) async {
    final db = await database;
    if (documento.id == null) return false;
    try {
      final changes = await db.update(
        'documenti',
        documento.toMap(),
        where: 'id = ?',
        whereArgs: [documento.id],
      );
      return changes > 0;
    } catch (e) {
      return false;
    }
  }

  Future<int> deleteDocumento(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'documenti',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return 0;
    }
  }
}