import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import '../../new_design_system.dart';
import '../../theme_provider.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onLogout;

  const PinLockScreen({
    super.key,
    required this.onUnlocked,
    this.onLogout,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _error;
  int _attempts = 0;
  bool _isLocked = false;
  int _lockSeconds = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canUseBiometrics = false;

  static const String _pinKey = 'app_security_pin';
  static const int _maxAttempts = 5;
  static const int _lockDurationSeconds = 30;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _checkBiometrics();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    // Ne pas utiliser la biométrie sur les plateformes non supportées
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    
    try {
      // Sur Android, vérifier la version du SDK
      // Désactiver complètement la biométrie sur Android < 9 (API 28)
      // car ces versions ont des problèmes de compatibilité qui causent des crashs
      if (Platform.isAndroid) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;
          final sdkInt = androidInfo.version.sdkInt;
          
          debugPrint('Android SDK version: $sdkInt');
          
          if (sdkInt < 28) {
            debugPrint('Biométrie désactivée: Android $sdkInt < 28 (Android 9)');
            // Ne pas activer la biométrie sur les anciennes versions
            return;
          }
        } catch (e) {
          // Si on ne peut pas obtenir la version SDK, continuer avec la biométrie
          debugPrint('Impossible de vérifier la version SDK: $e');
        }
      }
      
      // Vérifier si le device supporte la biométrie
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        debugPrint('Biométrie: Device non supporté');
        return;
      }
      
      // Vérifier si on peut vérifier la biométrie
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        debugPrint('Biométrie: Vérification non disponible');
        return;
      }
      
      // Vérifier quels types de biométrie sont disponibles
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('Biométries disponibles: $availableBiometrics');
      
      if (availableBiometrics.isEmpty) {
        debugPrint('Biométrie: Aucune biométrie configurée');
        return;
      }
      
      // Vérifier si on a au moins une biométrie utilisable
      final hasUsableBiometric = availableBiometrics.any((bio) =>
          bio == BiometricType.fingerprint ||
          bio == BiometricType.face ||
          bio == BiometricType.strong ||
          bio == BiometricType.weak);
      
      if (!hasUsableBiometric) {
        debugPrint('Biométrie: Pas de biométrie utilisable');
        return;
      }
      
      if (mounted) {
        setState(() {
          _canUseBiometrics = true;
        });
        
        // Délai avant l'authentification automatique
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted && _canUseBiometrics) {
          _authenticateWithBiometrics();
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Biométrie PlatformException: ${e.code} - ${e.message}');
      // Ne pas afficher d'erreur, juste désactiver silencieusement
      if (mounted) {
        setState(() {
          _canUseBiometrics = false;
        });
      }
    } catch (e) {
      debugPrint('Biométrie erreur générale: $e');
      if (mounted) {
        setState(() {
          _canUseBiometrics = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_canUseBiometrics) return;
    
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Déverrouillez SmartSpend avec votre empreinte',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permettre PIN/Pattern sur anciennes versions
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );
      
      if (authenticated && mounted) {
        HapticFeedback.lightImpact();
        widget.onUnlocked();
      }
    } on PlatformException catch (e) {
      // Erreurs spécifiques à la plateforme (Android ancien, pas de capteur, etc.)
      debugPrint('Auth biométrique PlatformException: ${e.code} - ${e.message}');
      
      // Désactiver silencieusement la biométrie si erreur critique
      if (e.code == 'NotAvailable' || 
          e.code == 'NotEnrolled' || 
          e.code == 'PasscodeNotSet' ||
          e.code == 'LockedOut' ||
          e.code == 'PermanentlyLockedOut') {
        if (mounted) {
          setState(() {
            _canUseBiometrics = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Auth biométrique erreur: $e');
      // Ne pas crasher, juste ignorer l'erreur
    }
  }

  void _onNumberPressed(String number) {
    if (_isLocked) return;
    
    HapticFeedback.lightImpact();
    
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _error = null;
      });
      
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_isLocked) return;
    
    HapticFeedback.lightImpact();
    
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    
    if (_enteredPin == savedPin) {
      // PIN correct
      HapticFeedback.lightImpact();
      widget.onUnlocked();
    } else {
      // PIN incorrect
      _shakeController.forward().then((_) => _shakeController.reverse());
      HapticFeedback.heavyImpact();
      
      _attempts++;
      
      if (_attempts >= _maxAttempts) {
        _lockApp();
      } else {
        setState(() {
          _error = 'Code incorrect (${_maxAttempts - _attempts} essais restants)';
          _enteredPin = '';
        });
      }
    }
  }

  void _lockApp() {
    setState(() {
      _isLocked = true;
      _lockSeconds = _lockDurationSeconds;
      _enteredPin = '';
      _error = null;
    });
    
    _startLockTimer();
  }

  void _startLockTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isLocked) {
        setState(() {
          _lockSeconds--;
          if (_lockSeconds <= 0) {
            _isLocked = false;
            _attempts = 0;
          }
        });
        
        if (_isLocked) {
          _startLockTimer();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final colors = isDark ? AppColors.dark : AppColors.light;

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
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Logo SmartSpend
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
                  
                  // Titre
                  Text(
                    'SmartSpend',
                    style: AppTextStyles.h1.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Sous-titre
                  Text(
                    _isLocked
                        ? 'Trop de tentatives'
                        : 'Entrez votre code PIN',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _isLocked ? colors.error : colors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Indicateurs PIN ou compteur
                  if (_isLocked)
                    _buildLockTimer(colors)
                  else
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _enteredPin.length;
                          
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: isFilled ? 20 : 16,
                            height: isFilled ? 20 : 16,
                            decoration: BoxDecoration(
                              color: isFilled ? colors.primary : Colors.transparent,
                              border: Border.all(
                                color: _error != null
                                    ? colors.error
                                    : isFilled
                                        ? colors.primary
                                        : colors.textSecondary.withOpacity(0.5),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  
                  // Message d'erreur
                  if (_error != null && !_isLocked) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Clavier numérique
                  if (!_isLocked) _buildNumericKeyboard(colors, isDark),
                  
                  // Boutons supplémentaires
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_canUseBiometrics && !_isLocked)
                        TextButton.icon(
                          onPressed: _authenticateWithBiometrics,
                          icon: Icon(
                            Icons.fingerprint,
                            color: colors.primary,
                          ),
                          label: Text(
                            'Biométrie',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                      
                      if (widget.onLogout != null) ...[
                        const SizedBox(width: 24),
                        TextButton.icon(
                          onPressed: widget.onLogout,
                          icon: Icon(
                            Icons.logout,
                            color: colors.error,
                          ),
                          label: Text(
                            'Déconnexion',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLockTimer(AppColorScheme colors) {
    return Column(
      children: [
        Icon(
          Icons.lock_clock,
          size: 48,
          color: colors.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Réessayez dans $_lockSeconds secondes',
          style: AppTextStyles.bodyLarge.copyWith(
            color: colors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNumericKeyboard(AppColorScheme colors, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyButton('1', colors, isDark),
              _buildKeyButton('2', colors, isDark),
              _buildKeyButton('3', colors, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyButton('4', colors, isDark),
              _buildKeyButton('5', colors, isDark),
              _buildKeyButton('6', colors, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyButton('7', colors, isDark),
              _buildKeyButton('8', colors, isDark),
              _buildKeyButton('9', colors, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _buildKeyButton('0', colors, isDark),
              _buildDeleteButton(colors, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(String number, AppColorScheme colors, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(36),
        splashColor: colors.primary.withOpacity(0.2),
        highlightColor: colors.primary.withOpacity(0.1),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : colors.primary.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(AppColorScheme colors, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enteredPin.isNotEmpty ? _onDeletePressed : null,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: _enteredPin.isNotEmpty
                  ? colors.textPrimary
                  : colors.textSecondary.withOpacity(0.3),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Utilitaire pour vérifier si le PIN est configuré
class PinHelper {
  static const String _pinKey = 'app_security_pin';
  static const String _pinEnabledKey = 'pin_enabled';

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_pinKey);
    return pin != null && pin.isNotEmpty;
  }

  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.setBool(_pinEnabledKey, false);
  }

  static Future<void> changePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
    await prefs.setBool(_pinEnabledKey, true);
  }
}
