import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/core/theme/theme_service.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/core/services/local_image_cache.dart';

// FIX: Aggiunti i widget del Design System
import 'package:myscooter/core/theme/app_colors.dart';

import '../../../core/widgets/glass_background.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/glass_card.dart';
import '../model/scooter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isNavigating = false;

  Future<bool?> _confirmDelete(BuildContext context, Scooter scooter) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteScooterTitle),
        content: Text(l10n.deleteScooterContent(scooter.modello)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(scooterListProvider.notifier).refreshScooters();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<UiMessage?>(messageProvider, (previous, next) {
      if (next != null) {
        final Color? bgColor = next.type == MessageType.error
            ? Colors.red.shade800
            : (next.type == MessageType.success ? Colors.green.shade800 : null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: bgColor, behavior: SnackBarBehavior.fixed),
        );
        ref.read(messageProvider.notifier).clear();
      }
    });

    final scooterState = ref.watch(scooterListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // FIX
      extendBodyBehindAppBar: true,        // FIX
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // FIX: AppBar invisibile
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: AppColors.primaryBlue),
          onPressed: (scooterState.isLoading || _isNavigating) ? null : () => context.push('/settings'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 28, color: AppColors.primaryBlue),
            onPressed: (scooterState.isLoading || _isNavigating) ? null : () async {
              setState(() => _isNavigating = true);
              try {
                final Scooter? resultScooter = await context.push<Scooter?>('/add-edit-scooter');
                if (resultScooter != null) {
                  await ref.read(scooterListProvider.notifier).addScooter(resultScooter);
                  if (mounted) ref.read(messageProvider.notifier).show(l10n.scooterAdded, type: MessageType.success);
                }
              } finally {
                if (mounted) setState(() => _isNavigating = false);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // FIX: Background globale
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopLogo(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.myScooters,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: scooterState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text(error.toString())),
                    data: (scooters) => RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: scooters.isEmpty
                          ? _buildEmptyState(context)
                          : _buildScooterList(context, scooters),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: Center(
        child: Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.secondaryCyan.withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/loghetto1_scritta128.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler, size: 50, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Icon(Icons.two_wheeler, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Center(child: Text(l10n.noScooterFound, style: const TextStyle(color: Colors.grey))),
        Center(child: Text(l10n.addScooterPrompt, style: const TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget _buildScooterList(BuildContext context, List<Scooter> scooters) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: scooters.length,
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16), // Padding globale
      itemBuilder: (context, index) {
        final scooter = scooters[index];
        bool hasImage = scooter.imgName != null && scooter.imgName!.isNotEmpty;

        return Dismissible(
          key: Key(scooter.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _confirmDelete(context, scooter),
          onDismissed: (direction) {
            ref.read(scooterListProvider.notifier).deleteScooter(scooter);
            ref.read(messageProvider.notifier).show(l10n.scooterDeleted);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            // FIX: Applicata la GlassCard!
            child: GlassCard(
              padding: EdgeInsets.zero, // Il ListTile gestisce il suo padding interno
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasImage ? AppColors.primaryBlue : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? CloudSyncImage(imagePath: scooter.imgName!, fit: BoxFit.cover, width: 60, height: 60)
                        : const Icon(Icons.moped, color: Colors.grey),
                  ),
                ),
                title: Text('${scooter.marca} ${scooter.modello}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('${l10n.licensePlateShort}: ${scooter.targa}'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  context.push('/scooter-detail', extra: scooter).then((_) {
                    ref.read(scooterListProvider.notifier).refreshScooters();
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}