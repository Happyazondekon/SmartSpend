import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_logic.dart';
import '../new_design_system.dart';
import '../theme_provider.dart';
import '../notification_service.dart';
import '../services/auth_service.dart';
import 'auth/pin_lock_screen.dart';
import 'auth/pin_setup_screen.dart';

class NewSettingsScreen extends StatefulWidget {
  const NewSettingsScreen({super.key});

  @override
  State<NewSettingsScreen> createState() => _NewSettingsScreenState();
}

class _NewSettingsScreenState extends State<NewSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _notificationsEnabled = true;
  bool _pinEnabled = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadNotificationState();
    _loadPinState();
  }

  Future<void> _loadNotificationState() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() => _notificationsEnabled = enabled);
    }
  }

  Future<void> _loadPinState() async {
    final enabled = await PinHelper.hasPin();
    if (mounted) {
      setState(() => _pinEnabled = enabled);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Consumer<BudgetLogic>(
      builder: (context, budgetLogic, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Paramètres',
                  style: AppTextStyles.displaySmall(isDark),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Personnalisez votre expérience',
                  style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Profil
                _buildProfileSection(colors, isDark, budgetLogic),
                const SizedBox(height: AppSpacing.lg),

                // Apparence
                _buildSection(
                  title: 'Apparence',
                  icon: Icons.palette_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildThemeSelector(colors, isDark),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Notifications
                _buildSection(
                  title: 'Notifications',
                  icon: Icons.notifications_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildNotificationToggle(colors, isDark),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Sécurité
                _buildSection(
                  title: 'Sécurité',
                  icon: Icons.security_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildPinToggle(colors, isDark),
                    if (_pinEnabled)
                      _buildDataOption(
                        icon: Icons.lock_reset_rounded,
                        title: 'Changer le code PIN',
                        subtitle: 'Modifier votre code de sécurité',
                        colors: colors,
                        isDark: isDark,
                        onTap: () => _changePin(context, colors, isDark),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Devise
                _buildSection(
                  title: 'Devise',
                  icon: Icons.attach_money_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildCurrencySelector(colors, isDark, budgetLogic),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Données
                _buildSection(
                  title: 'Données',
                  icon: Icons.storage_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildDataOption(
                      icon: Icons.download_rounded,
                      title: 'Exporter les données',
                      subtitle: 'Télécharger vos données en PDF',
                      colors: colors,
                      isDark: isDark,
                      onTap: () => budgetLogic.exportToPDF(context),
                    ),
                    _buildDataOption(
                      icon: Icons.history_rounded,
                      title: 'Historique mensuel',
                      subtitle: 'Voir l\'historique de vos mois clôturés',
                      colors: colors,
                      isDark: isDark,
                      onTap: () => _showMonthlyHistory(context, budgetLogic),
                    ),
                    _buildDataOption(
                      icon: Icons.delete_forever_rounded,
                      title: 'Réinitialiser les données',
                      subtitle: 'Supprimer toutes vos données',
                      colors: colors,
                      isDark: isDark,
                      isDestructive: true,
                      onTap: () => _showResetConfirmation(context, budgetLogic),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Premium
                _buildPremiumCard(colors, isDark, budgetLogic),
                const SizedBox(height: AppSpacing.lg),

                // Déconnexion
                _buildLogoutButton(colors, isDark),
                const SizedBox(height: AppSpacing.xl),

                // Version
                Center(
                  child: Text(
                    'SmartSpend v1.1.0',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(
      AppColorScheme colors, bool isDark, BudgetLogic budgetLogic) {
    final user = AuthService().currentUser;
    final email = user?.email ?? 'Utilisateur';
    final name = user?.displayName ?? email.split('@').first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.15),
            colors.secondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleLarge(isDark),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTextStyles.bodySmallThemed(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        budgetLogic.isPremium ? colors.warning : colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    budgetLogic.isPremium ? '⭐ Premium' : 'Gratuit',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: budgetLogic.isPremium
                          ? Colors.black87
                          : colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required AppColorScheme colors,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.titleSmall(isDark),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(AppColorScheme colors, bool isDark) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  label: 'Clair',
                  icon: Icons.light_mode_rounded,
                  isSelected: !themeProvider.isDarkMode,
                  colors: colors,
                  isDark: isDark,
                  onTap: () => themeProvider.toggleTheme(false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildThemeOption(
                  label: 'Sombre',
                  icon: Icons.dark_mode_rounded,
                  isSelected: themeProvider.isDarkMode,
                  colors: colors,
                  isDark: isDark,
                  onTap: () => themeProvider.toggleTheme(true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required AppColorScheme colors,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelSmall(isDark).copyWith(
                color: isSelected ? Colors.white : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(AppColorScheme colors, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rappels de transactions',
                style: AppTextStyles.bodyMediumThemed(isDark),
              ),
              Text(
                'Recevoir des rappels matin et soir',
                style: AppTextStyles.bodySmallThemed(isDark).copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await NotificationService().setNotificationsEnabled(value);
              if (value) {
                await NotificationService().scheduleAllReminders();
              } else {
                await NotificationService().cancelAllNotifications();
              }
            },
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPinToggle(AppColorScheme colors, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code PIN',
                style: AppTextStyles.bodyMediumThemed(isDark),
              ),
              Text(
                'Protéger l\'accès à l\'application',
                style: AppTextStyles.bodySmallThemed(isDark).copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          Switch(
            value: _pinEnabled,
            onChanged: (value) async {
              if (value) {
                // Configurer un nouveau PIN
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PinSetupScreen(
                      onPinSet: () {
                        Navigator.of(context).pop();
                        setState(() => _pinEnabled = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Code PIN activé avec succès'),
                            backgroundColor: colors.success,
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                // Désactiver le PIN
                _showDisablePinConfirmation(context, colors, isDark);
              }
            },
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  void _showDisablePinConfirmation(
      BuildContext context, AppColorScheme colors, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          'Désactiver le code PIN ?',
          style: AppTextStyles.titleMedium(isDark),
        ),
        content: Text(
          'Votre application ne sera plus protégée par un code de sécurité.',
          style: AppTextStyles.bodyMediumThemed(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await PinHelper.disablePin();
              Navigator.of(ctx).pop();
              setState(() => _pinEnabled = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code PIN désactivé'),
                  backgroundColor: colors.warning,
                ),
              );
            },
            child: Text(
              'Désactiver',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _changePin(BuildContext context, AppColorScheme colors, bool isDark) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          onPinSet: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Code PIN modifié avec succès'),
                backgroundColor: colors.success,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(
      AppColorScheme colors, bool isDark, BudgetLogic budgetLogic) {
    final currencies = ['XAF', 'EUR', 'USD', 'GBP', 'NGN'];
    final currentCurrency = budgetLogic.getCurrency();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: currencies.map((currency) {
          final isSelected = currentCurrency == currency;
          return GestureDetector(
            onTap: () => budgetLogic.setCurrency(currency),
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.background,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                ),
              ),
              child: Text(
                currency,
                style: AppTextStyles.labelMedium(isDark).copyWith(
                  color: isSelected ? Colors.white : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppColorScheme colors,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isDestructive ? colors.error : colors.primary)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: isDestructive ? colors.error : colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                      color: isDestructive ? colors.error : colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmallThemed(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(
      AppColorScheme colors, bool isDark, BudgetLogic budgetLogic) {
    if (budgetLogic.isPremium) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700).withOpacity(0.2),
            const Color(0xFFFFA500).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Passer à Premium',
                style: AppTextStyles.titleMedium(isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Débloquez toutes les fonctionnalités : exports PDF illimités, assistant IA illimité, et plus encore.',
            style: AppTextStyles.bodySmallThemed(isDark).copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => budgetLogic.openPremiumPurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text('Voir les offres'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppColorScheme colors, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Se déconnecter'),
      ),
    );
  }

  void _showMonthlyHistory(BuildContext context, BudgetLogic budgetLogic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final history = budgetLogic.getMonthlyHistory();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique mensuel',
              style: AppTextStyles.titleLarge(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Aucun mois clôturé',
                    style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...history.take(6).map((month) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.primary.withOpacity(0.15),
                      child: Icon(Icons.calendar_month_rounded,
                          color: colors.primary),
                    ),
                    title: Text('${month.monthName} ${month.year}'),
                    subtitle: Text(
                        'Revenus: ${budgetLogic.getCurrencySymbol()}${month.salary.toStringAsFixed(0)}'),
                    trailing: Text(
                      '${month.transactions.length} transactions',
                      style: AppTextStyles.labelSmall(isDark),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, BudgetLogic budgetLogic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Réinitialiser les données ?',
          style: AppTextStyles.titleLarge(isDark),
        ),
        content: Text(
          'Toutes vos données seront supprimées. Cette action est irréversible.',
          style: AppTextStyles.bodyMediumThemed(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              budgetLogic.resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Données réinitialisées'),
                  backgroundColor: colors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Se déconnecter ?',
          style: AppTextStyles.titleLarge(isDark),
        ),
        content: Text(
          'Vos données sont sauvegardées dans le cloud.',
          style: AppTextStyles.bodyMediumThemed(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}
