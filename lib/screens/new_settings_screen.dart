import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_logic.dart';
import '../new_design_system.dart';
import '../theme_provider.dart';
import '../notification_service.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../generated/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.settingsTitle,
                  style: AppTextStyles.displaySmall(isDark),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.settingsSubtitle,
                  style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Profil
                _buildProfileSection(colors, isDark, budgetLogic, l10n),
                const SizedBox(height: AppSpacing.lg),

                // Apparence
                _buildSection(
                  title: l10n.settingsAppearance,
                  icon: Icons.palette_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildThemeSelector(colors, isDark, l10n),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Notifications
                _buildSection(
                  title: l10n.settingsNotifications,
                  icon: Icons.notifications_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildNotificationToggle(colors, isDark, l10n),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Sécurité
                _buildSection(
                  title: l10n.settingsSecurity,
                  icon: Icons.security_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildPinToggle(colors, isDark, l10n),
                    if (_pinEnabled)
                      _buildDataOption(
                        icon: Icons.lock_reset_rounded,
                        title: l10n.settingsChangePINTitle,
                        subtitle: l10n.settingsChangePINSubtitle,
                        colors: colors,
                        isDark: isDark,
                        onTap: () => _changePin(context, colors, isDark, l10n),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Devise
                _buildSection(
                  title: l10n.currency,
                  icon: Icons.attach_money_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildCurrencySelector(colors, isDark, budgetLogic),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Langue
                _buildSection(
                  title: l10n.language,
                  icon: Icons.language_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildLanguageSelector(colors, isDark),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Données
                _buildSection(
                  title: l10n.settingsData,
                  icon: Icons.storage_rounded,
                  colors: colors,
                  isDark: isDark,
                  children: [
                    _buildDataOption(
                      icon: Icons.download_rounded,
                      title: l10n.settingsExportData,
                      subtitle: l10n.settingsExportDataSubtitle,
                      colors: colors,
                      isDark: isDark,
                      onTap: () => budgetLogic.exportToPDF(context),
                    ),
                    _buildDataOption(
                      icon: Icons.history_rounded,
                      title: l10n.settingsMonthlyHistory,
                      subtitle: l10n.settingsMonthlyHistorySubtitle,
                      colors: colors,
                      isDark: isDark,
                      onTap: () => _showMonthlyHistory(context, budgetLogic, l10n),
                    ),
                    _buildDataOption(
                      icon: Icons.delete_forever_rounded,
                      title: l10n.settingsResetData,
                      subtitle: l10n.settingsResetDataSubtitle,
                      colors: colors,
                      isDark: isDark,
                      isDestructive: true,
                      onTap: () => _showResetConfirmation(context, budgetLogic, l10n),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Premium
                _buildPremiumCard(colors, isDark, budgetLogic, l10n),
                const SizedBox(height: AppSpacing.lg),

                // Déconnexion
                _buildLogoutButton(colors, isDark, l10n),
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
      AppColorScheme colors, bool isDark, BudgetLogic budgetLogic, AppLocalizations l10n) {
    final user = AuthService().currentUser;
    final email = user?.email ?? l10n.user;
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
                    budgetLogic.isPremium ? '⭐ Premium' : l10n.freeVersion,
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

  Widget _buildThemeSelector(AppColorScheme colors, bool isDark, AppLocalizations l10n) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  label: l10n.settingsLightMode,
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
                  label: l10n.settingsDarkMode,
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

  Widget _buildNotificationToggle(AppColorScheme colors, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.transactionRemindersTitle,
                  style: AppTextStyles.bodyMediumThemed(isDark),
                ),
                Text(
                  l10n.transactionRemindersSubtitle,
                  style: AppTextStyles.bodySmallThemed(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
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

  Widget _buildPinToggle(AppColorScheme colors, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pinCode,
                style: AppTextStyles.bodyMediumThemed(isDark),
              ),
              Text(
                l10n.settingsPinProtection,
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
                            content: Text(l10n.settingsPinEnabledSuccess),
                            backgroundColor: colors.success,
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                // Désactiver le PIN
                _showDisablePinConfirmation(context, colors, isDark, l10n);
              }
            },
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  void _showDisablePinConfirmation(
      BuildContext context, AppColorScheme colors, bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          l10n.settingsDisablePinConfirm,
          style: AppTextStyles.titleMedium(isDark),
        ),
        content: Text(
          l10n.settingsDisablePinWarning,
          style: AppTextStyles.bodyMediumThemed(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
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
                  content: Text(l10n.settingsPinDisabledSuccess),
                  backgroundColor: colors.warning,
                ),
              );
            },
            child: Text(
              l10n.settingsDisableButton,
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _changePin(BuildContext context, AppColorScheme colors, bool isDark, AppLocalizations l10n) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          onPinSet: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.settingsPinChangedSuccess),
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

  Widget _buildLanguageSelector(AppColorScheme colors, bool isDark) {
    return Consumer<LocalizationService>(
      builder: (context, locService, _) {
        final languages = [
          {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
          {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
        ];
        final currentLang = locService.currentLocale.languageCode;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: languages.map((lang) {
              final isSelected = currentLang == lang['code'];
              return GestureDetector(
                onTap: () => locService.setLanguage(lang['code']!),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        lang['label']!,
                        style: AppTextStyles.labelMedium(isDark).copyWith(
                          color: isSelected ? Colors.white : colors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
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
      AppColorScheme colors, bool isDark, BudgetLogic budgetLogic, AppLocalizations l10n) {
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
                l10n.settingsPremium,
                style: AppTextStyles.titleMedium(isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.settingsPremiumDescription,
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
              child: Text(l10n.seeOffers),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AppColorScheme colors, bool isDark, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, l10n),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: Text(l10n.settingsLogout),
      ),
    );
  }

  void _showMonthlyHistory(BuildContext context, BudgetLogic budgetLogic, AppLocalizations l10n) {
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
              l10n.settingsMonthlyHistory,
              style: AppTextStyles.titleLarge(isDark),
            ),
            const SizedBox(height: AppSpacing.md),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.settingsNoClosedMonths,
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
                        '${l10n.incomes}: ${budgetLogic.getCurrencySymbol()}${month.salary.toStringAsFixed(0)}'),
                    trailing: Text(
                      '${month.transactions.length} ${l10n.transactions}',
                      style: AppTextStyles.labelSmall(isDark),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, BudgetLogic budgetLogic, AppLocalizations l10n) {
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
          l10n.settingsResetConfirm,
          style: AppTextStyles.titleLarge(isDark),
        ),
        content: Text(
          l10n.settingsResetWarning,
          style: AppTextStyles.bodyMediumThemed(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              budgetLogic.resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsResetSuccess),
                  backgroundColor: colors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: Text(l10n.settingsResetButton),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppLocalizations l10n) {
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
          l10n.settingsLogoutConfirm,
          style: AppTextStyles.titleLarge(isDark),
        ),
        content: Text(
          l10n.settingsLogoutWarning,
          style: AppTextStyles.bodyMediumThemed(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.error),
            child: Text(l10n.settingsLogoutButton),
          ),
        ],
      ),
    );
  }
}
