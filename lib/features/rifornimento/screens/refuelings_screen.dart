// lib/features/rifornimento/screens/refuelings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/message_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../scooter/model/scooter.dart';
import '../models/rifornimento.dart';
import '../../scooter/widgets/refuelings_list_section.dart';

class RefuelingsScreen extends ConsumerStatefulWidget {
  final Scooter scooter;

  const RefuelingsScreen({super.key, required this.scooter});

  @override
  ConsumerState<RefuelingsScreen> createState() => _RefuelingsScreenState();
}

class _RefuelingsScreenState extends ConsumerState<RefuelingsScreen> {
  List<Rifornimento> _rifornimenti = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRifornimenti();
  }

  Future<void> _loadRifornimenti() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(rifornimentoRepoProvider);
      final rifornimenti = await repo.getRifornimentiForScooter(widget.scooter.id!);
      if (mounted) setState(() => _rifornimenti = rifornimenti);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ref.read(messageProvider.notifier).show(l10n.errorLoadingRefuelings, type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndDelete(Rifornimento rif) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(l10n.deleteRecordContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(rifornimentoRepoProvider).deleteRifornimento(rif.id!);
        if (mounted) {
          setState(() => _rifornimenti.removeWhere((r) => r.id == rif.id));
        }
        ref.read(messageProvider.notifier).show(l10n.recordDeleted, type: MessageType.success);
      } catch (e) {
        ref.read(messageProvider.notifier).show(l10n.errorDeleting, type: MessageType.error);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.refuelingData),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: RefuelingsListSection(
          rifornimenti: _rifornimenti,
          isLoading: _isLoading,
          locale: locale,
          onAddTap: () async {
            final result = await context.push('/add-edit-rifornimento/${widget.scooter.id!}');
            if (result != null) await _loadRifornimenti();
          },
          onRifornimentoTap: (rif) async {
            final result = await context.push('/rifornimento-detail/${widget.scooter.id!}', extra: rif);
            if (result != null) await _loadRifornimenti();
          },
          onDeleteConfirm: _confirmAndDelete,
        ),
      ),
    );
  }
}