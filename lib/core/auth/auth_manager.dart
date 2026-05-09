import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;

import '../database/migration_manager.dart';
import '../services/local_image_cache.dart'; // Import per la gestione della cache immagini

class AuthManager extends ChangeNotifier {
  static final AuthManager shared = AuthManager._internal();
  AuthManager._internal();

  String? currentUserId;
  bool isSyncing = false;
  String currentNonce = "";

  void setSyncing(bool value) {
    isSyncing = value;
    notifyListeners();
  }

  // --- OSPITE ---
  Future<void> signInAnonymously() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      currentUserId = currentUser.uid;
      notifyListeners();
      MigrationManager.shared.eseguiMigrazioneSeNecessario(userId: currentUser.uid);
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      if (userCredential.user != null) {
        currentUserId = userCredential.user!.uid;
        notifyListeners();
        MigrationManager.shared.eseguiMigrazioneSeNecessario(userId: userCredential.user!.uid);
      }
    } catch (e) {
      debugPrint("ADR: Errore signInAnonymously - $e");
    }
  }

  // --- EMAIL E PASSWORD ---
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      setSyncing(true);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        try {
          final credential = EmailAuthProvider.credential(email: email, password: password);
          await currentUser.linkWithCredential(credential);
          await currentUser.sendEmailVerification();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            return "Email già in uso. Vai su 'Accedi' per fare il login.";
          }
          return e.message;
        }
      } else {
        final creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await creds.user?.sendEmailVerification();
      }
      currentUserId = FirebaseAuth.instance.currentUser?.uid;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      setSyncing(false);
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      setSyncing(true);
      // Puliamo la cache locale prima di accedere per forzare il caricamento dei dati corretti dal cloud
      await LocalImageCache.shared.clearCache();

      final creds = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      currentUserId = creds.user?.uid;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      setSyncing(false);
    }
  }

  Future<void> sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  bool isEmailVerified() {
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  // --- GOOGLE ---
  Future<bool> signInWithGoogle() async {
    try {
      setSyncing(true);
      final g_sign_in.GoogleSignIn googleSignIn = g_sign_in.GoogleSignIn(scopes: ['email', 'profile']);

      final g_sign_in.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false;

      final g_sign_in.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        try {
          // Tenta di unire i dati locali all'account Google
          await currentUser.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Se l'account Google esiste già, effettua il login diretto svuotando la cache
          if (e.code == 'credential-already-in-use') {
            debugPrint("ADR: Credenziale Google già esistente. Eseguo il Login diretto.");
            await LocalImageCache.shared.clearCache();
            await FirebaseAuth.instance.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        await LocalImageCache.shared.clearCache();
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      currentUserId = FirebaseAuth.instance.currentUser?.uid;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("ADR: Errore Google SignIn - $e");
      return false;
    } finally {
      setSyncing(false);
    }
  }

  // --- APPLE ---
  Future<bool> signInWithApple() async {
    try {
      setSyncing(true);
      final nonce = generateRandomNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: sha256ofString(nonce),
      );

      final oauthCredential = OAuthProvider('apple.com').credential(idToken: appleCredential.identityToken, rawNonce: nonce);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        try {
          await currentUser.linkWithCredential(oauthCredential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            debugPrint("ADR: Credenziale Apple già esistente. Eseguo il Login diretto.");
            await LocalImageCache.shared.clearCache();
            await FirebaseAuth.instance.signInWithCredential(oauthCredential);
          } else {
            rethrow;
          }
        }
      } else {
        await LocalImageCache.shared.clearCache();
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      }

      currentUserId = FirebaseAuth.instance.currentUser?.uid;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("ADR: Errore Apple SignIn - $e");
      return false;
    } finally {
      setSyncing(false);
    }
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    setSyncing(true);
    try {
      await FirebaseAuth.instance.signOut();

      final g_sign_in.GoogleSignIn googleSignIn = g_sign_in.GoogleSignIn();
      await googleSignIn.signOut();

      currentUserId = null;

      // Svuota la cache locale al logout per garantire che un nuovo login parta da dati puliti
      await LocalImageCache.shared.clearCache();

      notifyListeners();
      await signInAnonymously();
    } catch (e) {
      debugPrint("ADR: Errore SignOut - $e");
    } finally {
      setSyncing(false);
    }
  }

  String generateRandomNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}