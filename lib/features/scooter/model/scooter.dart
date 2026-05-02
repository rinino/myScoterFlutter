class Scooter {
  String? id;
  String? userId;
  final String marca;
  final String modello;
  final int cilindrata;
  final String targa;
  final int anno;
  final bool miscelatore;
  String? imgName; // Allineato a Swift (era imgPath)

  Scooter({
    this.id,
    this.userId,
    required this.marca,
    required this.modello,
    required this.cilindrata,
    required this.targa,
    required this.anno,
    required this.miscelatore,
    this.imgName,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'marca': marca,
      'modello': modello,
      'cilindrata': cilindrata,
      'targa': targa,
      'anno': anno,
      'miscelatore': miscelatore,
      'imgName': imgName,
    };
  }

  factory Scooter.fromMap(Map<String, dynamic> map, String documentId) {
    return Scooter(
      id: documentId,
      userId: map['userId'] as String?,
      marca: map['marca'] as String,
      modello: map['modello'] as String,
      cilindrata: map['cilindrata'] as int,
      targa: map['targa'] as String,
      anno: map['anno'] as int,
      miscelatore: map['miscelatore'] == true || map['miscelatore'] == 1,
      imgName: map['imgName'] as String?,
    );
  }
}