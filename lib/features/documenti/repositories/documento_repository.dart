import 'package:myscooter/core/database/database_helper.dart';
import 'package:myscooter/features/documenti/models/documento.dart';

class DocumentoRepository {
  final DatabaseHelper _dbHelper;

  DocumentoRepository(this._dbHelper);

  Future<int?> insertDocumento(Documento documento) async {
    return await _dbHelper.insertDocumento(documento);
  }

  Future<List<Documento>> getDocumenti(int scooterId) async {
    return await _dbHelper.getDocumenti(scooterId);
  }

  Future<bool> updateDocumento(Documento documento) async {
    return await _dbHelper.updateDocumento(documento);
  }

  Future<int> deleteDocumento(int id) async {
    return await _dbHelper.deleteDocumento(id);
  }
}