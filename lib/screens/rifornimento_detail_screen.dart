import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myscooter/models/rifornimento.dart';
import 'package:myscooter/screens/add_edit_rifornimento_screen.dart';
import 'package:myscooter/repository/rifornimento_repository.dart';
import 'package:myscooter/repository/scooter_repository.dart'; // NUOVO: Serve per leggere il miscelatore

class RifornimentoDetailScreen extends StatefulWidget {
  final Rifornimento rifornimento;
  final int scooterId;

  const RifornimentoDetailScreen({
    super.key,
    required this.rifornimento,
    required this.scooterId,
  });

  @override
  State<RifornimentoDetailScreen> createState() => _RifornimentoDetailScreenState();
}

class _RifornimentoDetailScreenState extends State<RifornimentoDetailScreen> {
  late Rifornimento _currentRifornimento;

  final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository();
  final ScooterRepository _scooterRepository = ScooterRepository(); // NUOVO

  // Variabili di stato allineate a Swift
  bool _isLoadingScooterDetails = true;
  bool _scooterHasMiscelatore = true;

  // (Mantenuta nel codice ma non usata nell'interfaccia per allineamento a iOS)
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentRifornimento = widget.rifornimento;
    _loadScooterDetails(); // NUOVO: Carica i dettagli dello scooter all'avvio
  }

  // NUOVO: Funzione per recuperare lo stato del miscelatore (come in Swift)
  Future<void> _loadScooterDetails() async {
    setState(() => _isLoadingScooterDetails = true);

    // Ritardo simulato per fluidità come in Swift (DispatchQueue.main.asyncAfter)
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final scooter = await _scooterRepository.getScooterById(widget.scooterId);
      if (scooter != null) {
        _scooterHasMiscelatore = scooter.miscelatore;
      }
    } catch (e) {
      _scooterHasMiscelatore = true; // Valore di default in caso di errore
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEditRifornimento() async {
    final Rifornimento? updatedRifornimento = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRifornimentoScreen(
          scooterId: widget.scooterId,
          rifornimento: _currentRifornimento,
        ),
      ),
    );

    // Se torniamo con un dato aggiornato, ricarichiamo la UI
    if (updatedRifornimento != null) {
      setState(() {
        _currentRifornimento = updatedRifornimento;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gestione del blocco interfaccia (come .allowsHitTesting in Swift)
    final bool isUIBlocked = _isLoadingScooterDetails || _isDeleting;
    final Color iconColor = isUIBlocked ? Colors.grey : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isUIBlocked ? null : () => Navigator.pop(context, true),
        ),
        actions: [
          // Tasto modifica allineato a Swift
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
                  // CARD DETTAGLI (Stile Form iOS)
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

                        // SEZIONE OLIO (Logica allineata a Swift)
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

                        // Riga Consumo Medio con icona Info
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

          // Spinner Centrale di caricamento
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

  // Riga helper per icone e testi (Stile Swift HStack)
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

  // --- FUNZIONE DI ELIMINAZIONE NASCOSTA ---
  // In Swift questa schermata non ha il tasto elimina (si elimina dalla lista tramite swipe).
  // Se vuoi rimettere il tasto elimina nella AppBar, de-commenta il tasto nella build
  // e chiama questa funzione.
  Future<void> _confirmAndDeleteRifornimento() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina'),
        content: const Text('Eliminare questo record? l\'azione è irreversibile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULLA')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINA', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && _currentRifornimento.id != null) {
      setState(() => _isDeleting = true);
      try {
        await _rifornimentoRepository.deleteRifornimento(_currentRifornimento.id!);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isDeleting = false);
      }
    }
  }
}