import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FIX PRO: Haptic Feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/features/manutenzione/providers/manutenzione_provider.dart';
import 'package:myscooter/core/providers/currency_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';

import 'package:myscooter/core/theme/app_colors.dart';
import '../../../core/widgets/glass_background.dart';

import '../widgets/maintenance_empty_state.dart';
import '../widgets/maintenance_summary_header.dart';
import '../widgets/maintenance_list_card.dart';

class MaintenanceListScreen extends ConsumerWidget {
  final Scooter scooter;
  const MaintenanceListScreen({super.key, required this.scooter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final manutenzioniAsync = ref.watch(manutenzioniStreamProvider(scooter.id!));
    final currencySymbol = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${scooter.marca} ${scooter.modello}', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            color: Colors.orange, // FIX PRO: Tema Arancione
            onPressed: () {
              HapticFeedback.mediumImpact(); // Vibrazione
              context.push('/add-edit-maintenance', extra: {
                'scooterId': scooter.id!,
                'manutenzione': null,
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // FIX PRO: Sfondo in vetro animato Arancione/Giallo!
          const GlassBackground(
            primaryColor: Colors.orange,
            secondaryColor: Colors.yellow,
          ),

          SafeArea(
            child: manutenzioniAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('$error')),
              data: (manutenzioni) {
                if (manutenzioni.isEmpty) {
                  // FIX PRO: Empty state ora è un pulsante come in Swift
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/add-edit-maintenance', extra: {
                        'scooterId': scooter.id!,
                        'manutenzione': null,
                      });
                    },
                    child: const MaintenanceEmptyState(),
                  );
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
        ],
      ),
    );
  }
}