// lib/features/scooter/widgets/image_viewer_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

import '../../../../core/providers/message_provider.dart';
import '../../../../l10n/app_localizations.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  final File imageFile;
  final String title;
  final String heroTag;

  const ImageViewerPage({
    super.key,
    required this.imageFile,
    required this.title,
    required this.heroTag,
  });

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  bool _isSaving = false;

  // Questa funzione apre la Share Sheet di sistema (include WhatsApp, Telegram, Mail, ecc.)
  Future<void> _shareImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final xFile = XFile(widget.imageFile.path);

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: l10n.shareText(widget.title),
          subject: l10n.shareSubject,
        ),
      );
    } catch (e) {
      ref.read(messageProvider.notifier).show(l10n.errorSharing, type: MessageType.error);
    }
  }

  Future<void> _saveToGallery() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);

    try {
      await Gal.putImage(widget.imageFile.path);
      ref.read(messageProvider.notifier).show(l10n.imageSaved, type: MessageType.success);
    } catch (e) {
      ref.read(messageProvider.notifier).show(l10n.errorSaving, type: MessageType.error);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          // Tasto Condividi (WhatsApp & Co.)
          IconButton(
            icon: const Icon(Icons.share, color: Colors.cyanAccent),
            onPressed: _shareImage,
          ),
          // Tasto Salva in Galleria
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_alt, color: Colors.cyanAccent),
            onPressed: _isSaving ? null : _saveToGallery,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: widget.heroTag,
            child: Image.file(widget.imageFile),
          ),
        ),
      ),
    );
  }
}