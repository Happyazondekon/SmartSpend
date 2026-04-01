import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/auth/new_login_screen.dart';
import 'screens/auth/new_email_verification_screen.dart';
import 'screens/auth/pin_setup_screen.dart';
import 'screens/auth/pin_lock_screen.dart';
import 'new_main_screen.dart';
import 'budget_logic.dart';
import 'theme_provider.dart';
import 'firestore_service.dart';
import 'widgets/sync_status_widget.dart';
import 'new_design_system.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isUnlocked = false;
  bool _checkingPin = true;
  bool _hasPin = false;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Verrouiller l'app quand elle revient du background
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground && _hasPin) {
      setState(() {
        _isUnlocked = false;
        _wasInBackground = false;
      });
    }
  }

  Future<void> _checkPinStatus() async {
    final hasPin = await PinHelper.hasPin();
    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _checkingPin = false;
        // Si pas de PIN, on considère comme déverrouillé (pour afficher l'écran de config)
        _isUnlocked = !hasPin;
      });
    }
  }

  void _onPinSet() {
    setState(() {
      _hasPin = true;
      _isUnlocked = true;
    });
  }

  void _onUnlocked() {
    setState(() {
      _isUnlocked = true;
    });
  }

  void _onLogout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _isUnlocked = false;
      _hasPin = false;
      _checkingPin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context, colors, isDark, 'Chargement...');
        }

        final user = snapshot.data;

        if (user == null) {
          return const NewLoginScreen();
        }

        if (!user.emailVerified) {
          return const NewEmailVerificationScreen();
        }

        // Utilisateur connecté et vérifié - Initialiser les données Firestore
        return FutureBuilder(
          future: _initializeUserData(),
          builder: (context, initSnapshot) {
            if (initSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen(context, colors, isDark, 'Initialisation de vos données...');
            }

            if (initSnapshot.hasError) {
              return _buildErrorScreen(context, colors);
            }

            // Vérifier le statut du PIN
            if (_checkingPin) {
              _checkPinStatus();
              return _buildLoadingScreen(context, colors, isDark, 'Vérification de la sécurité...');
            }

            // Si pas de PIN configuré, afficher l'écran de configuration
            if (!_hasPin) {
              return PinSetupScreen(onPinSet: _onPinSet);
            }

            // Si PIN configuré mais pas déverrouillé, afficher l'écran de saisie
            if (!_isUnlocked) {
              return PinLockScreen(
                onUnlocked: _onUnlocked,
                onLogout: _onLogout,
              );
            }

            // Déverrouillé - Afficher l'app principale
            return ChangeNotifierProvider(
              create: (_) => BudgetLogic.withContext(context),
              child: const SyncStatusWidget(
                child: NewMainScreen(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, AppColorScheme colors, bool isDark, String message) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    const Color(0xFFF0F4FF),
                    const Color(0xFFE8EFFF),
                    const Color(0xFFD6E4FF),
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/smartlogo.webp',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SmartSpend',
                style: AppTextStyles.h1.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, AppColorScheme colors) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3.copyWith(
                color: colors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger vos données',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _checkingPin = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeUserData() async {
    try {
      final firestoreService = FirestoreService();
      await firestoreService.initializeUserData();
      await Future.delayed(const Duration(milliseconds: 500));
      print('Données utilisateur initialisées avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation des données utilisateur: $e');
      rethrow;
    }
  }
}