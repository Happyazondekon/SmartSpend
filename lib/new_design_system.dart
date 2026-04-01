import 'package:flutter/material.dart';

/// Couleurs de l'application
class AppColors {
  // Mode clair
  static const light = AppColorScheme(
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceVariant: Color(0xFFF1F5F9),
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF8B5CF6),
    accent: Color(0xFF14B8A6),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
  );

  // Mode sombre
  static const dark = AppColorScheme(
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    primary: Color(0xFF818CF8),
    secondary: Color(0xFFA78BFA),
    accent: Color(0xFF2DD4BF),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF334155),
  );
}

/// Schéma de couleurs personnalisé
class AppColorScheme {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  // Getters dérivés pour la compatibilité
  Color get divider => border;
  Color get cardBackground => surface;
}

/// Espacements standardisés
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Rayons de bordure
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

/// Durées d'animation
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Styles de texte
class AppTextStyles {
  // Display
  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle displaySmall(bool isDark) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  // Headline
  static TextStyle headlineLarge(bool isDark) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle headlineMedium(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  // Title
  static TextStyle titleLarge(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle titleMedium(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle titleSmall(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  // Body - méthodes avec couleur selon le thème
  static TextStyle bodyLargeThemed(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle bodyMediumThemed(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle bodySmallThemed(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: isDark
            ? AppColors.dark.textSecondary
            : AppColors.light.textSecondary,
      );

  // Label - méthodes avec couleur selon le thème
  static TextStyle labelLargeThemed(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle labelMediumThemed(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: isDark
            ? AppColors.dark.textPrimary
            : AppColors.light.textPrimary,
      );

  static TextStyle labelSmallThemed(bool isDark) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: isDark
            ? AppColors.dark.textSecondary
            : AppColors.light.textSecondary,
      );

  // Getters statiques pour utilisation sans paramètre isDark
  // (la couleur est définie via copyWith dans le code appelant)
  static TextStyle get h1 => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get h2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get h3 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );

  static TextStyle get buttonLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // Getters pour body sans couleur (définie via copyWith)
  static TextStyle get body => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  // Alias pour les méthodes avec paramètre isDark
  static TextStyle labelMedium(bool isDark) => labelMediumThemed(isDark);
  static TextStyle labelSmall(bool isDark) => labelSmallThemed(isDark);
}

/// Composants UI réutilisables
class AppComponents {
  /// Crée une carte avec le style standard
  static Widget card({
    required Widget child,
    required bool isDark,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    final colors = isDark ? AppColors.dark : AppColors.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  /// Bouton primaire
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    required bool isDark,
    IconData? icon,
    bool isLoading = false,
  }) {
    final colors = isDark ? AppColors.dark : AppColors.light;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(text),
              ],
            ),
    );
  }

  /// Indicateur de progression circulaire
  static Widget progressRing({
    required double progress,
    required bool isDark,
    double size = 120,
    Color? color,
    Widget? center,
  }) {
    final colors = isDark ? AppColors.dark : AppColors.light;
    final progressColor = color ?? colors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                colors.border,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          // Center content
          if (center != null) center,
        ],
      ),
    );
  }

  /// Badge de statut
  static Widget statusBadge({
    required String text,
    required bool isDark,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall(isDark).copyWith(
          color: textColor ?? colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Extensions utiles
extension ColorExtensions on Color {
  /// Ajoute de l'opacité à une couleur
  Color withOpacityValue(double opacity) {
    return withOpacity(opacity);
  }
}
