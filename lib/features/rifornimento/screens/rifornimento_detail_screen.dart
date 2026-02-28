// lib/features/rifornimento/screens/rifornimento_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/core/providers/core_providers.dart';

import '../../../l10n/app_localizations.dart';

class RifornimentoDetailScreen extends ConsumerStatefulWidget {
  final Rifornimento rifornimento;
  final int scooterId;

  const RifornimentoDetailScreen({
    super.key,
    required this.rifornimento,
    required this.scooterId,
  });

  @override
  ConsumerState<RifornimentoDetailScreen> createState() => _RifornimentoDetailScreenState();
}

class _RifornimentoDetailScreenState extends ConsumerState<RifornimentoDetailScreen> {
  late Rifornimento _currentRifornimento;

  bool _isLoadingScooterDetails = true;
  bool _scooterHasMiscelatore = true;

  @override
  void initState() {
    super.initState();
    _currentRifornimento = widget.rifornimento;
    _loadScooterDetails();
  }

  Future<void> _loadScooterDetails() async {
    if (!mounted) return;
    setState(() => _isLoadingScooterDetails = true);

    try {
      final scooter = await ref.read(scooterRepoProvider).getScooterById(widget.scooterId);
      if (scooter != null) {
        _scooterHasMiscelatore = scooter.miscelatore;
      }
    } catch (e) {
      _scooterHasMiscelatore = true;
    } finally {
      if (mounted) {
        setState(() => _isLoadingScooterDetails = false);
      }
    }
  }

  void _showMediaConsumoInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.averageConsumptionCalcTitle),
          content: Text(l10n.averageConsumptionCalcDesc),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditRifornimento() async {
    final Rifornimento? updatedRifornimento = await context.push<Rifornimento?>(
      '/add-edit-rifornimento/${widget.scooterId}',
      extra: _currentRifornimento,
    );

    if (updatedRifornimento != null) {
      setState(() {
        _currentRifornimento = updatedRifornimento;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final bool isUIBlocked = _isLoadingScooterDetails;
    final Color iconColor = isUIBlocked ? Colors.grey : Theme.of(context).colorScheme.primary;

    // --- FIX NULL SAFETY PER MEDIA CONSUMO ---
    final double? mediaValue = _currentRifornimento.mediaConsumo;
    final String mediaDisplayText = (mediaValue != null && mediaValue > 0)
        ? '${mediaValue.toStringAsFixed(2)} Km/L'
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refuelingDetails),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isUIBlocked ? null : () => context.pop(true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isUIBlocked ? null : _navigateToEditRifornimento,
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isUIBlocked,
            child: Opacity(
              opacity: isUIBlocked ? 0.5 : 1.0,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.refuelingDetails,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        // DATA LOCALIZZATA
                        _buildDetailRow(
                            Icons.calendar_today,
                            l10n.date,
                            DateFormat.yMMMd(locale).add_Hm().format(
                                DateTime.fromMillisecondsSinceEpoch(_currentRifornimento.dataRifornimento)
                            ),
                            iconColor
                        ),
                        const Divider(height: 24),

                        _buildDetailRow(Icons.speed, l10n.currentKm, '${_currentRifornimento.kmAttuali.toInt()} km', iconColor),
                        const Divider(height: 24),

                        _buildDetailRow(Icons.local_gas_station, l10n.gasLiters, '${_currentRifornimento.litriBenzina.toStringAsFixed(2)} L', iconColor),
                        const Divider(height: 24),

                        // LITRI OLIO (Gestito con null-check sicuro)
                        if (_currentRifornimento.litriOlio != null)
                          _buildDetailRow(Icons.water_drop, l10n.oilLiters, '${_currentRifornimento.litriOlio!.toStringAsFixed(2)} L', iconColor)
                        else if (!isUIBlocked)
                          _buildDetailRow(Icons.water_drop, l10n.oilLiters, l10n.none, iconColor),

                        // PERCENTUALE OLIO (SOLO SE NON HA MISCELATORE)
                        if (!_scooterHasMiscelatore) ...[
                          const Divider(height: 24),
                          if (_currentRifornimento.percentualeOlio != null)
                            _buildDetailRow(Icons.percent, l10n.oilPercentage, '${_currentRifornimento.percentualeOlio!.toStringAsFixed(1)} %', iconColor)
                          else
                            _buildDetailRow(Icons.percent, l10n.oilPercentage, 'N/A', iconColor),
                        ],
                        const Divider(height: 24),

                        _buildDetailRow(Icons.add_road, l10n.kmTraveled, '${_currentRifornimento.kmPercorsi.toStringAsFixed(1)} km', iconColor),
                        const Divider(height: 24),

                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: iconColor, size: 22),
                            const SizedBox(width: 12),
                            Text('${l10n.averageConsumption}:', style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mediaDisplayText,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showMediaConsumoInfo(context),
                              child: Icon(Icons.info_outline, color: iconColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUIBlocked)
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}