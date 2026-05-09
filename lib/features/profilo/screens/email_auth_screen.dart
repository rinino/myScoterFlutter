import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:myscooter/core/auth/auth_manager.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;

    String? error;
    if (_isLogin) {
      error = await AuthManager.shared.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim()
      );
    } else {
      error = await AuthManager.shared.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim()
      );
    }

    if (!context.mounted) return; // FIX: Controllo mount prima della gestione UI
    setState(() => _isLoading = false);

    if (error != null) {
      ref.read(messageProvider.notifier).show(error, type: MessageType.error);
    } else {
      await ref.read(scooterListProvider.notifier).refreshScooters();

      if (!context.mounted) return; // FIX: Controllo mount post-await

      if (!_isLogin) {
        ref.read(messageProvider.notifier).show(l10n.mailVerificaInviata, type: MessageType.success);
      } else {
        ref.read(messageProvider.notifier).show(l10n.loginSuccess, type: MessageType.success);
      }

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/settings');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? l10n.accediEmail : l10n.registrati),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Icon(Icons.email, size: 80, color: Colors.blue),
              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    border: const OutlineInputBorder()
                ),
                validator: (val) => val == null || !val.contains('@') ? l10n.emailValida : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    border: const OutlineInputBorder()
                ),
                validator: (val) => val == null || val.length < 6 ? l10n.passwordCorta : null,
              ),
              const SizedBox(height: 16),

              if (!_isLogin)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: l10n.confermaPassword,
                      border: const OutlineInputBorder()
                  ),
                  validator: (val) => val != _passwordController.text ? l10n.passwordNonCoincidono : null,
                ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white
                ),
                child: _isLoading
                    ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : Text(
                    _isLogin ? l10n.accediEmail : l10n.registrati,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? l10n.nonHaiAccount : l10n.haiGiaAccount),
              )
            ],
          ),
        ),
      ),
    );
  }
}