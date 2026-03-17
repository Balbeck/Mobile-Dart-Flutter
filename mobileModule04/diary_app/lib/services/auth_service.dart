import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  // Stream qui émet le User courant à chaque changement d'état
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Retourne le user actuellement connecté (null si pas connecté)
  User? get currentUser => _auth.currentUser;

  // Initialise GoogleSignIn (obligatoire en v7)
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  // Connexion avec Google (API v7.x)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
      if (googleUser == null) return null; // L'user a annulé

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Erreur Google Sign-In : $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }
}
