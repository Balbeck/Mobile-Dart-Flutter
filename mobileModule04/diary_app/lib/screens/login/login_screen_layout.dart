import 'package:flutter/material.dart';

class LoginScreenLayout extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;

  const LoginScreenLayout({
    super.key,
    required this.isLoading,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/backgound_wallpapers/Pacific_Wallpaper_1.jpg',
            fit: BoxFit.cover,
          ),

          // Overlay sombre pour la lisibilité
          Container(color: Colors.black.withOpacity(0.45)),

          // Contenu centré
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre de l'app
                const Text(
                  'AiMe',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ton journal personnel',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 80),

                // Bouton Google Sign-In ou spinner
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _GoogleSignInButton(onPressed: onGoogleSignIn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        height: 24,
        width: 24,
      ),
      label: const Text(
        'Continuer avec Google',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    );
  }
}
