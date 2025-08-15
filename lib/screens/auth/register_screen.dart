import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleDarkMode;

  const RegisterScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Veuillez accepter les conditions d\'utilisation';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (result != null && mounted) {
        // Envoyer l'email de vérification
        await _authService.sendEmailVerification();

        // Naviguer vers l'écran de vérification
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            maintainState: true,
            builder: (context) => EmailVerificationScreen(
              isDarkMode: widget.isDarkMode,
              onToggleDarkMode: widget.onToggleDarkMode,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          // Gérer les erreurs spécifiques de Firebase
          if (e.code == 'email-already-in-use') {
            _errorMessage = 'L\'adresse e-mail est déjà utilisée.';
          } else {
            _errorMessage = e.message;
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

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null && mounted) {
        // Connexion réussie, naviguer vers l'écran principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            maintainState: true,
            builder: (context) => EmailVerificationScreen(
              isDarkMode: widget.isDarkMode,
              onToggleDarkMode: widget.onToggleDarkMode,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
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
                      child: SlideTransition(
                        position: _slideAnimation,
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

                            // Section de bienvenue
                            Container(
                              margin: const EdgeInsets.only(top: 48, bottom: 48),
                              child: Column(
                                children: [
                                  Text(
                                    'Créer un compte',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -1.0,
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rejoignez SmartSpend et prenez le contrôle de vos finances',
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

                            // Formulaire d'inscription
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Champ nom raffiné
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                                        child: Text(
                                          'Nom complet',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _nameController,
                                        keyboardType: TextInputType.name,
                                        textInputAction: TextInputAction.next,
                                        textCapitalization: TextCapitalization.words,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Votre nom et prénom',
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
                                              Icons.person_outline_rounded,
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
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Veuillez entrer votre nom';
                                          }
                                          if (value.trim().length < 2) {
                                            return 'Le nom doit contenir au moins 2 caractères';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

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
                                        textInputAction: TextInputAction.next,
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

                                  const SizedBox(height: 24),

                                  // Champ mot de passe raffiné
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                                        child: Text(
                                          'Mot de passe',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.next,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Minimum 6 caractères',
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
                                              Icons.lock_outline_rounded,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 20,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
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
                                            return 'Veuillez entrer un mot de passe';
                                          }
                                          if (value.length < 6) {
                                            return 'Le mot de passe doit contenir au moins 6 caractères';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Champ confirmation mot de passe raffiné
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                                        child: Text(
                                          'Confirmer le mot de passe',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _signUp(),
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Retapez votre mot de passe',
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
                                              Icons.lock_outline_rounded,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 20,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword = !_obscureConfirmPassword;
                                              });
                                            },
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
                                            return 'Veuillez confirmer votre mot de passe';
                                          }
                                          if (value != _passwordController.text) {
                                            return 'Les mots de passe ne correspondent pas';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Checkbox conditions d'utilisation
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _acceptedTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _acceptedTerms = value ?? false;
                                            if (_acceptedTerms) _errorMessage = null;
                                          });
                                        },
                                        activeColor: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                                fontSize: 14,
                                                height: 1.4,
                                              ),
                                              children: [
                                                const TextSpan(text: 'J\'accepte les '),
                                                TextSpan(
                                                  text: 'conditions d\'utilisation',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                                const TextSpan(text: ' et la '),
                                                TextSpan(
                                                  text: 'politique de confidentialité',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
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

                                  // Bouton d'inscription principal
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
                                      onPressed: _isLoading ? null : _signUp,
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
                                        'Créer mon compte',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Séparateur
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'ou',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Bouton Google élégant
                                  OutlinedButton.icon(
                                    onPressed: _isLoading ? null : _signUpWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      side: BorderSide(
                                        color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                                      ),
                                    ),
                                    icon: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    label: Text(
                                      'S\'inscrire avec Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Lien vers la connexion
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Déjà un compte ? ',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        maintainState: true,
                                        builder: (context) => LoginScreen(
                                          isDarkMode: widget.isDarkMode,
                                          onToggleDarkMode: widget.onToggleDarkMode,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Espace pour le bas de l'écran
                            const SizedBox(height: 24),
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
