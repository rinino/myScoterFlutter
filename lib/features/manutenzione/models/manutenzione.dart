import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoriaManutenzione {
  motore, accensione, alimentazione, olioCambio, trasmissione, freniGomme, carrozzeria, altro,
}

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
  String? id;
  String? userId;
  String scooterId;
  DateTime data;
  double km;
  CategoriaManutenzione categoria;
  String? categoriaCustom;
  String titolo;
  double? costo;
  String? note;
  String? nomeFoto;

  Manutenzione({
    this.id, this.userId, required this.scooterId, required this.data,
    required this.km, required this.categoria, this.categoriaCustom,
    required this.titolo, this.costo, this.note, this.nomeFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, 'scooterId': scooterId, 'data': Timestamp.fromDate(data),
      'km': km, 'categoria': categoria.name, 'categoriaCustom': categoriaCustom,
      'titolo': titolo, 'costo': costo, 'note': note, 'nomeFoto': nomeFoto,
    };
  }

  factory Manutenzione.fromMap(Map<String, dynamic> map, String documentId) {
    return Manutenzione(
      id: documentId,
      userId: map['userId'] as String?,
      scooterId: map['scooterId'] as String,
      data: (map['data'] as Timestamp).toDate(),
      km: (map['km'] as num).toDouble(),
      // FIX CRITICO: Ignora maiuscole/minuscole
      categoria: CategoriaManutenzione.values.firstWhere(
            (e) => e.name.toLowerCase() == map['categoria'].toString().toLowerCase(),
        orElse: () => CategoriaManutenzione.altro,
      ),
      categoriaCustom: map['categoriaCustom'] as String?,
      titolo: map['titolo'] as String,
      costo: map['costo'] != null ? (map['costo'] as num).toDouble() : null,
      note: map['note'] as String?,
      nomeFoto: map['nomeFoto'] as String?,
    );
  }
}