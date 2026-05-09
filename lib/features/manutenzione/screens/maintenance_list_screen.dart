import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/features/manutenzione/providers/manutenzione_provider.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';

import '../widgets/maintenance_empty_state.dart';
import '../widgets/maintenance_summary_header.dart';
import '../widgets/maintenance_list_card.dart';

class MaintenanceListScreen extends ConsumerWidget {
  final Scooter scooter;

  const MaintenanceListScreen({super.key, required this.scooter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // FIX: Ora chiama il corretto Stream Provider
    final manutenzioniAsync = ref.watch(manutenzioniStreamProvider(scooter.id!));
    final currencySymbol = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${scooter.marca} ${scooter.modello}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
            onPressed: () {
              context.push('/add-edit-maintenance', extra: {
                'scooterId': scooter.id!,
                'manutenzione': null,
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: manutenzioniAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('$error')),
          data: (manutenzioni) {
            if (manutenzioni.isEmpty) {
              return const MaintenanceEmptyState();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaintenanceSummaryHeader(
                  manutenzioni: manutenzioni,
                  currencySymbol: currencySymbol,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    l10n.registroManutenzione.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: manutenzioni.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      return MaintenanceListCard(
                        manutenzione: manutenzioni[index],
                        currencySymbol: currencySymbol,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}