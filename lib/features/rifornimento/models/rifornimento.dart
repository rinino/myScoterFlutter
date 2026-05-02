import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Rifornimento {
  String? id;
  String? userId;
  String idScooter;
  DateTime dataRifornimento; // Allineato a Swift (Date -> Timestamp)
  double kmAttuali;
  double litriBenzina;
  double? litriOlio;
  double? percentualeOlio;
  double kmPercorsi;
  double? mediaConsumo;
  double? costo;
  String? note;
  double? latitudine;
  double? longitudine;

  Rifornimento({
    this.id,
    this.userId,
    required this.idScooter,
    required this.dataRifornimento,
    required this.kmAttuali,
    required this.litriBenzina,
    this.litriOlio,
    this.percentualeOlio,
    required this.kmPercorsi,
    this.mediaConsumo,
    this.costo,
    this.note,
    this.latitudine,
    this.longitudine,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'idScooter': idScooter,
      'dataRifornimento': Timestamp.fromDate(dataRifornimento),
      'kmAttuali': kmAttuali,
      'litriBenzina': litriBenzina,
      'litriOlio': litriOlio,
      'percentualeOlio': percentualeOlio,
      'kmPercorsi': kmPercorsi,
      'mediaConsumo': mediaConsumo,
      'costo': costo,
      'note': note,
      'latitudine': latitudine,
      'longitudine': longitudine,
    };
  }

  factory Rifornimento.fromMap(Map<String, dynamic> map, String documentId) {
    return Rifornimento(
      id: documentId,
      userId: map['userId'] as String?,
      idScooter: map['idScooter'] as String,
      dataRifornimento: (map['dataRifornimento'] as Timestamp).toDate(),
      kmAttuali: (map['kmAttuali'] as num).toDouble(),
      litriBenzina: (map['litriBenzina'] as num).toDouble(),
      litriOlio: map['litriOlio'] != null ? (map['litriOlio'] as num).toDouble() : null,
      percentualeOlio: map['percentualeOlio'] != null ? (map['percentualeOlio'] as num).toDouble() : null,
      kmPercorsi: (map['kmPercorsi'] as num).toDouble(),
      mediaConsumo: map['mediaConsumo'] != null ? (map['mediaConsumo'] as num).toDouble() : null,
      costo: map['costo'] != null ? (map['costo'] as num).toDouble() : null,
      note: map['note'] as String?,
      latitudine: map['latitudine'] != null ? (map['latitudine'] as num).toDouble() : null,
      longitudine: map['longitudine'] != null ? (map['longitudine'] as num).toDouble() : null,
    );
  }

  String get formattedDataRifornimento {
    return DateFormat('dd/MM/yyyy').format(dataRifornimento);
  }
}