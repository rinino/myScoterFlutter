// lib/screens/add_edit_rifornimento_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // AGGIUNTO
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/core/providers/core_providers.dart'; // AGGIUNTO PER I PROVIDER

// 1. Cambiato in ConsumerStatefulWidget
class AddEditRifornimentoScreen extends ConsumerStatefulWidget {
  final int scooterId;
  final Rifornimento? rifornimento;

  const AddEditRifornimentoScreen({
    super.key,
    required this.scooterId,
    this.rifornimento,
  });

  @override
  ConsumerState<AddEditRifornimentoScreen> createState() => _AddEditRifornimentoScreenState();
}

// 2. Cambiato in ConsumerState
class _AddEditRifornimentoScreenState extends ConsumerState<AddEditRifornimentoScreen> {
  final _formKey = GlobalKey<FormState>();

  // 3. RIMOSSE LE ISTANZE DIRETTE!
  // final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository();
  // final ScooterRepository _scooterRepository = ScooterRepository();

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _kmAttualiController = TextEditingController();
  final TextEditingController _litriBenzinaController = TextEditingController();
  final TextEditingController _litriOlioController = TextEditingController();
  final TextEditingController _percentualeOlioController = TextEditingController();

  double _kmPercorsi = 0.0;
  double _mediaConsumo = 0.0;

  bool _isSaving = false;
  bool _isLoadingData = true;
  Rifornimento? _previousRifornimento;
  bool _scooterHasMiscelatore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupControllersListeners();

    // Se siamo in modalità modifica, prepopoliamo i campi
    if (widget.rifornimento != null) {
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.rifornimento!.dataRifornimento);
      _kmAttualiController.text = widget.rifornimento!.kmAttuali.toString();
      _litriBenzinaController.text = widget.rifornimento!.litriBenzina.toString();

      if (widget.rifornimento!.litriOlio != null) {
        _litriOlioController.text = widget.rifornimento!.litriOlio.toString();
      }
      if (widget.rifornimento!.percentualeOlio != null) {
        _percentualeOlioController.text = widget.rifornimento!.percentualeOlio.toString();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    try {
      // 4. USIAMO ref.read PER ACCEDERE AL REPOSITORY DEGLI SCOOTER
      final Scooter? scooter = await ref.read(scooterRepoProvider).getScooterById(widget.scooterId);
      if (scooter != null) {
        _scooterHasMiscelatore = scooter.miscelatore;
      }

      // 5. USIAMO ref.read PER ACCEDERE AL REPOSITORY DEI RIFORNIMENTI
      _previousRifornimento = await ref.read(rifornimentoRepoProvider).getPreviousRifornimentoExcluding(
        widget.scooterId,
        widget.rifornimento?.id,
      );

      _calculateStats();
    } catch (e) {
      _showErrorSnackBar('Errore nel caricamento dei dati iniziali.');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  void _setupControllersListeners() {
    _kmAttualiController.addListener(_calculateStats);
    _litriBenzinaController.addListener(_calculateStats);
    _percentualeOlioController.addListener(_calculateCalculatedLitriOlio);
  }

  void _calculateStats() {
    final double? kmAttuali = _parseToDouble(_kmAttualiController.text);
    final double? litriBenzina = _parseToDouble(_litriBenzinaController.text);

    setState(() {
      if (kmAttuali != null && _previousRifornimento != null) {
        _kmPercorsi = kmAttuali - _previousRifornimento!.kmAttuali;
        if (_kmPercorsi < 0) _kmPercorsi = 0.0;
      } else {
        _kmPercorsi = 0.0;
      }

      if (_kmPercorsi > 0 && litriBenzina != null && litriBenzina > 0) {
        _mediaConsumo = _kmPercorsi / litriBenzina;
      } else {
        _mediaConsumo = 0.0;
      }
    });
  }

  void _calculateCalculatedLitriOlio() {
    if (_scooterHasMiscelatore) return;
    final double? litriBenzina = _parseToDouble(_litriBenzinaController.text);
    final double? percentualeOlio = _parseToDouble(_percentualeOlioController.text);

    if (litriBenzina != null && percentualeOlio != null) {
      final double litriOlioCalculated = litriBenzina * (percentualeOlio / 100.0);
      _litriOlioController.text = litriOlioCalculated.toStringAsFixed(2);
    }
  }

  double? _parseToDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  Future<void> _saveRifornimento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final Rifornimento rifornimentoToSave = Rifornimento(
      id: widget.rifornimento?.id,
      idScooter: widget.scooterId,
      dataRifornimento: _selectedDate.millisecondsSinceEpoch,
      kmAttuali: _parseToDouble(_kmAttualiController.text)!,
      litriBenzina: _parseToDouble(_litriBenzinaController.text)!,
      litriOlio: _parseToDouble(_litriOlioController.text),
      percentualeOlio: _parseToDouble(_percentualeOlioController.text),
      kmPercorsi: _kmPercorsi,
      mediaConsumo: _mediaConsumo,
    );

    try {
      // 6. USIAMO ref.read ANCHE PER SALVARE E AGGIORNARE
      if (widget.rifornimento == null) {
        await ref.read(rifornimentoRepoProvider).insertRifornimento(rifornimentoToSave);
      } else {
        await ref.read(rifornimentoRepoProvider).updateRifornimento(rifornimentoToSave);
      }

      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context).pop(rifornimentoToSave);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Errore durante il salvataggio.');
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rifornimento == null ? 'Nuovo Rifornimento' : 'Modifica Rifornimento'),
        centerTitle: true,
        actions: [
          if (!_isLoadingData)
            TextButton(
              onPressed: _isSaving ? null : _saveRifornimento,
              child: const Text('SALVA', style: TextStyle(fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("DATA E CHILOMETRI"),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildKmInput(),
                  const SizedBox(height: 24),
                  _buildSectionLabel("CARBURANTE E MISCELA"),
                  _buildBenzinaInput(),
                  const SizedBox(height: 16),
                  if (!_scooterHasMiscelatore) ...[
                    _buildPercentualeOlioInput(),
                    const SizedBox(height: 16),
                  ],
                  _buildLitriOlioInput(),
                  const SizedBox(height: 32),
                  _buildStatsSummary(),
                ],
              ),
            ),
          ),
          if (_isSaving)
            const Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isSaving)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.blue),
        title: const Text("Data"),
        trailing: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
      ),
    );
  }

  Widget _buildKmInput() {
    return TextFormField(
      controller: _kmAttualiController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Km Attuali',
        prefixIcon: Icon(Icons.speed, color: Colors.blue),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final val = _parseToDouble(value ?? '');
        if (val == null) return 'Campo obbligatorio';
        if (_previousRifornimento != null && val <= _previousRifornimento!.kmAttuali) {
          return "Deve essere > del precedente (${_previousRifornimento!.kmAttuali.toInt()} km)";
        }
        return null;
      },
    );
  }

  Widget _buildBenzinaInput() {
    return TextFormField(
      controller: _litriBenzinaController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Litri Benzina',
        prefixIcon: Icon(Icons.local_gas_station, color: Colors.blue),
        border: OutlineInputBorder(),
      ),
      validator: (value) => _parseToDouble(value ?? '') == null ? 'Inserisci i litri' : null,
    );
  }

  Widget _buildPercentualeOlioInput() {
    return TextFormField(
      controller: _percentualeOlioController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Percentuale Olio (%)',
        prefixIcon: Icon(Icons.percent, color: Colors.blue),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLitriOlioInput() {
    return TextFormField(
      controller: _litriOlioController,
      enabled: _scooterHasMiscelatore,
      decoration: InputDecoration(
        labelText: _scooterHasMiscelatore ? 'Litri Olio' : 'Litri Olio (Calcolato)',
        prefixIcon: const Icon(Icons.oil_barrel, color: Colors.blue),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildStatRow("Percorrenza dal precedente", "${_kmPercorsi.toStringAsFixed(1)} km"),
          const Divider(height: 24),
          _buildStatRow("Consumo medio", "${_mediaConsumo.toStringAsFixed(2)} km/L"),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
      ],
    );
  }

  @override
  void dispose() {
    _kmAttualiController.dispose();
    _litriBenzinaController.dispose();
    _litriOlioController.dispose();
    _percentualeOlioController.dispose();
    super.dispose();
  }
}