import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myscooter/l10n/app_localizations.dart';

enum TipoDocumento {
  libretto, assicurazione, revisione, bollo, certificato, patente, altro,
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
  String? id;
  String? userId;
  String scooterId;
  TipoDocumento tipo;
  String? tipoCustom;
  DateTime? dataScadenza;
  String? note;
  String? nomeFoto;

  Documento({
    this.id, this.userId, required this.scooterId, required this.tipo,
    this.tipoCustom, this.dataScadenza, this.note, this.nomeFoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'scooterId': scooterId,
      'tipo': tipo.name,
      'tipoCustom': tipoCustom,
      'dataScadenza': dataScadenza != null ? Timestamp.fromDate(dataScadenza!) : null,
      'note': note,
      'nomeFoto': nomeFoto,
    };
  }

  factory Documento.fromMap(Map<String, dynamic> map, String documentId) {
    return Documento(
      id: documentId,
      userId: map['userId'] as String?,
      scooterId: map['scooterId'] as String,
      // FIX CRITICO: Ignora maiuscole/minuscole
      tipo: TipoDocumento.values.firstWhere(
            (e) => e.name.toLowerCase() == map['tipo'].toString().toLowerCase(),
        orElse: () => TipoDocumento.libretto,
      ),
      tipoCustom: map['tipoCustom'] as String?,
      dataScadenza: map['dataScadenza'] != null ? (map['dataScadenza'] as Timestamp).toDate() : null,
      note: map['note'] as String?,
      nomeFoto: map['nomeFoto'] as String?,
    );
  }
}