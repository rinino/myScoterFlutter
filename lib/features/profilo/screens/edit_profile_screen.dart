import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import '../models/utente_profilo.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  File? _newProfileImage;
  UtenteProfilo? _utenteProfilo;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(_currentUser.uid).get();
      if (doc.exists) {
        _utenteProfilo = UtenteProfilo.fromMap(doc.data()!, doc.id);
        _nomeController.text = _utenteProfilo!.nome;
        _cognomeController.text = _utenteProfilo!.cognome;
      }
    } catch (e) {
      debugPrint("Errore caricamento profilo: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Compressione foto come da Swift (800x800 e qualità ridotta per risparmiare banda/spazio)
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 70
    );

    if (pickedFile != null) {
      setState(() => _newProfileImage = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      String? photoUrl = _utenteProfilo?.nomeFotoProfilo ?? _currentUser.photoURL;

      // 1. Upload Immagine su Firebase Storage se è stata cambiata
      if (_newProfileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child("images/${_currentUser.uid}/profile.jpg");
        await storageRef.putFile(_newProfileImage!);
        photoUrl = await storageRef.getDownloadURL();
        await _currentUser.updatePhotoURL(photoUrl);
      }

      // 2. Aggiorna il Display Name su Auth (per comodità)
      final fullName = "${_nomeController.text.trim()} ${_cognomeController.text.trim()}".trim();
      if (fullName.isNotEmpty) {
        await _currentUser.updateDisplayName(fullName);
      }

      // 3. Salva su Firestore nel documento utente
      final newProfile = UtenteProfilo(
        id: _currentUser.uid,
        email: _currentUser.email ?? "no-email",
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        nomeFotoProfilo: photoUrl,
      );

      await FirebaseFirestore.instance.collection('utenti').doc(_currentUser.uid).set(newProfile.toMap());

      if (mounted) {
        ref.read(messageProvider.notifier).show(l10n.profiloAggiornato, type: MessageType.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ref.read(messageProvider.notifier).show(l10n.erroreSalvataggio, type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modificaProfilo),
        actions: [
          if (!_isLoading)
            IconButton(
                icon: const Icon(Icons.check, color: Colors.blue),
                onPressed: _isSaving ? null : _saveProfile
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // FOTO PROFILO
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _newProfileImage != null
                        ? FileImage(_newProfileImage!) as ImageProvider
                        : (_utenteProfilo?.nomeFotoProfilo != null || _currentUser?.photoURL != null)
                        ? NetworkImage(_utenteProfilo?.nomeFotoProfilo ?? _currentUser!.photoURL!)
                        : null,
                    child: (_newProfileImage == null && _utenteProfilo?.nomeFotoProfilo == null && _currentUser?.photoURL == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // CAMPI TESTO
          TextFormField(
            initialValue: _currentUser?.email ?? "N/A",
            enabled: false, // La mail non è modificabile
            decoration: InputDecoration(
                labelText: l10n.emailLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock)
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(
                labelText: l10n.nomeLabel,
                border: const OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _cognomeController,
            decoration: InputDecoration(
                labelText: l10n.cognomeLabel,
                border: const OutlineInputBorder()
            ),
          ),

          if (_isSaving)
            const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator())
            ),
        ],
      ),
    );
  }
}