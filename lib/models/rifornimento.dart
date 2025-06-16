import 'package:intl/intl.dart'; // Importa questo per DateFormat

class Rifornimento {
  int? id;
  int idScooter;
  int dataRifornimento; // timestamp in millisecondi
  double kmAttuali;
  double litriBenzina;
  double? litriOlio;
  double? percentualeOlio;
  double kmPercorsi;
  double? mediaConsumo;

  Rifornimento({
    this.id,
    required this.idScooter,
    required this.dataRifornimento,
    required this.kmAttuali,
    required this.litriBenzina,
    this.litriOlio,
    this.percentualeOlio,
    required this.kmPercorsi,
    this.mediaConsumo,
  });

  // Converti un Rifornimento in una Map. Utile per l'inserimento nel DB.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idScooter': idScooter,
      'dataRifornimento': dataRifornimento,
      'kmAttuali': kmAttuali,
      'litriBenzina': litriBenzina,
      'litriOlio': litriOlio,
      'percentualeOlio': percentualeOlio,
      'kmPercorsi': kmPercorsi,
      'mediaConsumo': mediaConsumo,
    };
  }

  // Crea un Rifornimento da una Map. Utile per il recupero dal DB.
  factory Rifornimento.fromMap(Map<String, dynamic> map) {
    return Rifornimento(
      id: map['id'] as int?,
      idScooter: map['idScooter'] as int,
      dataRifornimento: map['dataRifornimento'] as int,
      kmAttuali: map['kmAttuali'] as double,
      litriBenzina: map['litriBenzina'] as double,
      litriOlio: map['litriOlio'] as double?,
      percentualeOlio: map['percentualeOlio'] as double?,
      kmPercorsi: map['kmPercorsi'] as double,
      mediaConsumo: map['mediaConsumo'] as double?,
    );
  }

  // Getter per ottenere la data come DateTime
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(dataRifornimento);

  // Getter per ottenere la data formattata come stringa
  String get formattedDataRifornimento {
    return DateFormat('dd/MM/yyyy').format(dateTime); // Formato italiano
  }
}