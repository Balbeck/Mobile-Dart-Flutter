import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final result = await _authService.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion annulée ou échouée.')),
        );
      }
      // Si result != null, le StreamBuilder dans app.dart
      // détecte automatiquement le changement et navigue vers ProfileScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreenLayout(
      isLoading: _isLoading,
      onGoogleSignIn: _handleGoogleSignIn,
    );
  }
}
