import 'package:flutter/material.dart';
import 'package:myscooter/l10n/app_localizations.dart';

enum TipoDocumento {
  libretto,
  assicurazione,
  revisione,
  bollo,
  certificato,
  patente,
  altro,
}

extension TipoDocumentoExt on TipoDocumento {
  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case TipoDocumento.libretto: return l10n.docLibretto;
      case TipoDocumento.assicurazione: return l10n.docAssicurazione;
      case TipoDocumento.revisione: return l10n.docRevisione;
      case TipoDocumento.bollo: return l10n.docBollo;
      case TipoDocumento.certificato: return l10n.docCertificato;
      case TipoDocumento.patente: return l10n.docPatente;
      case TipoDocumento.altro: return l10n.cat_altro;
    }
  }

  IconData get icon {
    switch (this) {
      case TipoDocumento.libretto: return Icons.menu_book;
      case TipoDocumento.assicurazione: return Icons.security;
      case TipoDocumento.revisione: return Icons.verified;
      case TipoDocumento.bollo: return Icons.description;
      case TipoDocumento.certificato: return Icons.history_edu;
      case TipoDocumento.patente: return Icons.badge;
      case TipoDocumento.altro: return Icons.attach_file;
    }
  }
}

class Documento {
  final int? id;
  final int idScooter;
  final TipoDocumento tipo;
  final String? tipoCustom;
  final DateTime? dataScadenza;
  final String? note;
  final String? nomeFoto;

  Documento({
    this.id,
    required this.idScooter,
    required this.tipo,
    this.tipoCustom,
    this.dataScadenza,
    this.note,
    this.nomeFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idScooter': idScooter,
      'tipo': tipo.name,
      'tipoCustom': tipoCustom,
      'dataScadenza': dataScadenza?.millisecondsSinceEpoch,
      'note': note,
      'nomeFoto': nomeFoto,
    };
  }

  factory Documento.fromMap(Map<String, dynamic> map) {
    return Documento(
      id: map['id'],
      idScooter: map['idScooter'],
      tipo: TipoDocumento.values.byName(map['tipo']),
      tipoCustom: map['tipoCustom'],
      dataScadenza: map['dataScadenza'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dataScadenza'])
          : null,
      note: map['note'],
      nomeFoto: map['nomeFoto'],
    );
  }
}