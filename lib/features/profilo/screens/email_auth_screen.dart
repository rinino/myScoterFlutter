import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FIX PRO: Haptic Feedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myscooter/core/auth/auth_manager.dart';
import 'package:myscooter/core/providers/message_provider.dart';
import 'package:myscooter/features/scooter/providers/scooter_provider.dart';
import 'package:myscooter/l10n/app_localizations.dart';

import 'package:myscooter/core/theme/app_colors.dart';
import 'package:myscooter/core/widgets/glass_background.dart';
import 'package:myscooter/core/widgets/custom_glass_card.dart'; // FIX PRO

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
    HapticFeedback.mediumImpact(); // FIX PRO
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

    if (!context.mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ref.read(messageProvider.notifier).show(error, type: MessageType.error);
    } else {
      await ref.read(scooterListProvider.notifier).refreshScooters();
      if (!context.mounted) return;

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_isLogin ? l10n.accediEmail : l10n.registrati),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const GlassBackground(
            primaryColor: AppColors.primaryBlue,
            secondaryColor: AppColors.secondaryCyan,
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const Icon(Icons.email, size: 80, color: AppColors.primaryBlue),
                  const SizedBox(height: 32),

                  CustomGlassCard(
                    borderColors: [
                      Colors.blue.withOpacity(0.4),
                      Colors.cyan.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildModernTextField(
                              _emailController,
                              l10n.emailLabel,
                              Icons.alternate_email,
                              TextInputType.emailAddress,
                              false,
                                  (val) => val == null || !val.contains('@') ? l10n.emailValida : null
                          ),
                          const Divider(height: 1),
                          _buildModernTextField(
                              _passwordController,
                              l10n.passwordLabel,
                              Icons.lock_outline,
                              TextInputType.text,
                              true,
                                  (val) => val == null || val.length < 6 ? l10n.passwordCorta : null
                          ),
                          if (!_isLogin) ...[
                            const Divider(height: 1),
                            _buildModernTextField(
                                _confirmPasswordController,
                                l10n.confermaPassword,
                                Icons.lock_reset,
                                TextInputType.text,
                                true,
                                    (val) => val != _passwordController.text ? l10n.passwordNonCoincidono : null
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4
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
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isLogin = !_isLogin);
                    },
                    child: Text(_isLogin ? l10n.nonHaiAccount : l10n.haiGiaAccount, style: const TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
      TextEditingController controller, String label, IconData icon, TextInputType type, bool obscure, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue.withOpacity(0.8), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: type,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}