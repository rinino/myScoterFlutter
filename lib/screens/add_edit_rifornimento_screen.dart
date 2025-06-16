import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myscoterflutter/models/rifornimento.dart';
import 'package:myscoterflutter/models/scooter.dart'; // Importa il modello Scooter
import 'package:myscoterflutter/repository/rifornimento_repository.dart';
import 'package:myscoterflutter/repository/scooter_repository.dart'; // Importa il repository Scooter

class AddEditRifornimentoScreen extends StatefulWidget {
  final int scooterId;
  final Rifornimento? rifornimento; // Opzionale, per la modifica di un rifornimento esistente

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
  final ScooterRepository _scooterRepository = ScooterRepository(); // Istanzia il ScooterRepository

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _kmAttualiController = TextEditingController();
  final TextEditingController _litriBenzinaController = TextEditingController();
  final TextEditingController _litriOlioController = TextEditingController();
  final TextEditingController _percentualeOlioController = TextEditingController();

  double _kmPercorsi = 0.0;
  double _mediaConsumo = 0.0;

  bool _isSaving = false;
  bool _isLoadingData = true; // Unico flag per caricamento dati iniziali
  Rifornimento? _previousRifornimento; // Il rifornimento precedente per i calcoli

  bool _scooterHasMiscelatore = false; // Caricato dal DB

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Carica dettagli scooter e rifornimento precedente
    _setupControllersListeners();

    if (widget.rifornimento != null) {
      // Se stiamo modificando un rifornimento esistente
      // Modifica qui: converti il timestamp in DateTime
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.rifornimento!.dataRifornimento);
      _kmAttualiController.text = widget.rifornimento!.kmAttuali.toString(); // Non formattare qui per l'editing
      _litriBenzinaController.text = widget.rifornimento!.litriBenzina.toString(); // Non formattare qui

      if (widget.rifornimento!.litriOlio != null) {
        _litriOlioController.text = widget.rifornimento!.litriOlio.toString();
      }
      if (widget.rifornimento!.percentualeOlio != null) {
        _percentualeOlioController.text = widget.rifornimento!.percentualeOlio.toString();
      }
      // I kmPercorsi e mediaConsumo verranno ricalcolati dopo il caricamento del precedente
    }
  }

  // Simile a onAppear in SwiftUI: carica tutti i dati iniziali
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // 1. Carica i dettagli dello Scooter per il flag miscelatore
      final Scooter? scooter = await _scooterRepository.getScooterById(widget.scooterId);
      if (scooter != null) {
        _scooterHasMiscelatore = scooter.miscelatore;
      } else {
        // Se lo scooter non esiste, c'è un problema. Gestisci l'errore.
        print("Errore: Scooter con ID ${widget.scooterId} non trovato.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore: Dettagli scooter non trovati.')),
          );
          // Forse potresti fare Navigator.pop(context, false) qui
        }
        _isLoadingData = false; // Termina il caricamento
        return;
      }

      // 2. Carica il rifornimento precedente (escludendo quello corrente se in modifica)
      _previousRifornimento = await _rifornimentoRepository.getPreviousRifornimentoExcluding(
        widget.scooterId,
        widget.rifornimento?.id,
      );
      _calculateStats(); // Calcola i valori iniziali dopo il caricamento dei dati

    } catch (e) {
      print("Errore nel caricamento dei dati iniziali: $e");
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
    // Aggiungi listener per ricalcolare i valori derivati in tempo reale
    _kmAttualiController.addListener(_calculateStats);
    _litriBenzinaController.addListener(_calculateStats);
    _percentualeOlioController.addListener(_calculateCalculatedLitriOlio); // Solo per campo percentuale olio
  }

  void _calculateStats() {
    // Questa funzione calcola kmPercorsi e mediaConsumo
    final double? kmAttuali = _parseToDouble(_kmAttualiController.text);
    final double? litriBenzina = _parseToDouble(_litriBenzinaController.text);

    setState(() {
      if (kmAttuali != null && _previousRifornimento != null) {
        _kmPercorsi = kmAttuali - _previousRifornimento!.kmAttuali;
        if (_kmPercorsi < 0) {
          _kmPercorsi = 0.0; // Evita valori negativi
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
    // Questa funzione è chiamata solo se lo scooter NON ha il miscelatore,
    // per calcolare i litri di olio in base a benzina e percentuale.
    if (_scooterHasMiscelatore) return; // Non calcolare se ha miscelatore (litri olio è manuale)

    final double? litriBenzina = _parseToDouble(_litriBenzinaController.text);
    final double? percentualeOlio = _parseToDouble(_percentualeOlioController.text);

    if (litriBenzina != null && litriBenzina > 0 && percentualeOlio != null && percentualeOlio >= 0) {
      final double litriOlioCalculated = litriBenzina * (percentualeOlio / 100.0);
      _litriOlioController.text = litriOlioCalculated.toStringAsFixed(2);
    } else {
      _litriOlioController.text = ''; // Resetta se i valori non sono validi
    }
  }

  // Funzione di utilità per parsare stringhe con "," o "." in double
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
            ),
            dialogBackgroundColor: Colors.grey[900],
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
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Assicurati di aver inserito valori validi per tutti i campi obbligatori.');
      return;
    }

    // Ulteriore validazione logica qui, come in Swift
    final double? kmAttuali = _parseToDouble(_kmAttualiController.text);
    final double? litriBenzina = _parseToDouble(_litriBenzinaController.text);
    double? litriOlio;
    double? percentualeOlio;

    if (_scooterHasMiscelatore) {
      litriOlio = _parseToDouble(_litriOlioController.text);
      // Se il campo litri olio è manuale, non è strettamente obbligatorio
      // a meno che tu non voglia forzarlo.
      // Se è vuoto, rimane null. Se c'è, deve essere valido.
    } else {
      percentualeOlio = _parseToDouble(_percentualeOlioController.text);
      // Assicurati che i litri olio siano calcolati se non lo sono già stati
      _calculateCalculatedLitriOlio();
      litriOlio = _parseToDouble(_litriOlioController.text); // Prendi il valore calcolato
    }

    if (kmAttuali == null || litriBenzina == null || kmAttuali <= 0 || litriBenzina <= 0) {
      // Questo dovrebbe essere già coperto dai validator dei TextFormField
      _showErrorSnackBar('I campi Km Attuali e Litri Benzina devono essere numeri positivi.');
      return;
    }

    if (!_scooterHasMiscelatore && (percentualeOlio == null || percentualeOlio < 0 || percentualeOlio > 100)) {
      // Questo dovrebbe essere già coperto dal validator di percentualeOlio
      _showErrorSnackBar('La percentuale di olio deve essere tra 0 e 100.');
      return;
    }

    if (_previousRifornimento != null && kmAttuali <= _previousRifornimento!.kmAttuali) {
      _showErrorSnackBar("I chilometri attuali non possono essere minori o uguali ai chilometri dell'ultimo rifornimento.");
      return;
    }


    setState(() {
      _isSaving = true;
    });

    // Assicurati che kmPercorsi e mediaConsumo siano calcolati prima del salvataggio
    _calculateStats();

    final Rifornimento rifornimentoToSave = Rifornimento(
      id: widget.rifornimento?.id, // Se stiamo modificando, usa l'ID esistente
      idScooter: widget.scooterId,
      dataRifornimento: _selectedDate.millisecondsSinceEpoch, // Modifica qui: passa il timestamp
      kmAttuali: kmAttuali,
      litriBenzina: litriBenzina,
      litriOlio: litriOlio,          // Sarà null se non ha miscelatore, o il valore inserito
      percentualeOlio: percentualeOlio, // Sarà null se ha miscelatore, o il valore inserito
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
        Navigator.pop(context, true); // Torna indietro e indica successo
      }
    } catch (e) {
      print('Errore durante il salvataggio del rifornimento: $e');
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
    final Color appBarTitleColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final Color detailTextColor = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rifornimento == null ? 'Aggiungi Rifornimento' : 'Modifica Rifornimento'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Stack(
        children: [
          _isLoadingData // Mostra un loader finché i dati iniziali non sono caricati
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Selettore Data ---
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

                  // --- Km Attuali ---
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
                    enabled: !_isLoadingData, // Disabilita durante il caricamento
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci i km attuali';
                      }
                      final val = _parseToDouble(value);
                      if (val == null || val <= 0) {
                        return 'Inserisci un valore numerico valido (> 0)';
                      }
                      if (_previousRifornimento != null && val <= _previousRifornimento!.kmAttuali) {
                        return "Deve essere maggiore dei km dell'ultimo rifornimento (${_previousRifornimento!.kmAttuali.toStringAsFixed(0)})";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Litri Benzina ---
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
                        return 'Inserisci i litri di benzina';
                      }
                      if (_parseToDouble(value) == null || _parseToDouble(value)! <= 0) {
                        return 'Inserisci un valore numerico valido (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Percentuale Olio (se NO miscelatore) ---
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
                          return 'Inserisci la percentuale di olio';
                        }
                        final val = _parseToDouble(value);
                        if (val == null || val < 0 || val > 100) {
                          return 'Inserisci un valore numerico valido (0-100)';
                        }
                        return null;
                      },
                    ),
                  if (!_scooterHasMiscelatore) const SizedBox(height: 16),

                  // --- Litri Olio (Condizionale, abilitato/disabilitato) ---
                  TextFormField(
                    controller: _litriOlioController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: _scooterHasMiscelatore ? 'Litri Olio' : 'Litri Olio (calcolato)',
                      hintText: _scooterHasMiscelatore ? 'Inserisci i litri di olio' : 'Calcolato automaticamente',
                      labelStyle: TextStyle(color: detailTextColor),
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      filled: true,
                      fillColor: Colors.grey[800],
                      prefixIcon: Icon(Icons.oil_barrel, color: detailTextColor),
                    ),
                    style: TextStyle(color: _scooterHasMiscelatore ? Colors.white : Colors.white54),
                    readOnly: !_scooterHasMiscelatore, // Read-only se non ha miscelatore
                    enabled: !_isLoadingData && _scooterHasMiscelatore, // Disabilita se è calcolato o in caricamento
                    validator: (value) {
                      if (_scooterHasMiscelatore) { // Solo se il campo è modificabile
                        // Litri olio è opzionale per scooter con miscelatore, quindi non è richiesta la non-vuotaggine
                        if (value != null && value.isNotEmpty) {
                          if (_parseToDouble(value) == null || _parseToDouble(value)! < 0) {
                            return 'Inserisci un valore numerico valido (>= 0)';
                          }
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Km Percorsi (Visualizzazione) ---
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

                  // --- Media Consumo (Visualizzazione) ---
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

                  // --- Pulsante Salva ---
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
          if (_isSaving) // Copertura modale quando si salva
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
        ],
      ),
    );
  }
}