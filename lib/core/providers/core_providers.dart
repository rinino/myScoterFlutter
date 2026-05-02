// lib/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myscooter/features/rifornimento/repositories/rifornimento_repository.dart';
import 'package:myscooter/features/scooter/repositories/scooter_repository.dart';
import 'package:myscooter/features/manutenzione/repositories/manutenzione_repository.dart';
import 'package:myscooter/features/documenti/repositories/documento_repository.dart';


final scooterRepoProvider = Provider<ScooterRepository>((ref) => ScooterRepository());
final rifornimentoRepoProvider = Provider<RifornimentoRepository>((ref) => RifornimentoRepository());
final manutenzioneRepoProvider = Provider<ManutenzioneRepository>((ref) => ManutenzioneRepository());
final documentoRepoProvider = Provider<DocumentoRepository>((ref) => DocumentoRepository());