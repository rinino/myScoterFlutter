import 'package:myscoterflutter/models/scooter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async'; // Per gestire le operazioni asincrone

class DatabaseHelper {
  // --- Singleton Pattern ---
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Getter per l'istanza del database. Inizializza il DB solo la prima volta che viene richiesto.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // --- Inizializzazione del Database ---
  Future<Database> _initDatabase() async {
    // Ottieni il percorso della directory documenti dell'app dove verrà salvato il DB
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'scooter_database.db'); // Nome del tuo file database

    return await openDatabase(
      path,
      version: 1, // La versione del database. Incrementala per triggerare onUpgrade.
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure, // Opzionale, per configurazioni avanzate
    );
  }

  // --- Callback di Creazione del Database ---
  // Chiamato solo quando il database viene creato per la prima volta.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scooters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        modello TEXT NOT NULL,
        cilindrata INTEGER NOT NULL,
        targa TEXT NOT NULL UNIQUE, -- La targa è unica per ogni scooter
        anno INTEGER NOT NULL,
        miscelatore INTEGER NOT NULL, -- 0 per false, 1 per true
        imgPath TEXT -- Percorso o URI dell'immagine, può essere null
      )
    ''');
    // Aggiungi qui altre istruzioni CREATE TABLE per le tue altre entità
  }

  // --- Callback di Aggiornamento del Database (Migrazioni) ---
  // Chiamato quando la versione del database nel codice è maggiore di quella sul dispositivo.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Esempio di migrazione da oldVersion 1 a newVersion 2:
    if (oldVersion < 2) {
      // await db.execute("ALTER TABLE scooters ADD COLUMN nuova_colonna TEXT;");
    }
    // Ogni blocco `if` gestisce una specifica transizione di versione
    if (oldVersion < 3) {
      // Esempio: aggiungi una nuova tabella
      // await db.execute('''
      //   CREATE TABLE servizi (
      //     id INTEGER PRIMARY KEY AUTOINCREMENT,
      //     scooterId INTEGER NOT NULL,
      //     descrizione TEXT,
      //     FOREIGN KEY (scooterId) REFERENCES scooters(id) ON DELETE CASCADE
      //   )
      // ''');
    }
  }

  // --- Callback di Configurazione del Database (Opzionale) ---
  // Chiamato subito dopo l'apertura del database, prima di qualsiasi query.
  // Utile per abilitare il supporto alle chiavi esterne (FOREIGN KEY).
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // --- Metodi CRUD per Scooter ---

  // Inserisce un nuovo scooter nel database. Ritorna l'ID generato.
  Future<int> insertScooter(Scooter scooter) async {
    final db = await database;
    return await db.insert(
      'scooters',
      scooter.toMap(), // Converte l'oggetto Scooter in una Map
      conflictAlgorithm: ConflictAlgorithm.replace, // Se un'entità con lo stesso ID esiste, la sostituisce
    );
  }

  // Recupera tutti gli scooter dal database.
  Future<List<Scooter>> getScooters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scooters');
    // Converte la lista di Map in una lista di oggetti Scooter
    return List.generate(maps.length, (i) {
      return Scooter.fromMap(maps[i]);
    });
  }

  // Recupera un singolo scooter per ID. Ritorna null se non trovato.
  Future<Scooter?> getScooterById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scooters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1, // Ci aspettiamo al massimo un risultato
    );
    if (maps.isNotEmpty) {
      return Scooter.fromMap(maps.first);
    }
    return null; // Scooter non trovato
  }

  // Recupera un singolo scooter per targa. Ritorna null se non trovato.
  Future<Scooter?> getScooterByTarga(String targa) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scooters',
      where: 'targa = ?',
      whereArgs: [targa],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Scooter.fromMap(maps.first);
    }
    return null;
  }

  // Aggiorna uno scooter esistente nel database. Ritorna il numero di righe aggiornate.
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

  // Cancella uno scooter dal database dato il suo ID. Ritorna il numero di righe eliminate.
  Future<int> deleteScooter(int id) async {
    final db = await database;
    return await db.delete(
      'scooters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cancella tutti gli scooter dalla tabella (utile per il debug o reset)
  Future<int> deleteAllScooters() async {
    final db = await database;
    return await db.delete('scooters');
  }

  // Chiude la connessione al database.
  // In un'applicazione mobile, spesso non è necessario chiamare esplicitamente close,
  // ma può essere utile in scenari specifici (es. unit testing).
  Future<void> closeDb() async {
    final db = await _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null; // Resetta l'istanza per permettere una nuova apertura
    }
  }
}