import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myscooter/models/scooter.dart';
import 'package:myscooter/models/rifornimento.dart';
import 'package:myscooter/repository/rifornimento_repository.dart';
import 'package:myscooter/repository/scooter_repository.dart';
import 'package:myscooter/screens/add_edit_scooter_screen.dart';
import 'package:myscooter/screens/add_edit_rifornimento_screen.dart';
import 'package:myscooter/screens/rifornimento_detail_screen.dart';
import 'package:intl/intl.dart';

class ScooterDetailScreen extends StatefulWidget {
  final Scooter scooter;

  const ScooterDetailScreen({super.key, required this.scooter});

  @override
  State<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends State<ScooterDetailScreen> {
  final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository();
  final ScooterRepository _scooterRepository = ScooterRepository();

  List<Rifornimento> _rifornimenti = [];
  bool _isLoadingRifornimenti = true;
  bool _isProcessingAction = false;

  late Scooter _currentScooter;

  @override
  void initState() {
    super.initState();
    _currentScooter = widget.scooter;
    _loadRifornimenti();
  }

  Future<void> _loadRifornimenti() async {
    setState(() => _isLoadingRifornimenti = true);

    if (_currentScooter.id == null) {
      setState(() {
        _rifornimenti = [];
        _isLoadingRifornimenti = false;
      });
      return;
    }

    try {
      final rifornimenti = await _rifornimentoRepository.getRifornimentiForScooter(_currentScooter.id!);

      // Piccolo delay per fluidità UI
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _rifornimenti = rifornimenti;
        _isLoadingRifornimenti = false;
      });
    } catch (e) {
      setState(() => _isLoadingRifornimenti = false);
      if (mounted) _showSnackBar('Errore nel caricamento dei rifornimenti.');
    }
  }

  Future<void> _deleteRifornimento(int id) async {
    setState(() => _isProcessingAction = true);
    try {
      await _rifornimentoRepository.deleteRifornimento(id);
      setState(() {
        _rifornimenti.removeWhere((r) => r.id == id);
      });
      if (mounted) _showSnackBar('Rifornimento eliminato.');
    } catch (e) {
      if (mounted) _showSnackBar('Errore durante l\'eliminazione.');
    } finally {
      setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _navigateToEditScooter() async {
    final Scooter? updatedScooter = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditScooterScreen(scooter: _currentScooter),
      ),
    );

    if (updatedScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        await _scooterRepository.updateScooter(updatedScooter);
        setState(() => _currentScooter = updatedScooter);
        await _loadRifornimenti();
        if (mounted) _showSnackBar('Scooter aggiornato!');
      } catch (e) {
        if (mounted) _showSnackBar('Errore durante il salvataggio.');
      } finally {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  // --- CORREZIONE QUI: rimosso il vincolo 'bool?' che causava il crash ---
  Future<void> _navigateToAddRifornimento() async {
    if (_isProcessingAction) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRifornimentoScreen(scooterId: _currentScooter.id!),
      ),
    );

    // Se result non è nullo, significa che è stato salvato un rifornimento
    if (result != null) {
      await _loadRifornimenti();
      if (mounted) _showSnackBar('Rifornimento salvato!');
    }
  }

  // --- CORREZIONE QUI: rimosso il vincolo 'bool?' ---
  Future<void> _navigateToRifornimentoDetail(Rifornimento rifornimento) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RifornimentoDetailScreen(
          rifornimento: rifornimento,
          scooterId: _currentScooter.id!,
        ),
      ),
    );

    if (result != null) {
      await _loadRifornimenti();
    }
  }

  void _openImageViewer() {
    if (_currentScooter.imgPath == null || !File(_currentScooter.imgPath!).existsSync()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(File(_currentScooter.imgPath!)),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isUIBlocked = _isProcessingAction || _isLoadingRifornimenti;
    final Color iconColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentScooter.marca} ${_currentScooter.modello}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isUIBlocked ? null : () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isUIBlocked ? null : _navigateToEditScooter,
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isUIBlocked,
            child: Opacity(
              opacity: isUIBlocked ? 0.6 : 1.0,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCircularImage(),
                  const SizedBox(height: 24),
                  _buildScooterDetailsCard(iconColor),
                  const SizedBox(height: 24),
                  _buildRifornimentiSection(iconColor),
                ],
              ),
            ),
          ),
          if (isUIBlocked)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildCircularImage() {
    final bool hasImage = _currentScooter.imgPath != null && File(_currentScooter.imgPath!).existsSync();

    return Center(
      child: GestureDetector(
        onTap: hasImage && !_isProcessingAction ? _openImageViewer : null,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withOpacity(0.5), width: 3),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: ClipOval(
            child: hasImage
                ? Image.file(File(_currentScooter.imgPath!), fit: BoxFit.cover)
                : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.moped, size: 50, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScooterDetailsCard(Color iconColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _detailRow(Icons.sell, 'Marca', _currentScooter.marca, iconColor),
            const Divider(),
            _detailRow(Icons.moped, 'Modello', _currentScooter.modello, iconColor),
            const Divider(),
            _detailRow(Icons.engineering, 'Cilindrata', '${_currentScooter.cilindrata} cc', iconColor),
            const Divider(),
            _detailRow(Icons.water_drop, 'Miscelatore', _currentScooter.miscelatore ? 'Sì' : 'No', iconColor),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRifornimentiSection(Color btnColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RIFORNIMENTI', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: _isProcessingAction ? null : _navigateToAddRifornimento,
            )
          ],
        ),
        if (!_isLoadingRifornimenti && _rifornimenti.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Nessun dato presente'))),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rifornimenti.length,
          itemBuilder: (context, index) {
            final rif = _rifornimenti[index];
            return Dismissible(
              key: Key(rif.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (dir) => _showConfirmDialog(),
              onDismissed: (dir) => _deleteRifornimento(rif.id!),
              child: ListTile(
                leading: const Icon(Icons.local_gas_station),
                title: Text(DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(rif.dataRifornimento))),
                subtitle: Text('${rif.kmAttuali.toInt()} km - ${rif.mediaConsumo?.toStringAsFixed(2) ?? "N/A"} km/L'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToRifornimentoDetail(rif),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina'),
        content: const Text('Vuoi eliminare questo record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ANNULLA')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ELIMINA', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}