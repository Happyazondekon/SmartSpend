import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Vérifier si l'utilisateur est connecté
  bool get isSignedIn => currentUser != null;

  // Inscription avec email et mot de passe
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Mettre à jour le profil avec le nom
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur d\'inscription: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de l\'inscription: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur de connexion: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de la connexion: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      // Obtenir les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer une nouvelle credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Une fois connecté, retourner le UserCredential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur de connexion Google: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de la connexion Google: $e');
      throw 'Erreur lors de la connexion avec Google';
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur de réinitialisation: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de la réinitialisation: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Envoyer l'email de vérification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur envoi email de vérification: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de l\'envoi de l\'email: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Recharger les informations utilisateur
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur mise à jour profil: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de la mise à jour: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Changer le mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user?.email != null) {
        // Ré-authentifier l'utilisateur
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Changer le mot de passe
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur changement mot de passe: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors du changement: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Supprimer le compte
  Future<void> deleteAccount({String? password}) async {
    try {
      final user = currentUser;
      if (user != null) {
        // Si c'est un compte email/password, ré-authentifier
        if (password != null && user.email != null) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        }

        // Supprimer le compte
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur suppression compte: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Erreur inattendue lors de la suppression: $e');
      throw 'Une erreur inattendue s\'est produite';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      // Déconnexion de Google si connecté via Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Déconnexion de Firebase
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw 'Erreur lors de la déconnexion';
    }
  }

  // Gestion des erreurs d'authentification
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'operation-not-allowed':
        return 'Cette méthode d\'authentification n\'est pas activée';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-credential':
        return 'Les informations d\'identification sont invalides';
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec un autre mode de connexion';
      case 'requires-recent-login':
        return 'Cette action nécessite une reconnexion récente';
      case 'provider-already-linked':
        return 'Ce compte est déjà lié à un autre fournisseur';
      case 'no-such-provider':
        return 'Aucun fournisseur trouvé pour ce compte';
      case 'invalid-verification-code':
        return 'Code de vérification invalide';
      case 'invalid-verification-id':
        return 'ID de vérification invalide';
      case 'network-request-failed':
        return 'Erreur de connexion réseau';
      default:
        return e.message ?? 'Une erreur d\'authentification s\'est produite';
    }
  }

  // Vérifier si l'email nécessite une vérification
  bool get emailVerified => currentUser?.emailVerified ?? false;

  // Obtenir le nom d'affichage
  String? get displayName => currentUser?.displayName;

  // Obtenir l'email
  String? get userEmail => currentUser?.email;

  // Obtenir l'URL de photo
  String? get photoURL => currentUser?.photoURL;

  // Obtenir l'UID
  String? get uid => currentUser?.uid;
}