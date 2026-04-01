import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SmartSpend Design System
/// Basé sur les maquettes modernes Light/Dark
class AppDesign {
  // === COULEURS ===
  
  // Couleurs principales
  static const Color primaryDark = Color(0xFF0EA5E9);  // Bleu cyan clair
  static const Color primaryLight = Color(0xFF0284C7); // Bleu professionnel
  static const Color accentDark = Color(0xFF38BDF8);   // Accent cyan
  static const Color accentLight = Color(0xFF0369A1);  // Accent bleu foncé
  
  // Fonds
  static const Color backgroundDark = Color(0xFF0A0F14);  // Fond sombre profond
  static const Color backgroundLight = Color(0xFFF8FAFC); // Fond blanc cassé
  
  // Surfaces (Cards)
  static const Color surfaceDark = Color(0xFF111827);     // Card sombre
  static const Color surfaceLight = Color(0xFFFFFFFF);    // Card blanc
  static const Color surfaceElevatedDark = Color(0xFF1E293B);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);
  
  // Textes
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedDark = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  
  // États
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // === HELPER METHODS ===
  
  static Color primary(bool isDark) => isDark ? primaryDark : primaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
  static Color background(bool isDark) => isDark ? backgroundDark : backgroundLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceElevated(bool isDark) => isDark ? surfaceElevatedDark : surfaceElevatedLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(bool isDark) => isDark ? textMutedDark : textMutedLight;
  
  // === GRADIENTS ===
  
  static LinearGradient primaryGradient(bool isDark) => LinearGradient(
    colors: isDark 
        ? [primaryDark, accentDark]
        : [primaryLight, accentLight],
  );
  
  static LinearGradient cardGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark 
        ? [surfaceDark, surfaceElevatedDark.withOpacity(0.8)]
        : [surfaceLight, surfaceElevatedLight.withOpacity(0.5)],
  );
  
  // === SHADOWS ===
  
  static List<BoxShadow> cardShadow(bool isDark) => isDark 
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
      : [
          BoxShadow(
            color: primaryLight.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
  
  static List<BoxShadow> buttonShadow(bool isDark) => [
    BoxShadow(
      color: primary(isDark).withOpacity(isDark ? 0.3 : 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // === BORDER RADIUS ===
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;
  
  // === SPACING ===
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
}

/// Widgets de design réutilisables
class SmartCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool elevated;
  final VoidCallback? onTap;
  final bool hasBorder;
  
  const SmartCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevated = false,
    this.onTap,
    this.hasBorder = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? (elevated 
            ? AppDesign.surfaceElevated(isDark) 
            : AppDesign.surface(isDark)),
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        border: hasBorder ? Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ) : null,
        boxShadow: AppDesign.cardShadow(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Card avec gradient pour stats importantes
class GradientStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final bool isLarge;
  
  const GradientStatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.isLarge = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppDesign.primary(isDark);
    
    return SmartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.textSecondary(isDark),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isLarge ? 42 : 32,
                  fontWeight: FontWeight.w700,
                  color: AppDesign.textPrimary(isDark),
                  height: 1,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppDesign.textSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (icon != null) ...[
            const SizedBox(height: 12),
            Icon(icon, color: accent.withOpacity(0.7), size: 20),
          ],
        ],
      ),
    );
  }
}

/// Card de progression de budget
class BudgetProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double spent;
  final double total;
  final String currency;
  final Color? color;
  
  const BudgetProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.spent,
    required this.total,
    required this.currency,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final progressColor = color ?? AppDesign.primary(isDark);
    final percentage = (progress * 100).toInt();
    
    return SmartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppDesign.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppDesign.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppDesign.radiusRound),
                ),
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatNumber(spent)} / ${_formatNumber(total)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppDesign.textPrimary(isDark),
                ),
              ),
              Text(
                currency,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppDesign.textSecondary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppDesign.surfaceElevated(isDark),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [progressColor, progressColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FIXED COSTS',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppDesign.textMuted(isDark),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'FREE CASH FLOW',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppDesign.textMuted(isDark),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}k';
    }
    return number.toStringAsFixed(0);
  }
}

/// Card d'allocation de catégorie
class AllocationCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final double spent;
  final double allocated;
  final String currency;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const AllocationCard({
    super.key,
    required this.name,
    this.subtitle,
    required this.spent,
    required this.allocated,
    required this.currency,
    required this.icon,
    required this.color,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
    
    Color progressColor = color;
    if (progress > 1) progressColor = AppDesign.error;
    else if (progress > 0.9) progressColor = AppDesign.warning;
    
    return SmartCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppDesign.textPrimary(isDark),
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppDesign.textSecondary(isDark),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${spent.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: progressColor,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${allocated.toStringAsFixed(0)} $currency',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppDesign.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Barre de progression
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppDesign.surfaceElevated(isDark),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 6,
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppDesign.textSecondary(isDark),
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20, color: AppDesign.textSecondary(isDark)),
                        const SizedBox(width: 12),
                        const Text('Modifier'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: AppDesign.error),
                        const SizedBox(width: 12),
                        Text('Supprimer', style: TextStyle(color: AppDesign.error)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Card d'objectif financier
class GoalCard extends StatelessWidget {
  final String name;
  final String? description;
  final String? category;
  final double currentAmount;
  final double targetAmount;
  final String currency;
  final IconData icon;
  final Color color;
  final DateTime? targetDate;
  final VoidCallback? onTap;
  
  const GoalCard({
    super.key,
    required this.name,
    this.description,
    this.category,
    required this.currentAmount,
    required this.targetAmount,
    required this.currency,
    required this.icon,
    required this.color,
    this.targetDate,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();
    
    return SmartCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              if (category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDesign.radiusRound),
                  ),
                  child: Text(
                    category!.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppDesign.textPrimary(isDark),
            ),
          ),
          if (description != null)
            Text(
              description!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppDesign.textSecondary(isDark),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$currency${_formatNumber(currentAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    TextSpan(
                      text: ' / $currency${_formatNumber(targetAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppDesign.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppDesign.surfaceElevated(isDark),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 8,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)},${(number % 1000).toStringAsFixed(0).padLeft(3, '0').substring(0, 3)}';
    }
    return number.toStringAsFixed(0);
  }
}

/// Card d'insight avec gradient
class InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? gradientStart;
  final Color? gradientEnd;
  
  const InsightCard({
    super.key,
    required this.title,
    required this.content,
    this.actionLabel,
    this.onAction,
    this.gradientStart,
    this.gradientEnd,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startColor = gradientStart ?? AppDesign.primary(isDark);
    final endColor = gradientEnd ?? AppDesign.accent(isDark);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            startColor.withOpacity(isDark ? 0.3 : 0.15),
            endColor.withOpacity(isDark ? 0.2 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        border: Border.all(
          color: startColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppDesign.textPrimary(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppDesign.textSecondary(isDark),
                height: 1.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: startColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Transaction item
class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final IconData icon;
  final Color color;
  final bool isIncome;
  final String? status;
  final VoidCallback? onTap;
  
  const TransactionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.color,
    this.isIncome = false,
    this.status,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SmartCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppDesign.textPrimary(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (status != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppDesign.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                        ),
                        child: Text(
                          status!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppDesign.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppDesign.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}$currency${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isIncome ? AppDesign.success : AppDesign.textPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppDesign.textPrimary(isDark),
            ),
          ),
          if (trailing != null) 
            trailing!
          else if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.primary(isDark),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bottom navigation bar moderne
class SmartBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const SmartBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final items = [
      _NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'BUDGET'),
      _NavItem(Icons.flag_outlined, Icons.flag, 'GOALS'),
      _NavItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'STATS'),
      _NavItem(Icons.history_outlined, Icons.history, 'HISTORY'),
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesign.surface(isDark),
        borderRadius: BorderRadius.circular(AppDesign.radiusXLarge),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];
          
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppDesign.primary(isDark).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected 
                        ? AppDesign.primary(isDark) 
                        : AppDesign.textSecondary(isDark),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? AppDesign.primary(isDark) 
                          : AppDesign.textSecondary(isDark),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  
  _NavItem(this.icon, this.activeIcon, this.label);
}

/// Circular progress indicator pour les stats
class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final String value;
  final String? subtitle;
  final String currency;
  final double size;
  final Color? color;
  
  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.value,
    this.subtitle,
    required this.currency,
    this.size = 180,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = color ?? AppDesign.primary(isDark);
    
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
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                AppDesign.surfaceElevated(isDark),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(progressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppDesign.textSecondary(isDark),
                    letterSpacing: 1,
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.w700,
                      color: AppDesign.textPrimary(isDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      currency,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppDesign.textSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Create goal button style
class CreateGoalButton extends StatelessWidget {
  final VoidCallback onTap;
  
  const CreateGoalButton({super.key, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppDesign.primaryGradient(isDark),
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        boxShadow: AppDesign.buttonShadow(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Create New Goal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fuel your next adventure or build your safety net.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
