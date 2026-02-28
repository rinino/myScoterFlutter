import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../rifornimento/models/rifornimento.dart';

class RefuelingsListSection extends StatelessWidget {
  final List<Rifornimento> rifornimenti;
  final bool isLoading;
  final String locale;
  final VoidCallback onAddTap;
  final Function(Rifornimento) onRifornimentoTap;
  final Function(Rifornimento) onDeleteConfirm;

  const RefuelingsListSection({
    super.key,
    required this.rifornimenti,
    required this.isLoading,
    required this.locale,
    required this.onAddTap,
    required this.onRifornimentoTap,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.refuelings, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), onPressed: onAddTap),
          ],
        ),
        if (!isLoading && rifornimenti.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(l10n.noDataPresent))),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rifornimenti.length,
          itemBuilder: (context, index) {
            final rif = rifornimenti[index];
            return Dismissible(
              key: Key(rif.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (dir) async {
                onDeleteConfirm(rif);
                return false; // Gestiamo l'eliminazione manualmente per sicurezza
              },
              child: ListTile(
                leading: const Icon(Icons.local_gas_station),
                title: Text(DateFormat.yMd(locale).format(DateTime.fromMillisecondsSinceEpoch(rif.dataRifornimento))),
                subtitle: Text('${rif.kmAttuali.toInt()} km - ${rif.mediaConsumo?.toStringAsFixed(2) ?? "N/A"} km/L'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onRifornimentoTap(rif),
              ),
            );
          },
        ),
      ],
    );
  }
}