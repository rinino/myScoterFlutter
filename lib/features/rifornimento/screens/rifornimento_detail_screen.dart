// lib/features/rifornimento/screens/rifornimento_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/core/providers/core_providers.dart';

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
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentRifornimento = widget.rifornimento;
    _loadScooterDetails();
  }

  Future<void> _loadScooterDetails() async {
    setState(() => _isLoadingScooterDetails = true);

    await Future.delayed(const Duration(milliseconds: 600));

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calcolo Consumo Medio'),
          content: const Text(
            'Il consumo medio viene calcolato dividendo i chilometri percorsi dall\'ultimo rifornimento per i litri di benzina inseriti in questo rifornimento. Si assume che ad ogni rifornimento venga fatto il pieno.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              // I popup e i dialog vanno benissimo col Navigator standard
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
    final bool isUIBlocked = _isLoadingScooterDetails || _isDeleting;
    final Color iconColor = isUIBlocked ? Colors.grey : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Router standard per tornare indietro: usiamo context.pop()
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
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dettagli Rifornimento',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        _buildDetailRow(Icons.calendar_today, 'Data', DateFormat('dd/MM/yyyy HH:mm').format(_currentRifornimento.dateTime), iconColor),
                        const Divider(height: 24),

                        _buildDetailRow(Icons.speed, 'Km Attuali', '${_currentRifornimento.kmAttuali.toStringAsFixed(0)}', iconColor),
                        const Divider(height: 24),

                        _buildDetailRow(Icons.local_gas_station, 'Litri Benzina', '${_currentRifornimento.litriBenzina.toStringAsFixed(2)}', iconColor),
                        const Divider(height: 24),

                        if (_currentRifornimento.litriOlio != null)
                          _buildDetailRow(Icons.water_drop, 'Litri Olio', '${_currentRifornimento.litriOlio!.toStringAsFixed(2)} L', iconColor)
                        else if (!isUIBlocked)
                          _buildDetailRow(Icons.water_drop, 'Litri Olio', 'Nessuno', iconColor),

                        if (!_scooterHasMiscelatore) ...[
                          const Divider(height: 24),
                          if (_currentRifornimento.percentualeOlio != null)
                            _buildDetailRow(Icons.percent, 'Percentuale Olio', '${_currentRifornimento.percentualeOlio!.toStringAsFixed(2)} %', iconColor)
                          else
                            _buildDetailRow(Icons.percent, 'Percentuale Olio', 'N/A', iconColor),
                        ],
                        const Divider(height: 24),

                        _buildDetailRow(Icons.add_road, 'Km Percorsi', '${_currentRifornimento.kmPercorsi.toStringAsFixed(2)}', iconColor),
                        const Divider(height: 24),

                        Row(
                          children: [
                            Icon(Icons.bar_chart, color: iconColor, size: 22),
                            const SizedBox(width: 12),
                            const Text('Media Consumo:', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentRifornimento.mediaConsumo != null ? '${_currentRifornimento.mediaConsumo!.toStringAsFixed(2)} Km/L' : 'N/A',
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
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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

  Future<void> _confirmAndDeleteRifornimento() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina'),
        content: const Text('Eliminare questo record? l\'azione è irreversibile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULLA')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINA', style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && _currentRifornimento.id != null) {
      setState(() => _isDeleting = true);
      try {
        await ref.read(rifornimentoRepoProvider).deleteRifornimento(_currentRifornimento.id!);
        if (mounted) {
          // Torniamo indietro indicando che c'è stata una modifica (eliminazione)
          context.pop(true);
        }
      } catch (e) {
        setState(() => _isDeleting = false);
      }
    }
  }
}