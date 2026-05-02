import 'package:cloud_firestore/cloud_firestore.dart';

class UtenteProfilo {
  String? id;
  String email;
  String nome;
  String cognome;
  String? nomeFotoProfilo;
  String provider;
  DateTime dataRegistrazione;

  UtenteProfilo({
    this.id,
    required this.email,
    this.nome = "",
    this.cognome = "",
    this.nomeFotoProfilo,
    this.provider = "email",
    DateTime? dataRegistrazione,
  }) : dataRegistrazione = dataRegistrazione ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'cognome': cognome,
      'nomeFotoProfilo': nomeFotoProfilo,
      'provider': provider,
      'dataRegistrazione': Timestamp.fromDate(dataRegistrazione),
    };
  }

  factory UtenteProfilo.fromMap(Map<String, dynamic> map, String documentId) {
    return UtenteProfilo(
      id: documentId,
      email: map['email'] as String,
      nome: map['nome'] as String? ?? "",
      cognome: map['cognome'] as String? ?? "",
      nomeFotoProfilo: map['nomeFotoProfilo'] as String?,
      provider: map['provider'] as String? ?? "email",
      dataRegistrazione: map['dataRegistrazione'] != null
          ? (map['dataRegistrazione'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}