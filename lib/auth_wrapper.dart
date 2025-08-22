import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'budget_screen.dart';
import 'theme_provider.dart';
import 'firestore_service.dart';  // Nouveau import
import 'widgets/sync_status_widget.dart';  // Nouveau import

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: themeProvider.isDarkMode
                      ? [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  ]
                      : [
                    Theme.of(context).colorScheme.primary.withOpacity(0.02),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SmartSpend',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return LoginScreen();
        }

        if (!user.emailVerified) {
          return EmailVerificationScreen();
        }

        // Utilisateur connecté et vérifié - Initialiser les données Firestore
        return FutureBuilder(
          future: _initializeUserData(),
          builder: (context, initSnapshot) {
            if (initSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: themeProvider.isDarkMode
                          ? [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withOpacity(0.85),
                      ]
                          : [
                        Theme.of(context).colorScheme.primary.withOpacity(0.02),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SmartSpend',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Initialisation de vos données...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (initSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Impossible de charger vos données',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Relancer l'initialisation
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => AuthWrapper()),
                          );
                        },
                        child: Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Envelopper BudgetScreen avec SyncStatusWidget
            return SyncStatusWidget(
              child: BudgetScreen(),
            );
          },
        );
      },
    );
  }

  // Fonction pour initialiser les données utilisateur dans Firestore
  Future<void> _initializeUserData() async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.initializeUserData();

      // Petite pause pour s'assurer que tout est bien initialisé
      await Future.delayed(Duration(milliseconds: 500));

      print('Données utilisateur initialisées avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation des données utilisateur: $e');
      throw e;
    }
  }
}