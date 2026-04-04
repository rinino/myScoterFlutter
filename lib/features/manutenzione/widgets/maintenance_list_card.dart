import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:myscooter/features/manutenzione/models/manutenzione.dart';
import 'package:myscooter/features/manutenzione/providers/manutenzione_provider.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class MaintenanceListCard extends ConsumerWidget {
  final Manutenzione manutenzione;
  final String currencySymbol;

  const MaintenanceListCard({
    super.key,
    required this.manutenzione,
    required this.currencySymbol,
  });

  String _translateCategory(BuildContext context, AppLocalizations l10n, Manutenzione m) {
    if (m.categoria == CategoriaManutenzione.altro && m.categoriaCustom != null) {
      return m.categoriaCustom!;
    }
    switch (m.categoria) {
      case CategoriaManutenzione.motore: return l10n.cat_motore;
      case CategoriaManutenzione.accensione: return l10n.cat_accensione;
      case CategoriaManutenzione.alimentazione: return l10n.cat_alimentazione;
      case CategoriaManutenzione.olioCambio: return l10n.cat_olio_cambio;
      case CategoriaManutenzione.trasmissione: return l10n.cat_trasmissione;
      case CategoriaManutenzione.freniGomme: return l10n.cat_freni_gomme;
      case CategoriaManutenzione.carrozzeria: return l10n.cat_carrozzeria;
      case CategoriaManutenzione.altro: return l10n.cat_altro;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);

    return Dismissible(
      key: Key('manutenzione_${manutenzione.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(l10n.confirmTitle),
              content: Text(l10n.confirmDeleteMaintenance),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel.toUpperCase()) // Usato cancel esistente
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                      l10n.delete.toUpperCase(), // Usato delete esistente
                      style: const TextStyle(color: Colors.red)
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        ref.read(manutenzioneListProvider(manutenzione.idScooter).notifier).deleteManutenzione(manutenzione.id!);
        ref.read(messageProvider.notifier).show(l10n.maintenanceDeleted, type: MessageType.success);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push('/maintenance-detail', extra: manutenzione);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(manutenzione.categoria.icon, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(manutenzione.data),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      '${manutenzione.km.toStringAsFixed(0)} km',
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  manutenzione.titolo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _translateCategory(context, l10n, manutenzione),
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                if (manutenzione.costo != null || (manutenzione.nomeFoto != null && manutenzione.nomeFoto!.isNotEmpty)) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (manutenzione.costo != null)
                        Text(
                          '${manutenzione.costo!.toStringAsFixed(2)} $currencySymbol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      if (manutenzione.costo == null) const Spacer(),
                      if (manutenzione.nomeFoto != null && manutenzione.nomeFoto!.isNotEmpty)
                        const Icon(Icons.receipt_long, color: Colors.grey, size: 20),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}