// lib/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/core/database/database_helper.dart';
import 'package:myscooter/features/rifornimento/repositories/rifornimento_repository.dart';
import 'package:myscooter/features/scooter/repositories/scooter_repository.dart';

// 1. Provider globale del Database
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// 2. Provider del repository Scooter (gli iniettiamo il database leggendolo dal provider sopra!)
final scooterRepoProvider = Provider<ScooterRepository>((ref) {
  final dbHelper = ref.read(databaseProvider);
  return ScooterRepository(dbHelper);
});

// 3. Provider del repository Rifornimento
final rifornimentoRepoProvider = Provider<RifornimentoRepository>((ref) {
  final dbHelper = ref.read(databaseProvider);
  return RifornimentoRepository(dbHelper);
});