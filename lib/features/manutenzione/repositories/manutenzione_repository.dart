import 'package:myscooter/core/database/database_helper.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';

class ManutenzioneRepository {
  final DatabaseHelper _dbHelper;

  ManutenzioneRepository(this._dbHelper);

  Future<int?> insertManutenzione(Manutenzione manutenzione) async {
    return await _dbHelper.insertManutenzione(manutenzione);
  }

  Future<List<Manutenzione>> getManutenzioni(int scooterId) async {
    return await _dbHelper.getManutenzioni(scooterId);
  }

  Future<bool> updateManutenzione(Manutenzione manutenzione) async {
    return await _dbHelper.updateManutenzione(manutenzione);
  }

  Future<int> deleteManutenzione(int id) async {
    return await _dbHelper.deleteManutenzione(id);
  }
}