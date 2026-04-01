import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../new_design_system.dart';
import '../../theme_provider.dart';
import 'new_login_screen.dart';

class NewEmailVerificationScreen extends StatefulWidget {
  const NewEmailVerificationScreen({super.key});

  @override
  State<NewEmailVerificationScreen> createState() =>
      _NewEmailVerificationScreenState();
}

class _NewEmailVerificationScreenState extends State<NewEmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ThemeProvider _themeProvider = ThemeProvider();

  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? _timer;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_onThemeChanged);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!_isEmailVerified) {
      _sendVerificationEmail();
      _startEmailVerificationCheck();
    }
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    _animationController.dispose();
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        _timer?.cancel();
        if (mounted) {
          setState(() => _isEmailVerified = true);
          // Attendre un moment puis naviguer
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail) return;

    try {
      await _authService.sendEmailVerification();
      setState(() {
        _canResendEmail = false;
        _secondsRemaining = 60;
      });

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          setState(() => _canResendEmail = true);
          timer.cancel();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi de l\'email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeProvider.isDarkMode;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [colors.background, colors.surface]
                : [colors.primary.withOpacity(0.05), colors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      Text(
                        'SmartSpend',
                        style: AppTextStyles.h3.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      _buildThemeToggle(colors),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl * 2),

                  // Animation icône
                  Center(
                    child: _isEmailVerified
                        ? _buildSuccessIcon(colors)
                        : _buildEmailIcon(colors),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Titre
                  Text(
                    _isEmailVerified
                        ? 'Email vérifié ! 🎉'
                        : 'Vérifiez votre email',
                    style: AppTextStyles.h1.copyWith(
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _isEmailVerified
                        ? 'Votre compte est maintenant activé.\nRedirection en cours...'
                        : 'Nous avons envoyé un email de vérification à :',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (!_isEmailVerified) ...[
                    const SizedBox(height: AppSpacing.lg),

                    // Email card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.email_rounded,
                              color: colors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Flexible(
                            child: Text(
                              user?.email ?? '',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Instructions
                    _buildInstructionCard(colors),

                    const SizedBox(height: AppSpacing.xl),

                    // Bouton renvoyer
                    _buildResendButton(colors),

                    const SizedBox(height: AppSpacing.lg),

                    // Bouton changer email
                    _buildSecondaryButton(
                      text: 'Utiliser un autre email',
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewLoginScreen(),
                            ),
                          );
                        }
                      },
                      colors: colors,
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xl),

                    // Indicateur de redirection
                    Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(AppColorScheme colors) {
    return GestureDetector(
      onTap: () => _themeProvider.toggleTheme(!_themeProvider.isDarkMode),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
        ),
        child: Icon(
          _themeProvider.isDarkMode
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          color: colors.primary,
        ),
      ),
    );
  }

  Widget _buildEmailIcon(AppColorScheme colors) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread_rounded,
                  size: 60,
                  color: colors.primary,
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.warning,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon(AppColorScheme colors) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(
              Icons.verified_rounded,
              size: 60,
              color: colors.success,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionCard(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInstructionRow(
            '1',
            'Ouvrez votre application email',
            Icons.email_outlined,
            colors,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInstructionRow(
            '2',
            'Cliquez sur le lien de vérification',
            Icons.link_rounded,
            colors,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInstructionRow(
            '3',
            'Revenez sur cette page',
            Icons.refresh_rounded,
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(
    String number,
    String text,
    IconData icon,
    AppColorScheme colors,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        Icon(icon, color: colors.primary, size: 20),
      ],
    );
  }

  Widget _buildResendButton(AppColorScheme colors) {
    return GestureDetector(
      onTap: _canResendEmail ? _sendVerificationEmail : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: _canResendEmail
              ? LinearGradient(
                  colors: [colors.primary, colors.primary.withOpacity(0.8)],
                )
              : null,
          color: _canResendEmail ? null : colors.divider,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canResendEmail
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            _canResendEmail
                ? 'Renvoyer l\'email'
                : 'Renvoyer dans $_secondsRemaining s',
            style: AppTextStyles.buttonLarge.copyWith(
              color: _canResendEmail ? Colors.white : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    required AppColorScheme colors,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.buttonLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
