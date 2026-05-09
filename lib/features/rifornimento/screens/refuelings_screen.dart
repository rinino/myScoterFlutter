// lib/features/rifornimento/screens/refuelings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/message_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../scooter/model/scooter.dart';
import '../models/rifornimento.dart';
import '../../scooter/widgets/refuelings_list_section.dart';

// NUOVO PROVIDER STREAM PER I RIFORNIMENTI
final rifornimentiStreamProvider = StreamProvider.autoDispose.family<List<Rifornimento>, String>((ref, scooterId) {
  final repo = ref.read(rifornimentoRepoProvider);
  return repo.streamRifornimentiForScooter(scooterId);
});

class RefuelingsScreen extends ConsumerWidget {
  final Scooter scooter;

  const RefuelingsScreen({super.key, required this.scooter});

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref, Rifornimento rif) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(l10n.deleteRecordContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(rifornimentoRepoProvider).deleteRifornimento(rif.id!);
        if (context.mounted) {
          ref.read(messageProvider.notifier).show(l10n.recordDeleted, type: MessageType.success);
        }
      } catch (e) {
        if (context.mounted) {
          ref.read(messageProvider.notifier).show(l10n.errorDeleting, type: MessageType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).languageCode;

    // Ascoltiamo lo stream dei rifornimenti!
    final rifornimentiAsync = ref.watch(rifornimentiStreamProvider(scooter.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refuelingData),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: rifornimentiAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(l10n.errorLoadingRefuelings)),
            data: (rifornimenti) {
              return RefuelingsListSection(
                rifornimenti: rifornimenti,
                isLoading: false,
                locale: locale,
                onAddTap: () {
                  context.push('/add-edit-rifornimento/${scooter.id!}');
                },
                onRifornimentoTap: (rif) {
                  context.push('/rifornimento-detail/${scooter.id!}', extra: rif);
                },
                onDeleteConfirm: (rif) => _confirmAndDelete(context, ref, rif),
              );
            }
        ),
      ),
    );
  }
}