import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/core/providers/core_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../scooter/model/scooter.dart';

// FIX: Importiamo il Design System
import 'package:myscooter/core/theme/app_colors.dart';

class AddEditRifornimentoScreen extends ConsumerStatefulWidget {
  final String scooterId;
  final Rifornimento? rifornimento;
  const AddEditRifornimentoScreen({
    super.key,
    required this.scooterId,
    this.rifornimento,
  });
  @override
  ConsumerState<AddEditRifornimentoScreen> createState() => _AddEditRifornimentoScreenState();
}

class _AddEditRifornimentoScreenState extends ConsumerState<AddEditRifornimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _kmAttualiController = TextEditingController();
  final TextEditingController _litriBenzinaController = TextEditingController();
  final TextEditingController _litriOlioController = TextEditingController();
  final TextEditingController _percentualeOlioController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  double? _latitudine;
  double? _longitudine;
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
      _selectedDate = widget.rifornimento!.dataRifornimento;
      _kmAttualiController.text = widget.rifornimento!.kmAttuali.toString();
      _litriBenzinaController.text = widget.rifornimento!.litriBenzina.toString();
      if (widget.rifornimento!.litriOlio != null) {
        _litriOlioController.text = widget.rifornimento!.litriOlio.toString();
      }
      if (widget.rifornimento!.percentualeOlio != null) {
        _percentualeOlioController.text = widget.rifornimento!.percentualeOlio.toString();
      }
      if (widget.rifornimento!.costo != null) {
        _costoController.text = widget.rifornimento!.costo.toString();
      }
      if (widget.rifornimento!.note != null) {
        _noteController.text = widget.rifornimento!.note!;
      }
      _latitudine = widget.rifornimento!.latitudine;
      _longitudine = widget.rifornimento!.longitudine;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    try {
      final Scooter? scooter = await ref.read(scooterRepoProvider).getScooterById(widget.scooterId);
      if (scooter != null) {
        _scooterHasMiscelatore = scooter.miscelatore;
      }
      _previousRifornimento = await ref.read(rifornimentoRepoProvider).getPreviousRifornimentoExcluding(
        widget.scooterId,
        widget.rifornimento?.id,
      );
      _calculateStats();
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(AppLocalizations.of(context)!.errorInitialData);
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
    final String noteText = _noteController.text.trim();
    final String? noteFinali = noteText.isEmpty ? null : noteText;
    final Rifornimento rifornimentoToSave = Rifornimento(
      id: widget.rifornimento?.id,
      idScooter: widget.scooterId,
      dataRifornimento: _selectedDate,
      kmAttuali: _parseToDouble(_kmAttualiController.text)!,
      litriBenzina: _parseToDouble(_litriBenzinaController.text)!,
      litriOlio: _parseToDouble(_litriOlioController.text),
      percentualeOlio: _parseToDouble(_percentualeOlioController.text),
      kmPercorsi: _kmPercorsi,
      mediaConsumo: _mediaConsumo,
      costo: _parseToDouble(_costoController.text),
      note: noteFinali,
      latitudine: _latitudine,
      longitudine: _longitudine,
    );
    try {
      if (widget.rifornimento == null) {
        await ref.read(rifornimentoRepoProvider).insertRifornimento(rifornimentoToSave);
      } else {
        await ref.read(rifornimentoRepoProvider).updateRifornimento(rifornimentoToSave);
      }
      if (mounted) {
        Future.microtask(() {
          if (mounted) Navigator.of(context).pop(rifornimentoToSave);
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(AppLocalizations.of(context)!.errorSaving);
      setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent, // FIX: Sfondo trasparente
      extendBodyBehindAppBar: true,        // FIX: Glass effect
      appBar: AppBar(
        title: Text(widget.rifornimento == null ? l10n.addRefueling : l10n.editRefueling),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          color: AppColors.primaryBlue, // FIX: Colore a tema
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoadingData)
            IconButton(
              icon: const Icon(Icons.check, size: 28),
              color: AppColors.primaryBlue, // FIX: Colore a tema
              onPressed: _isSaving ? null : _saveRifornimento,
            )
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // FIX: Aggiunto lo sfondo in vetro
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(l10n.dateAndKm),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDatePicker(l10n),
                          const Divider(height: 1),
                          _buildModernTextField(_kmAttualiController, l10n.currentKm, Icons.speed, l10n, isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionLabel(l10n.fuelAndMix),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildModernTextField(_litriBenzinaController, l10n.gasLiters, Icons.local_gas_station, l10n, isNumber: true),
                          if (!_scooterHasMiscelatore) ...[
                            const Divider(height: 1),
                            _buildModernTextField(_percentualeOlioController, '${l10n.oilPercentage} (%)', Icons.percent, l10n, isNumber: true, isRequired: false),
                          ],
                          const Divider(height: 1),
                          _buildModernTextField(_litriOlioController, _scooterHasMiscelatore ? l10n.oilLiters : '${l10n.oilLiters} ${l10n.calculatedLabel}', Icons.oil_barrel, l10n, isNumber: true, isEnabled: _scooterHasMiscelatore, isRequired: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionLabel(l10n.costoLabel),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: _buildModernTextField(_costoController, l10n.costoLabel, Icons.payments_outlined, l10n, isNumber: true, isRequired: false),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionLabel(l10n.noteLabel),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildModernTextField(_noteController, l10n.placeholderNote, Icons.notes, l10n, isRequired: false, maxLines: 3),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionLabel(l10n.posizioneGPSLabel),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: _buildGPSInput(l10n),
                    ),
                    const SizedBox(height: 32),

                    _buildStatsSummary(l10n),
                    const SizedBox(height: 40),
                  ],
                ),
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

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildDatePicker(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primaryBlue.withOpacity(0.8), size: 22),
            const SizedBox(width: 16),
            Text(l10n.date, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Text(DateFormat.yMMMd(locale).format(_selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
      TextEditingController controller, String label, IconData icon, AppLocalizations l10n, {
        bool isNumber = false, bool isRequired = true, bool isEnabled = true, int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12.0 : 0),
            child: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.8), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: isEnabled,
              maxLines: maxLines,
              keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
              ),
              validator: (val) {
                if (isRequired && (val == null || val.trim().isEmpty)) return l10n.requiredField;
                if (val != null && val.isNotEmpty && isNumber && _parseToDouble(val) == null) return l10n.insertNumber;

                // Controllo speciale per i km
                if (controller == _kmAttualiController) {
                  final doubleVal = _parseToDouble(val ?? '');
                  if (doubleVal != null && _previousRifornimento != null && doubleVal <= _previousRifornimento!.kmAttuali) {
                    return l10n.mustBeGreaterThan(_previousRifornimento!.kmAttuali.toInt().toString());
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSInput(AppLocalizations l10n) {
    final bool hasLocation = _latitudine != null && _longitudine != null;
    return ListTile(
      leading: Icon(
        hasLocation ? Icons.map : Icons.map_outlined,
        color: hasLocation ? Colors.green : AppColors.primaryBlue,
      ),
      title: Text(hasLocation ? l10n.posizioneSalvata : l10n.aggiungiPosizione),
      trailing: hasLocation
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await context.pushNamed<LatLng>(
          'location-picker',
          extra: {'lat': _latitudine, 'lon': _longitudine},
        );
        if (result != null) {
          setState(() {
            _latitudine = result.latitude;
            _longitudine = result.longitude;
          });
        }
      },
    );
  }

  Widget _buildStatsSummary(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildStatRow(l10n.kmTraveled, "${_kmPercorsi.toStringAsFixed(1)} km"),
          const Divider(height: 24),
          _buildStatRow(l10n.averageConsumption, "${_mediaConsumo.toStringAsFixed(2)} km/L"),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 16)),
      ],
    );
  }

  @override
  void dispose() {
    _kmAttualiController.dispose();
    _litriBenzinaController.dispose();
    _litriOlioController.dispose();
    _percentualeOlioController.dispose();
    _costoController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}