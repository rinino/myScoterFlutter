import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../rifornimento/models/rifornimento.dart';

// FIX: Importiamo i Colori e la GlassCard
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_card.dart';

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
            IconButton(icon: const Icon(Icons.add_circle, color: AppColors.primaryBlue), onPressed: onAddTap),
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
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16)
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (dir) async {
                onDeleteConfirm(rif);
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.local_gas_station, color: AppColors.primaryBlue)
                    ),
                    title: Text(DateFormat.yMMMd(locale).format(rif.dataRifornimento), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${rif.kmAttuali.toInt()} km - ${rif.mediaConsumo?.toStringAsFixed(2) ?? "N/A"} km/L'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => onRifornimentoTap(rif),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}