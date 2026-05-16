import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FIX: Necessario per pulizia e creazione profilo
import 'package:firebase_storage/firebase_storage.dart'; // FIX: Necessario per pulizia storage
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;

import '../database/migration_manager.dart';
import '../services/local_image_cache.dart';

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
      User? finalUser;

      if (currentUser != null && currentUser.isAnonymous) {
        try {
          final credential = EmailAuthProvider.credential(email: email, password: password);
          final result = await currentUser.linkWithCredential(credential);
          finalUser = result.user;
          await finalUser?.sendEmailVerification();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            return "Email già in uso. Vai su 'Accedi' per fare il login.";
          }
          return e.message;
        }
      } else {
        final creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        finalUser = creds.user;
        await finalUser?.sendEmailVerification();
      }

      // FIX: Crea il documento del profilo utente per coerenza con iOS
      if (finalUser != null) {
        await _creaOAggiornaProfiloUtente(finalUser, 'email');
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
      await LocalImageCache.shared.clearCache();

      // FIX: Rileviamo l'UID dell'Ospite prima di fare il login
      final oldAnonymousUid = FirebaseAuth.instance.currentUser?.isAnonymous == true
          ? FirebaseAuth.instance.currentUser?.uid
          : null;

      final creds = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // FIX: Se l'utente era un ospite e ha fatto login su un account esistente, distruggiamo i dati fantasma
      if (oldAnonymousUid != null && oldAnonymousUid != creds.user?.uid) {
        await _deleteGhostData(oldAnonymousUid);
      }

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
      User? finalUser;

      if (currentUser != null && currentUser.isAnonymous) {
        final oldAnonymousUid = currentUser.uid;
        try {
          final res = await currentUser.linkWithCredential(credential);
          finalUser = res.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            await LocalImageCache.shared.clearCache();
            final res = await FirebaseAuth.instance.signInWithCredential(credential);
            finalUser = res.user;
            // FIX: Distruzione dati fantasma
            await _deleteGhostData(oldAnonymousUid);
          } else {
            rethrow;
          }
        }
      } else {
        await LocalImageCache.shared.clearCache();
        final res = await FirebaseAuth.instance.signInWithCredential(credential);
        finalUser = res.user;
      }

      if (finalUser != null) {
        await _creaOAggiornaProfiloUtente(finalUser, 'google');
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
      User? finalUser;

      if (currentUser != null && currentUser.isAnonymous) {
        final oldAnonymousUid = currentUser.uid;
        try {
          final res = await currentUser.linkWithCredential(oauthCredential);
          finalUser = res.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            await LocalImageCache.shared.clearCache();
            final res = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
            finalUser = res.user;
            // FIX: Distruzione dati fantasma
            await _deleteGhostData(oldAnonymousUid);
          } else {
            rethrow;
          }
        }
      } else {
        await LocalImageCache.shared.clearCache();
        final res = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        finalUser = res.user;
      }

      if (finalUser != null) {
        await _creaOAggiornaProfiloUtente(finalUser, 'apple');
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
      await LocalImageCache.shared.clearCache();

      notifyListeners();
      await signInAnonymously();
    } catch (e) {
      debugPrint("ADR: Errore SignOut - $e");
    } finally {
      setSyncing(false);
    }
  }

  // --- METODI PRIVATI DI SUPPORTO (PULIZIA E COERENZA DB) ---

  Future<void> _deleteGhostData(String uid) async {
    try {
      final db = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      final collections = ['scooters', 'rifornimenti', 'manutenzioni', 'documenti', 'utenti'];

      WriteBatch batch = db.batch();

      for (String collection in collections) {
        final snap = await db.collection(collection).where('userId', isEqualTo: uid).get();
        for (var doc in snap.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();

      // Elimina Immagini Orfane su Storage
      try {
        final listResult = await storage.ref("images/$uid").listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch (_) {}

    } catch (e) {
      debugPrint("ADR: Errore eliminazione dati fantasma: $e");
    }
  }

  Future<void> _creaOAggiornaProfiloUtente(User user, String provider) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('utenti').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Genera nome e cognome dal displayName (se disponibili)
        String nome = '';
        String cognome = '';
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          final parti = user.displayName!.split(' ');
          nome = parti.first;
          if (parti.length > 1) {
            cognome = parti.sublist(1).join(' ');
          }
        }

        await docRef.set({
          'email': user.email ?? '',
          'nome': nome,
          'cognome': cognome,
          'nomeFotoProfilo': user.photoURL,
          'provider': provider,
          'dataRegistrazione': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("ADR: Errore creazione profilo base: $e");
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