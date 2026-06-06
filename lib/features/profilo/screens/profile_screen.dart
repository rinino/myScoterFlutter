import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:myscooter/core/auth/auth_manager.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/core/services/local_image_cache.dart';
import '../../scooter/widgets/image_viewer_page.dart';
import '../../../l10n/app_localizations.dart';

// FIX: Importiamo i componenti del Design System
import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_background.dart';
import 'package:myscooter/core/widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    await ref.read(scooterListProvider.notifier).refreshScooters();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _handleLogin(BuildContext context, WidgetRef ref, Future<bool> Function() loginMethod) async {
    final l10n = AppLocalizations.of(context)!;

    final bool? wantsToProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.attenzioneSovrascritturaTitolo)),
            ],
          ),
          content: Text(l10n.attenzioneSovrascritturaMessaggio),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.annulla, style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.procedi),
            ),
          ],
        );
      },
    );

    if (wantsToProceed != true) return;

    final success = await loginMethod();

    if (success) {
      await ref.read(scooterListProvider.notifier).refreshScooters();
      if (context.mounted) {
        ref.read(messageProvider.notifier).show(l10n.loginSuccess, type: MessageType.success);
      }
    } else {
      if (context.mounted) {
        ref.read(messageProvider.notifier).show(l10n.loginError, type: MessageType.error);
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref, AppLocalizations l10n, User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [const Icon(Icons.warning_amber_rounded, color: Colors.red), const SizedBox(width: 8), Text(l10n.eliminaAccount)]),
        content: Text(l10n.eliminaAccountConferma),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.annulla, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.eliminaDefinitivamente)),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userId = user.uid;
      final db = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;

      // 1. ELIMINAZIONE FOTO DA CLOUD STORAGE
      try {
        final storageRef = storage.ref().child("images/$userId");
        final listResult = await storageRef.listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch(e) {
        debugPrint("ADR: Nessuna foto da eliminare o errore Storage: $e");
      }

      // 2. ELIMINAZIONE DATI NUCLEARE A CHUNK (Sicurezza contro il limite dei 500 doc)
      WriteBatch batch = db.batch();
      int count = 0;

      Future<void> commitIfNeed() async {
        count++;
        if (count >= 490) {
          await batch.commit();
          batch = db.batch();
          count = 0;
        }
      }

      final collections = ['scooters', 'rifornimenti', 'manutenzioni', 'documenti'];
      for (var coll in collections) {
        final snap = await db.collection(coll).where('userId', isEqualTo: userId).get();
        for (var doc in snap.docs) {
          batch.delete(doc.reference);
          await commitIfNeed();
        }
      }

      // Elimina il profilo utente
      batch.delete(db.collection('utenti').doc(userId));
      await commitIfNeed();

      // Invia gli ultimi residui
      if (count > 0) {
        await batch.commit();
      }

      // 3. ELIMINAZIONE AUTENTICAZIONE
      await user.delete();
      await AuthManager.shared.signOut();
      await ref.read(scooterListProvider.notifier).refreshScooters();

      if (context.mounted) {
        ref.read(messageProvider.notifier).show(l10n.accountEliminato, type: MessageType.success);
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) ref.read(messageProvider.notifier).show(l10n.erroreRiautenticazione, type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent, // FIX: Scaffold trasparente
      extendBodyBehindAppBar: true,        // FIX: Glass effect
      appBar: AppBar(
        title: Text(l10n.profiloTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Stack(
        children: [
          // FIX: Sfondo in vetro
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _onRefresh(ref),
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;

                  if (user == null || user.isAnonymous) {
                    return _buildGuestView(context, ref, l10n);
                  } else {
                    return _buildUserView(context, ref, l10n, user);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.utenteOspite, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(l10n.datiLocali, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton.icon(
          onPressed: () => _handleLogin(context, ref, AuthManager.shared.signInWithGoogle),
          icon: const Icon(Icons.account_circle),
          label: Text(l10n.accediGoogle, style: const TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
        ),
        const SizedBox(height: 16),
        if (Platform.isIOS) ...[
          ElevatedButton.icon(
            onPressed: () => _handleLogin(context, ref, AuthManager.shared.signInWithApple),
            icon: const Icon(Icons.apple),
            label: Text(l10n.accediApple, style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: () => context.push('/email-auth'),
          icon: const Icon(Icons.email_outlined),
          label: Text(l10n.accediEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.primaryBlue, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildUserView(BuildContext context, WidgetRef ref, AppLocalizations l10n, User user) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('utenti').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          String displayName = user.displayName ?? (user.email ?? l10n.cloudUser);
          String? photoUrl = user.photoURL;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final nome = data['nome'] as String? ?? '';
            final cognome = data['cognome'] as String? ?? '';
            if (nome.isNotEmpty || cognome.isNotEmpty) {
              displayName = "$nome $cognome".trim();
            }
            final dbPhoto = data['nomeFotoProfilo'] as String?;
            if (dbPhoto != null && dbPhoto.isNotEmpty) {
              photoUrl = dbPhoto;
            }
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: [
              GlassCard(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (photoUrl != null && photoUrl.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => ImageViewerPage(
                                  imagePath: photoUrl!,
                                  title: displayName,
                                  heroTag: 'profile_image_${user.uid}',
                                ),
                              ),
                            );
                          }
                        },
                        child: Hero(
                          tag: 'profile_image_${user.uid}',
                          child: ClipOval(
                            child: Container(
                              width: 120,
                              height: 120,
                              color: AppColors.primaryBlue,
                              child: (photoUrl != null && photoUrl.isNotEmpty)
                                  ? CloudSyncImage(imagePath: photoUrl, width: 120, height: 120, fit: BoxFit.cover)
                                  : Center(child: Text(user.email?[0].toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    if (user.email != null) ...[
                      const SizedBox(height: 8),
                      Text(user.email!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () => context.push('/edit-profile'),
                icon: const Icon(Icons.edit),
                label: Text(l10n.modificaProfilo, style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthManager.shared.signOut();
                  await ref.read(scooterListProvider.notifier).refreshScooters();
                  if (context.mounted) {
                    ref.read(messageProvider.notifier).show(l10n.logoutSuccess);
                    context.pop();
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.esci, style: const TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 64),
              Center(
                child: TextButton.icon(
                  onPressed: () => _deleteAccount(context, ref, l10n, user),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(l10n.eliminaAccount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }
    );
  }
}