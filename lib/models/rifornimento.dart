import 'package:intl/intl.dart'; // Per gestire la formattazione delle date

class Rifornimento {
  int? id;
  int idScooter;
  DateTime dataRifornimento;
  double kmAttuali;
  double litriBenzina;
  double? litriOlio;
  double kmPercorsi;
  double? mediaConsumo;
  double? percentualeOlio;

  Rifornimento({
    this.id, // Opzionale, sarà generato dal DB
    required this.idScooter,
    required this.dataRifornimento,
    required this.kmAttuali,
    required this.litriBenzina,
    this.litriOlio, // Opzionale
    required this.kmPercorsi,
    this.mediaConsumo, // Opzionale
    this.percentualeOlio, // Opzionale
  });

  // Metodo per convertire l'oggetto Rifornimento in una Map<String, dynamic>
  // Essenziale per salvare i dati nel database sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idScooter': idScooter,
      'dataRifornimento': dataRifornimento.millisecondsSinceEpoch, // Salva la data come timestamp UNIX
      'kmAttuali': kmAttuali,
      'litriBenzina': litriBenzina,
      'litriOlio': litriOlio,
      'kmPercorsi': kmPercorsi,
      'mediaConsumo': mediaConsumo,
      'percentualeOlio': percentualeOlio,
    };
  }

  // Costruttore factory per creare un oggetto Rifornimento da una Map<String, dynamic>
  // Essenziale per recuperare i dati dal database sqflite
  factory Rifornimento.fromMap(Map<String, dynamic> map) {
    return Rifornimento(
      id: map['id'],
      idScooter: map['idScooter'],
      dataRifornimento: DateTime.fromMillisecondsSinceEpoch(map['dataRifornimento']), // Converte il timestamp in DateTime
      kmAttuali: map['kmAttuali'],
      litriBenzina: map['litriBenzina'],
      litriOlio: map['litriOlio'],
      kmPercorsi: map['kmPercorsi'],
      mediaConsumo: map['mediaConsumo'],
      percentualeOlio: map['percentualeOlio'],
    );
  }

  // Metodo helper per formattare la data per la visualizzazione (opzionale)
  String get formattedDataRifornimento {
    return DateFormat('dd/MM/yyyy').format(dataRifornimento);
  }

  @override
  String toString() {
    return 'Rifornimento{id: $id, idScooter: $idScooter, dataRifornimento: $dataRifornimento, kmAttuali: $kmAttuali, litriBenzina: $litriBenzina, litriOlio: $litriOlio, kmPercorsi: $kmPercorsi, mediaConsumo: $mediaConsumo, percentualeOlio: $percentualeOlio}';
  }
}