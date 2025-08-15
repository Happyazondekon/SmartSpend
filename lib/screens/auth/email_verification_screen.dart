import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import 'package:smartspend/budget_screen.dart';
import 'login_screen.dart';
import '../../theme_provider.dart'; // NOUVEAU: Importation du ThemeProvider

class EmailVerificationScreen extends StatefulWidget {
  // SUPPRIMÉ: final bool isDarkMode;
  // SUPPRIMÉ: final Function(bool) onToggleDarkMode;

  const EmailVerificationScreen({
    super.key,
    // SUPPRIMÉ: required this.isDarkMode,
    // SUPPRIMÉ: required this.onToggleDarkMode,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ThemeProvider _themeProvider = ThemeProvider(); // NOUVEAU: Instance unique
  late Timer _timer;
  bool _isLoading = false;
  bool _canResendEmail = true;
  int _resendCountdown = 0;
  String? _errorMessage;
  String? _successMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // NOUVEAU: Écouter les changements de thème
    _themeProvider.addListener(_onThemeChanged);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);

    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    // NOUVEAU: Arrêter d'écouter les changements
    _themeProvider.removeListener(_onThemeChanged);
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // NOUVEAU: Callback pour les changements de thème
  void _onThemeChanged() {
    setState(() {});
  }

  void _startEmailVerificationCheck() {
    // Vérifie l'état de vérification de l'email toutes les 3 secondes
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = _authService.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          timer.cancel();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                maintainState: true,
                builder: (context) => const BudgetScreen(),
              ),
            );
          }
        }
      }
    });
  }

  void _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _isLoading = true;
      _canResendEmail = false;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.sendEmailVerification();
      if (mounted) {
        setState(() {
          _successMessage = 'Un nouvel email de vérification a été envoyé !';
          _resendCountdown = 60; // 1 minute
          _startResendCountdown();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Impossible de renvoyer l'email. Veuillez réessayer plus tard.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startResendCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResendEmail = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
        }
      }
    });
  }

  void _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          maintainState: true,
          builder: (context) => const LoginScreen(), // MODIFIÉ: Suppression des paramètres
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
            // MODIFIÉ: widget.isDarkMode → _themeProvider.isDarkMode
            colors: _themeProvider.isDarkMode
                ? [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
              Theme.of(context).colorScheme.surface.withOpacity(0.85),
            ]
                : [
              Theme.of(context).colorScheme.primary.withOpacity(0.02),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.03),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Espace pour le haut de l'écran
                          const SizedBox(height: 24),

                          // En-tête avec SmartSpend et le bouton de thème
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Spacer pour centrer le titre
                              const Spacer(),
                              // Titre SmartSpend centré et en primary
                              Text(
                                "SmartSpend",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              // Spacer pour équilibrer
                              const Spacer(),
                              // Bouton pour le thème
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  // MODIFIÉ: Nouvelle logique de changement de thème
                                  onPressed: () => _themeProvider.toggleTheme(!_themeProvider.isDarkMode),
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      // MODIFIÉ: widget.isDarkMode → _themeProvider.isDarkMode
                                      _themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      key: ValueKey(_themeProvider.isDarkMode),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Section principale
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 48),
                            child: Column(
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      size: 72,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                Text(
                                  'Vérifiez votre e-mail !',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -1.0,
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nous avons envoyé un lien de vérification à votre adresse e-mail. Veuillez cliquer sur le lien pour continuer.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                // Message d'erreur élégant
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.error_outline_rounded,
                                            color: Theme.of(context).colorScheme.error,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Message de succès
                                if (_successMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.check_circle_outline_rounded,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _successMessage!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Bouton pour renvoyer l'email
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: FilledButton(
                                    onPressed: _canResendEmail ? _resendVerificationEmail : null,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                        : Text(
                                      _canResendEmail ? 'Renvoyer l\'email' : 'Renvoyer dans ($_resendCountdown s)',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Bouton pour se déconnecter
                                TextButton(
                                  onPressed: _signOut,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        color: Theme.of(context).colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Utiliser un autre compte',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}