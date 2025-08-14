import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import 'package:smartspend/budget_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleDarkMode;

  const EmailVerificationScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
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
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _animationController.repeat(reverse: true);

    // Vérifier périodiquement si l'email a été vérifié
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    await _authService.reloadUser();

    if (_authService.emailVerified && mounted) {
      _timer.cancel();

      // Afficher un message de succès
      if (mounted) {
        setState(() {
          _successMessage = 'Email vérifié avec succès !';
        });
      }

      // Attendre un peu avant de rediriger
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BudgetScreen(
              isDarkMode: widget.isDarkMode,
              onToggleDarkMode: widget.onToggleDarkMode,
            ),
          ),
              (route) => false,
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.sendEmailVerification();

      if (mounted) {
        setState(() {
          _successMessage = 'Email de vérification renvoyé !';
          _canResendEmail = false;
          _resendCountdown = 60;
        });

        // Démarrer le compte à rebours
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_resendCountdown > 0) {
            if(mounted) {
              setState(() {
                _resendCountdown--;
              });
            }
          } else {
            if(mounted) {
              setState(() {
                _canResendEmail = true;
              });
            }
            timer.cancel();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
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

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              isDarkMode: widget.isDarkMode,
              onToggleDarkMode: widget.onToggleDarkMode,
            ),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la déconnexion';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authService.userEmail ?? 'votre email';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
            colors: widget.isDarkMode
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "SmartSpend",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
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
                                  onPressed: () => widget.onToggleDarkMode(!widget.isDarkMode),
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      key: ValueKey(widget.isDarkMode),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Contenu principal
                          Container(
                            margin: const EdgeInsets.only(top: 48),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Illustration
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.mark_email_read_outlined,
                                      size: 80,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Titre
                                Text(
                                  'Vérifiez votre email',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -0.5,
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 16),

                                // Description
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Nous avons envoyé un email de vérification à\n'),
                                      TextSpan(
                                        text: userEmail,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const TextSpan(text: '\n\nCliquez sur le lien dans l\'email pour activer votre compte.'),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 48),

                                // Indicateur de vérification en cours ou message de succès/erreur
                                if (_successMessage == null && _errorMessage == null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Vérification automatique en cours...',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_successMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _successMessage!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 16),
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

                                const SizedBox(height: 32),

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
                                    onPressed: _canResendEmail && !_isLoading ? _resendVerificationEmail : null,
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
                                      _canResendEmail
                                          ? 'Renvoyer l\'email'
                                          : 'Renvoyer dans ${_resendCountdown}s',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Bouton de déconnexion
                                TextButton(
                                  onPressed: _signOut,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                                    ),
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
