// lib/features/scooter/widgets/terms_and_conditions_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/message_provider.dart';
import '../../../../l10n/app_localizations.dart';

class TermsAndConditionsView extends ConsumerWidget {
  const TermsAndConditionsView({super.key});

  final String _urlSito = "https://rinino.github.io/myScooterSite/";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header stile iOS
          AppBar(
            title: Text(l10n.legale),
            centerTitle: true,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.fatto, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.document_scanner, size: 80, color: Colors.blue),
                  const SizedBox(height: 25),
                  Text(
                    l10n.maggiori_info,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    l10n.info_text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // Pulsante per il sito con gestione errori
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(_urlSito);
                        try {
                          // Se la configurazione nativa (AndroidManifest/Info.plist) è ok, apre il link
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            // Errore se il sistema rifiuta l'apertura
                            ref.read(messageProvider.notifier).show(
                                "Impossibile aprire il browser",
                                type: MessageType.error
                            );
                          }
                        } catch (e) {
                          ref.read(messageProvider.notifier).show(
                              "Errore: $e",
                              type: MessageType.error
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: Text(l10n.leggi_sito, style: const TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                  Text(
                    l10n.info_dati,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}