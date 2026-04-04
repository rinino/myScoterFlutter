import 'package:flutter/material.dart';

// Enum per le categorie di manutenzione (allineato alla versione Swift)
enum CategoriaManutenzione {
  motore,
  accensione,
  alimentazione,
  olioCambio,
  trasmissione,
  freniGomme,
  carrozzeria,
  altro,
}

// Estensione per gestire icone e chiavi di traduzione associate alle categorie
extension CategoriaManutenzioneExt on CategoriaManutenzione {
  String get nameKey {
    switch (this) {
      case CategoriaManutenzione.motore: return 'cat_motore';
      case CategoriaManutenzione.accensione: return 'cat_accensione';
      case CategoriaManutenzione.alimentazione: return 'cat_alimentazione';
      case CategoriaManutenzione.olioCambio: return 'cat_olio_cambio';
      case CategoriaManutenzione.trasmissione: return 'cat_trasmissione';
      case CategoriaManutenzione.freniGomme: return 'cat_freni_gomme';
      case CategoriaManutenzione.carrozzeria: return 'cat_carrozzeria';
      case CategoriaManutenzione.altro: return 'cat_altro';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoriaManutenzione.motore: return Icons.build;
      case CategoriaManutenzione.accensione: return Icons.bolt;
      case CategoriaManutenzione.alimentazione: return Icons.opacity;
      case CategoriaManutenzione.olioCambio: return Icons.oil_barrel;
      case CategoriaManutenzione.trasmissione: return Icons.settings_input_component;
      case CategoriaManutenzione.freniGomme: return Icons.tire_repair;
      case CategoriaManutenzione.carrozzeria: return Icons.format_paint;
      case CategoriaManutenzione.altro: return Icons.more_horiz;
    }
  }
}

class Manutenzione {
  final int? id;
  final int idScooter;
  final DateTime data;
  final double km;
  final CategoriaManutenzione categoria;
  final String? categoriaCustom;
  final String titolo;
  final double? costo;
  final String? note;
  final String? nomeFoto;

  Manutenzione({
    this.id,
    required this.idScooter,
    required this.data,
    required this.km,
    required this.categoria,
    this.categoriaCustom,
    required this.titolo,
    this.costo,
    this.note,
    this.nomeFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idScooter': idScooter,
      'data': data.millisecondsSinceEpoch, // Come per i rifornimenti, salviamo in millisecondi
      'km': km,
      'categoria': categoria.name, // Salviamo il nome dell'enum (es. 'motore')
      'categoriaCustom': categoriaCustom,
      'titolo': titolo,
      'costo': costo,
      'note': note,
      'nomeFoto': nomeFoto,
    };
  }

  factory Manutenzione.fromMap(Map<String, dynamic> map) {
    return Manutenzione(
      id: map['id'],
      idScooter: map['idScooter'],
      data: DateTime.fromMillisecondsSinceEpoch(map['data']),
      km: (map['km'] as num).toDouble(),
      // Recuperiamo l'enum dal nome stringa salvato nel DB
      categoria: CategoriaManutenzione.values.byName(map['categoria']),
      categoriaCustom: map['categoriaCustom'],
      titolo: map['titolo'],
      costo: map['costo'] != null ? (map['costo'] as num).toDouble() : null,
      note: map['note'],
      nomeFoto: map['nomeFoto'],
    );
  }
}