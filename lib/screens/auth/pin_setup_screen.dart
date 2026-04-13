import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../generated/gen_l10n/app_localizations.dart';
import '../../new_design_system.dart';
import '../../theme_provider.dart';

class PinSetupScreen extends StatefulWidget {
  final VoidCallback onPinSet;

  const PinSetupScreen({super.key, required this.onPinSet});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const String _pinKey = 'app_security_pin';
  static const String _pinEnabledKey = 'pin_enabled';

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
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    HapticFeedback.lightImpact();
    
    if (_isConfirming) {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += number;
          _error = null;
        });
        if (_confirmPin.length == 4) {
          _verifyPin();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() {
          _pin += number;
          _error = null;
        });
        if (_pin.length == 4) {
          setState(() {
            _isConfirming = true;
          });
        }
      }
    }
  }

  void _onDeletePressed() {
    HapticFeedback.lightImpact();
    
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          _error = null;
        });
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
          _error = null;
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    if (_pin == _confirmPin) {
      // Sauvegarder le PIN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, _pin);
      await prefs.setBool(_pinEnabledKey, true);
      
      if (mounted) {
        widget.onPinSet();
      }
    } else {
      // PIN ne correspond pas
      _shakeController.forward().then((_) => _shakeController.reverse());
      HapticFeedback.heavyImpact();
      
      setState(() {
        _error = AppLocalizations.of(context)!.pinSetupErrorMismatch;
        _confirmPin = '';
      });
    }
  }

  void _resetPin() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirming = false;
      _error = null;
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
                  
                  // Icône de sécurité
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
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Titre
                  Text(
                    _isConfirming ? AppLocalizations.of(context)!.pinSetupConfirmTitle : AppLocalizations.of(context)!.pinSetupTitle,
                    style: AppTextStyles.h2.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Sous-titre
                  Text(
                    _isConfirming
                        ? AppLocalizations.of(context)!.pinSetupConfirmDescription
                        : AppLocalizations.of(context)!.pinSetupDescription,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Indicateurs PIN
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
                        final currentPin = _isConfirming ? _confirmPin : _pin;
                        final isFilled = index < currentPin.length;
                        
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
                  if (_error != null) ...[
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
                  _buildNumericKeyboard(colors, isDark),
                  
                  // Bouton reset si en mode confirmation
                  if (_isConfirming) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _resetPin,
                      child: Text(
                        AppLocalizations.of(context)!.pinSetupRestart,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
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
    final currentPin = _isConfirming ? _confirmPin : _pin;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: currentPin.isNotEmpty ? _onDeletePressed : null,
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
              color: currentPin.isNotEmpty
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
