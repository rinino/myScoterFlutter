// lib/features/scooter/screens/scooter_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/core/providers/core_providers.dart';

// IMPORT WIDGETS
import '../widgets/scooter_header_image.dart';
import '../widgets/scooter_info_card.dart';
import '../widgets/refuelings_list_section.dart';
import '../widgets/image_viewer_page.dart'; // Assicurati che esista questo file

import '../../../l10n/app_localizations.dart';
import '../model/scooter.dart';

class ScooterDetailScreen extends ConsumerStatefulWidget {
  final Scooter scooter;

  const ScooterDetailScreen({super.key, required this.scooter});

  @override
  ConsumerState<ScooterDetailScreen> createState() => _ScooterDetailScreenState();
}

class _ScooterDetailScreenState extends ConsumerState<ScooterDetailScreen> {
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

  // --- LOGICA DATI ---

  Future<void> _loadRifornimenti() async {
    if (_currentScooter.id == null) {
      if (mounted) setState(() => _isLoadingRifornimenti = false);
      return;
    }
    setState(() => _isLoadingRifornimenti = true);
    try {
      final repo = ref.read(rifornimentoRepoProvider);
      final rifornimenti = await repo.getRifornimentiForScooter(_currentScooter.id!);
      if (mounted) setState(() => _rifornimenti = rifornimenti);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ref.read(messageProvider.notifier).show(l10n.errorLoadingRefuelings, type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoadingRifornimenti = false);
    }
  }

  // --- NAVIGAZIONE E AZIONI ---

  void _openImageViewer() {
    if (_currentScooter.imgPath == null || !File(_currentScooter.imgPath!).existsSync()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ImageViewerPage(
          imageFile: File(_currentScooter.imgPath!),
          title: "${_currentScooter.marca} ${_currentScooter.modello}",
          heroTag: 'scooter_image_${_currentScooter.id}',
        ),
      ),
    );
  }

  Future<void> _navigateToEditScooter() async {
    final l10n = AppLocalizations.of(context)!;
    final Scooter? updatedScooter = await context.push<Scooter?>('/add-edit-scooter', extra: _currentScooter);

    if (updatedScooter != null) {
      setState(() => _isProcessingAction = true);
      try {
        await ref.read(scooterRepoProvider).updateScooter(updatedScooter);
        if (mounted) setState(() => _currentScooter = updatedScooter);
        await _loadRifornimenti();
        ref.read(messageProvider.notifier).show(l10n.scooterUpdated, type: MessageType.success);
      } catch (e) {
        ref.read(messageProvider.notifier).show(l10n.errorUpdating, type: MessageType.error);
      } finally {
        if (mounted) setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _confirmAndDeleteRifornimento(Rifornimento rif) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(l10n.deleteRecordContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessingAction = true);
      try {
        await ref.read(rifornimentoRepoProvider).deleteRifornimento(rif.id!);
        if (mounted) setState(() => _rifornimenti.removeWhere((r) => r.id == rif.id));
        ref.read(messageProvider.notifier).show(l10n.recordDeleted, type: MessageType.success);
      } catch (e) {
        ref.read(messageProvider.notifier).show(l10n.errorDeleting, type: MessageType.error);
      } finally {
        if (mounted) setState(() => _isProcessingAction = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final bool isUIBlocked = _isProcessingAction || _isLoadingRifornimenti;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentScooter.marca} ${_currentScooter.modello}'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: isUIBlocked ? null : _navigateToEditScooter),
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
                  ScooterHeaderImage(
                    imgPath: _currentScooter.imgPath,
                    scooterId: _currentScooter.id!,
                    onTap: _openImageViewer,
                  ),
                  const SizedBox(height: 24),
                  ScooterInfoCard(scooter: _currentScooter),
                  const SizedBox(height: 24),
                  RefuelingsListSection(
                    rifornimenti: _rifornimenti,
                    isLoading: _isLoadingRifornimenti,
                    locale: locale,
                    onAddTap: () async {
                      final result = await context.push('/add-edit-rifornimento/${_currentScooter.id!}');
                      if (result != null) await _loadRifornimenti();
                    },
                    onRifornimentoTap: (rif) async {
                      final result = await context.push('/rifornimento-detail/${_currentScooter.id!}', extra: rif);
                      if (result != null) await _loadRifornimenti();
                    },
                    onDeleteConfirm: _confirmAndDeleteRifornimento,
                  ),
                ],
              ),
            ),
          ),
          if (isUIBlocked) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}