import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'services/remote_config_service.dart';

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
  bool _updateRequired = false;
  bool _checkingUpdate = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final remoteConfig = RemoteConfigService();
      await remoteConfig.initialize();
      final updateRequired = await remoteConfig.isUpdateRequired();
      if (mounted) {
        setState(() {
          _updateRequired = updateRequired;
          _checkingUpdate = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur vérification mise à jour: $e');
      if (mounted) {
        setState(() => _checkingUpdate = false);
      }
    }
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

    // Vérification de la mise à jour en cours
    if (_checkingUpdate) {
      return _buildLoadingScreen(context, colors, isDark, 'Vérification...');
    }

    // Mise à jour requise - bloquer l'accès
    if (_updateRequired) {
      return _buildUpdateRequiredScreen(context, colors, isDark);
    }

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

  Widget _buildUpdateRequiredScreen(BuildContext context, AppColorScheme colors, bool isDark) {
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 64,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Titre
                Text(
                  'Mise à jour requise',
                  style: AppTextStyles.h2.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Une nouvelle version de SmartSpend est disponible avec des améliorations importantes et des corrections de bugs.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Veuillez mettre à jour l\'application pour continuer à l\'utiliser.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Bouton de mise à jour
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(RemoteConfigService().storeUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Mettre à jour maintenant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Note
                Text(
                  '💡 Vos données sont sauvegardées et seront restaurées après la mise à jour.',
                  style: AppTextStyles.bodySmallThemed(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}