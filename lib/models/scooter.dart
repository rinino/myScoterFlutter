// lib/models/scooter.dart
import 'package:flutter/foundation.dart';

class Scooter {
  // @PrimaryKey(autoGenerate = true) -> gestito dal database al momento dell'inserimento
  final int? id; // `id` è nullable perché non sarà presente quando crei un nuovo oggetto prima di inserirlo nel DB
  final String marca;
  final String modello;
  final int cilindrata;
  final String targa;
  final int anno;
  final bool miscelatore;
  final String? imgPath; // Usiamo `imgPath` per essere più generici (percorso locale o URI)

  // Costruttore per creare un nuovo oggetto Scooter
  Scooter({
    this.id, // Opzionale per i nuovi oggetti
    required this.marca,
    required this.modello,
    required this.cilindrata,
    required this.targa,
    required this.anno,
    required this.miscelatore,
    this.imgPath, // Opzionale
  });

  // Metodo per convertire un oggetto Scooter in una Map<String, dynamic>
  // Questo è utile quando inserisci o aggiorni i dati nel database SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Sarà null per i nuovi oggetti, il DB lo auto-genererà
      'marca': marca,
      'modello': modello,
      'cilindrata': cilindrata,
      'targa': targa,
      'anno': anno,
      'miscelatore': miscelatore ? 1 : 0, // SQLite non ha tipo Boolean, usiamo 0 per false, 1 per true
      'imgPath': imgPath,
    };
  }

  // Costruttore di fabbrica per creare un oggetto Scooter da una Map<String, dynamic>
  // Questo è utile quando recuperi i dati dal database SQLite.
  factory Scooter.fromMap(Map<String, dynamic> map) {
    return Scooter(
      id: map['id'] as int?,
      marca: map['marca'] as String,
      modello: map['modello'] as String,
      cilindrata: map['cilindrata'] as int,
      targa: map['targa'] as String,
      anno: map['anno'] as int,
      miscelatore: map['miscelatore'] == 1, // Converti 0/1 in booleano
      imgPath: map['imgPath'] as String?,
    );
  }

  // Override di toString per una stampa più leggibile (utile per il debug)
  @override
  String toString() {
    return 'Scooter(id: $id, marca: $marca, modello: $modello, cilindrata: $cilindrata, targa: $targa, anno: $anno, miscelatore: $miscelatore, imgPath: $imgPath)';
  }
}