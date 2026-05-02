import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:myscooter/l10n/app_localizations.dart';
import '../models/documento.dart';
import '../providers/documento_provider.dart';

class DocumentiCarouselView extends ConsumerWidget {
  final String scooterId; // FIX: Ora è String

  const DocumentiCarouselView({super.key, required this.scooterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncDocs = ref.watch(documentoListProvider(scooterId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            l10n.documentiScadenze.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        SizedBox(
          height: 160,
          child: asyncDocs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Errore: $e')),
            data: (documenti) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: documenti.length + 1,
                itemBuilder: (context, index) {
                  if (index == documenti.length) {
                    return _buildAddButton(context, l10n);
                  }
                  return _buildDocCard(context, ref, l10n, documenti[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocCard(BuildContext context, WidgetRef ref, AppLocalizations l10n, Documento doc) {
    final dateFormat = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);

    Color getExpiryColor(DateTime? expiry) {
      if (expiry == null) return Colors.green;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final exp = DateTime(expiry.year, expiry.month, expiry.day);
      if (exp.isBefore(today) || exp.isAtSameMomentAs(today)) return Colors.red;
      if (exp.difference(today).inDays <= 30) return Colors.orange;
      return Colors.green;
    }

    final color = getExpiryColor(doc.dataScadenza);

    return GestureDetector(
      onTap: () => context.push('/documento-detail', extra: doc),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.deleteRecordTitle),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
              TextButton(
                onPressed: () {
                  ref.read(documentoListProvider(scooterId).notifier).deleteDocumento(doc.id!);
                  Navigator.pop(ctx);
                },
                child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(doc.tipo.icon, size: 28, color: color),
            const Spacer(),
            Text(
              doc.tipo == TipoDocumento.altro ? (doc.tipoCustom ?? l10n.cat_altro) : doc.tipo.getLocalizedName(l10n),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              doc.dataScadenza != null ? l10n.scadeIl : l10n.senzaScadenza,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            if (doc.dataScadenza != null)
              Text(
                dateFormat.format(doc.dataScadenza!),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push('/add-edit-documento', extra: {'scooterId': scooterId, 'documento': null}),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.5), style: BorderStyle.solid, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(l10n.aggiungi, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}