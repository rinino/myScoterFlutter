import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myscoterflutter/models/rifornimento.dart';
import 'package:myscoterflutter/models/scooter.dart';
import 'package:myscoterflutter/repository/rifornimento_repository.dart';
import 'package:myscoterflutter/repository/scooter_repository.dart';

class AddEditRifornimentoScreen extends StatefulWidget {
  final int scooterId;
  final Rifornimento? rifornimento;

  const AddEditRifornimentoScreen({
    super.key,
    required this.scooterId,
    this.rifornimento,
  });

  @override
  State<AddEditRifornimentoScreen> createState() => _AddEditRifornimentoScreenState();
}

class _AddEditRifornimentoScreenState extends State<AddEditRifornimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final RifornimentoRepository _rifornimentoRepository = RifornimentoRepository();
  final ScooterRepository _scooterRepository = ScooterRepository();

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
    setState(() {
      _isLoadingData = true;
    });

    try {
      final Scooter? scooter = await _scooterRepository.getScooterById(widget.scooterId);
      if (scooter != null) {
        _scooterHasMiscelatore = scooter.miscelatore;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore: Dettagli scooter non trovati.')),
          );
        }
        _isLoadingData = false;
        return;
      }

      // Carica il rifornimento precedente SOLO se stiamo aggiungendo un nuovo rifornimento
      // O se stiamo modificando ma il rifornimento corrente NON è il più recente.
      // Questa logica è cruciale per i calcoli.
      _previousRifornimento = await _rifornimentoRepository.getPreviousRifornimentoExcluding(
        widget.scooterId,
        widget.rifornimento?.id, // Esclude il rifornimento corrente se in modalità modifica
      );
      _calculateStats();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel caricamento dei dati iniziali.')),
        );
      }
    } finally {
      setState(() {
        _isLoadingData = false;
      });
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
        if (_kmPercorsi < 0) {
          _kmPercorsi = 0.0;
        }
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

    if (litriBenzina != null && litriBenzina > 0 && percentualeOlio != null && percentualeOlio >= 0) {
      final double litriOlioCalculated = litriBenzina * (percentualeOlio / 100.0);
      _litriOlioController.text = litriOlioCalculated.toStringAsFixed(2);
    } else {
      _litriOlioController.text = '';
    }
  }

  double? _parseToDouble(String text) {
    if (text.isEmpty) return null;
    String cleanedText = text.replaceAll(',', '.');
    return double.tryParse(cleanedText);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _saveRifornimento() async {
    // Il metodo validate() chiama i validator di tutti i TextFormField
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Controlla i campi evidenziati per errori.');
      return;
    }

    // Validazioni logiche aggiuntive che non possono essere fatte solo con i validator dei TextFormField
    final double? kmAttuali = _parseToDouble(_kmAttualiController.text);
    final double? litriBenzina = _parseToDouble(_litriBenzinaController.text);
    double? litriOlio;
    double? percentualeOlio;

    if (_scooterHasMiscelatore) {
      litriOlio = _parseToDouble(_litriOlioController.text);
      // Se il miscelatore è presente, i litri olio sono opzionali, ma se ci sono devono essere >= 0
      if (litriOlio != null && litriOlio < 0) {
        _showErrorSnackBar('I litri di olio non possono essere negativi.');
        return;
      }
    } else {
      percentualeOlio = _parseToDouble(_percentualeOlioController.text);
      // Se non ha miscelatore, percentualeOlio è obbligatoria e deve essere tra 0 e 100
      if (percentualeOlio == null || percentualeOlio < 0 || percentualeOlio > 100) {
        _showErrorSnackBar('La percentuale di olio deve essere un valore tra 0 e 100.');
        return;
      }
      // Ricalcola i litri olio per assicurarti che siano aggiornati
      _calculateCalculatedLitriOlio();
      litriOlio = _parseToDouble(_litriOlioController.text); // Prendi il valore calcolato
    }

    setState(() {
      _isSaving = true;
    });

    _calculateStats(); // Assicurati che siano aggiornati prima di salvare

    final Rifornimento rifornimentoToSave = Rifornimento(
      id: widget.rifornimento?.id,
      idScooter: widget.scooterId,
      dataRifornimento: _selectedDate.millisecondsSinceEpoch,
      kmAttuali: kmAttuali!, // Già validato come non nullo e > 0
      litriBenzina: litriBenzina!, // Già validato come non nullo e > 0
      litriOlio: litriOlio,
      percentualeOlio: percentualeOlio,
      kmPercorsi: _kmPercorsi,
      mediaConsumo: _mediaConsumo,
    );

    try {
      if (widget.rifornimento == null) {
        await _rifornimentoRepository.insertRifornimento(rifornimentoToSave);
      } else {
        await _rifornimentoRepository.updateRifornimento(rifornimentoToSave);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il salvataggio del rifornimento.')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _kmAttualiController.removeListener(_calculateStats);
    _litriBenzinaController.removeListener(_calculateStats);
    _percentualeOlioController.removeListener(_calculateCalculatedLitriOlio);
    _kmAttualiController.dispose();
    _litriBenzinaController.dispose();
    _litriOlioController.dispose();
    _percentualeOlioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final Color appBarTitleColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color detailTextColor = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rifornimento == null ? 'Aggiungi Rifornimento' : 'Modifica Rifornimento'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Stack(
        children: [
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Rifornimento:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: detailTextColor),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isLoadingData ? null : () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                        prefixIcon: Icon(Icons.calendar_today, color: detailTextColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _kmAttualiController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Km Attuali',
                      hintText: 'Inserisci i km attuali',
                      labelStyle: TextStyle(color: detailTextColor),
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: Icon(Icons.speed, color: detailTextColor),
                    ),
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isLoadingData,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'I Km Attuali sono obbligatori.';
                      }
                      final val = _parseToDouble(value);
                      if (val == null) {
                        return 'Inserisci un numero valido (usa . per i decimali).';
                      }
                      if (val <= 0) {
                        return 'I Km Attuali devono essere maggiori di 0.';
                      }
                      if (_previousRifornimento != null && val <= _previousRifornimento!.kmAttuali) {
                        return "Devono essere maggiori dei km dell'ultimo rifornimento (${_previousRifornimento!.kmAttuali.toStringAsFixed(0)}).";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _litriBenzinaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Litri Benzina',
                      hintText: 'Inserisci i litri di benzina',
                      labelStyle: TextStyle(color: detailTextColor),
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: Icon(Icons.local_gas_station, color: detailTextColor),
                    ),
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isLoadingData,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'I Litri di Benzina sono obbligatori.';
                      }
                      final val = _parseToDouble(value);
                      if (val == null) {
                        return 'Inserisci un numero valido (usa . per i decimali).';
                      }
                      if (val <= 0) {
                        return 'I Litri di Benzina devono essere maggiori di 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (!_scooterHasMiscelatore)
                    TextFormField(
                      controller: _percentualeOlioController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Percentuale Olio (%)',
                        hintText: 'Es. 2 per 2%',
                        labelStyle: TextStyle(color: detailTextColor),
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: Colors.grey[800],
                        prefixIcon: Icon(Icons.percent, color: detailTextColor),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled: !_isLoadingData,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La Percentuale Olio è obbligatoria per questo scooter.';
                        }
                        final val = _parseToDouble(value);
                        if (val == null) {
                          return 'Inserisci un numero valido (usa . per i decimali).';
                        }
                        if (val < 0 || val > 100) {
                          return 'Il valore deve essere tra 0 e 100.';
                        }
                        return null;
                      },
                    ),
                  if (!_scooterHasMiscelatore) const SizedBox(height: 16),

                  TextFormField(
                    controller: _litriOlioController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _scooterHasMiscelatore ? 'Litri Olio (Opzionale)' : 'Litri Olio (Calcolato)',
                      hintText: _scooterHasMiscelatore ? 'Inserisci i litri di olio' : 'Calcolato automaticamente',
                      labelStyle: TextStyle(color: detailTextColor),
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: Icon(Icons.oil_barrel, color: detailTextColor),
                    ),
                    style: TextStyle(color: _scooterHasMiscelatore ? Colors.white : Colors.white54),
                    readOnly: !_scooterHasMiscelatore,
                    enabled: !_isLoadingData && _scooterHasMiscelatore,
                    validator: (value) {
                      if (_scooterHasMiscelatore && value != null && value.isNotEmpty) {
                        final val = _parseToDouble(value);
                        if (val == null) {
                          return 'Inserisci un numero valido (usa . per i decimali).';
                        }
                        if (val < 0) {
                          return 'I Litri di Olio non possono essere negativi.';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Km Percorsi:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: detailTextColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade600),
                    ),
                    child: Text(
                      _kmPercorsi >= 0
                          ? '${_kmPercorsi.toStringAsFixed(2)} km (dal rifornimento precedente a Km ${_previousRifornimento?.kmAttuali.toStringAsFixed(0) ?? 'N/A'})'
                          : 'Inserisci i Km Attuali',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Media Consumo:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: detailTextColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade600),
                    ),
                    child: Text(
                      _mediaConsumo > 0
                          ? '${_mediaConsumo.toStringAsFixed(2)} km/L'
                          : 'Inserisci Km Attuali e Litri Benzina',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isSaving || _isLoadingData) ? null : _saveRifornimento,
                      icon: _isSaving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.save),
                      label: Text(widget.rifornimento == null ? 'Salva Rifornimento' : 'Aggiorna Rifornimento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}