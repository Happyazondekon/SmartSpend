import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart'; // Assurez-vous que l'importation de LoginScreen est correcte
import '../../theme_provider.dart'; // NOUVEAU: Importation du ThemeProvider

class ForgotPasswordScreen extends StatefulWidget {
  // SUPPRIMÉ: final bool isDarkMode;
  // SUPPRIMÉ: final Function(bool) onToggleDarkMode;

  const ForgotPasswordScreen({
    super.key,
    // SUPPRIMÉ: required this.isDarkMode,
    // SUPPRIMÉ: required this.onToggleDarkMode,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final ThemeProvider _themeProvider = ThemeProvider(); // NOUVEAU: Instance unique

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;
  String? _successMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // NOUVEAU: Écouter les changements de thème
    _themeProvider.addListener(_onThemeChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    // NOUVEAU: Arrêter d'écouter les changements
    _themeProvider.removeListener(_onThemeChanged);
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // NOUVEAU: Callback pour les changements de thème
  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.resetPassword(email: _emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
          _successMessage = 'Un email de réinitialisation a été envoyé à ${_emailController.text.trim()}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Une erreur est survenue. Veuillez vérifier votre adresse email.";
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
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Espace pour le haut de l'écran
                            const SizedBox(height: 24),

                            // En-tête avec SmartSpend et le bouton de thème
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Bouton de retour
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
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          maintainState: true,
                                          builder: (context) => const LoginScreen(), // MODIFIÉ: Suppression des paramètres
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
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

                            // Section de bienvenue
                            Container(
                              margin: const EdgeInsets.only(top: 48, bottom: 48),
                              child: Column(
                                children: [
                                  Text(
                                    'Mot de passe oublié ?',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -1.0,
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pas de souci ! Entrez votre adresse e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            // Condition si l'email a été envoyé ou non
                            if (!_emailSent) ...[
                              // Formulaire
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Champ email raffiné
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                                          child: Text(
                                            'Adresse e-mail',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) => _resetPassword(),
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'nom@exemple.com',
                                            hintStyle: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                            ),
                                            prefixIcon: Container(
                                              margin: const EdgeInsets.all(12),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.email_outlined,
                                                color: Theme.of(context).colorScheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Theme.of(context).colorScheme.primary,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer votre e-mail';
                                            }
                                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                              return 'Format d\'e-mail invalide';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 32),

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

                                    // Bouton d'envoi élégant
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
                                        onPressed: _isLoading ? null : _resetPassword,
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
                                            : const Text(
                                          'Envoyer le lien',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Écran de confirmation
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.mark_email_read_outlined,
                                        size: 48,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    Text(
                                      'Email envoyé !',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 16),

                                    if (_successMessage != null)
                                      Text(
                                        _successMessage!,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                    const SizedBox(height: 32),

                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Vérifiez votre boîte de réception (et vos spams) puis cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe.',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 48),

                            // Bouton retour à la connexion
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        maintainState: true,
                                        builder: (context) => const LoginScreen(), // MODIFIÉ: Suppression des paramètres
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Retour à la connexion',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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