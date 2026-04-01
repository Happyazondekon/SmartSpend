import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_logic.dart';
import '../new_design_system.dart';

class NewBudgetScreen extends StatefulWidget {
  const NewBudgetScreen({super.key});

  @override
  State<NewBudgetScreen> createState() => _NewBudgetScreenState();
}

class _NewBudgetScreenState extends State<NewBudgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetLogic>(
      builder: (context, budgetLogic, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colors = isDark ? AppColors.dark : AppColors.light;

        if (budgetLogic.isLoading) {
          return _buildLoadingState(colors, isDark);
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec titre et salaire
                _buildHeader(budgetLogic, colors, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Carte récapitulative "Sky View"
                _buildSkyViewCard(budgetLogic, colors, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Section catégories
                _buildCategoriesSection(budgetLogic, colors, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Dernières transactions
                _buildRecentTransactions(budgetLogic, colors, isDark),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(AppColorScheme colors, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chargement...',
            style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BudgetLogic budgetLogic, AppColorScheme colors, bool isDark) {
    final currencySymbol = budgetLogic.getCurrencySymbol();
    final salary = budgetLogic.getSalary();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble',
              style: AppTextStyles.displaySmall(isDark),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _getGreeting(),
              style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        // Badge revenus
        GestureDetector(
          onTap: () => _showSalaryDialog(budgetLogic, colors, isDark),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  salary > 0
                      ? '$currencySymbol${_formatNumber(salary)}'
                      : 'Définir',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkyViewCard(
      BudgetLogic budgetLogic, AppColorScheme colors, bool isDark) {
    final salary = budgetLogic.getSalary();
    final budget = budgetLogic.getBudget();
    final currencySymbol = budgetLogic.getCurrencySymbol();

    final totalSpent =
        budget.values.fold(0.0, (sum, v) => sum + (v['spent'] as num));
    final totalBudget =
        budget.values.fold(0.0, (sum, v) => sum + (v['amount'] as num));
    final remaining = salary - totalSpent;
    final progress = salary > 0 ? totalSpent / salary : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  colors.primary.withOpacity(0.1),
                  colors.secondary.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Progress ring central
          Row(
            children: [
              // Graphique circulaire
              AppComponents.progressRing(
                progress: progress,
                isDark: isDark,
                size: 100,
                color: progress > 1 ? colors.error : colors.primary,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTextStyles.headlineMedium(isDark).copyWith(
                        color: progress > 1 ? colors.error : colors.primary,
                      ),
                    ),
                    Text(
                      'utilisé',
                      style: AppTextStyles.labelSmall(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Statistiques
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      label: 'Dépensé',
                      value: '$currencySymbol${_formatNumber(totalSpent)}',
                      color: colors.error,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildStatRow(
                      label: 'Budget',
                      value: '$currencySymbol${_formatNumber(totalBudget)}',
                      color: colors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildStatRow(
                      label: 'Restant',
                      value: '$currencySymbol${_formatNumber(remaining)}',
                      color: remaining >= 0 ? colors.success : colors.error,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Barre de progression linéaire
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression du mois',
                    style: AppTextStyles.labelSmall(isDark),
                  ),
                  Text(
                    '${_getDaysRemainingInMonth()} jours restants',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 1 ? colors.error : colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium(isDark).copyWith(
            color: isDark
                ? AppColors.dark.textSecondary
                : AppColors.light.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall(isDark).copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(
      BudgetLogic budgetLogic, AppColorScheme colors, bool isDark) {
    final budget = budgetLogic.getBudget();
    final currencySymbol = budgetLogic.getCurrencySymbol();
    final categories = budget.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catégories',
              style: AppTextStyles.titleLarge(isDark),
            ),
            TextButton.icon(
              onPressed: () => _showAddCategoryDialog(budgetLogic, colors, isDark),
              icon: Icon(Icons.add_rounded, color: colors.primary, size: 20),
              label: Text(
                'Ajouter',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Grille de catégories
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final entry = categories[index];
            return _buildCategoryCard(
              name: entry.key,
              data: entry.value,
              currencySymbol: currencySymbol,
              colors: colors,
              isDark: isDark,
              onTap: () => _showCategoryDetails(
                  budgetLogic, entry.key, entry.value, colors, isDark),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required Map<String, dynamic> data,
    required String currencySymbol,
    required AppColorScheme colors,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final spent = (data['spent'] as num?)?.toDouble() ?? 0.0;
    final percentage = (data['percentage'] as num?) ?? 0;
    final color = data['color'] as Color? ?? colors.primary;
    final progress = amount > 0 ? spent / amount : 0.0;
    final isOverBudget = spent > amount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isOverBudget ? colors.error.withOpacity(0.5) : colors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    data['icon'] as IconData? ?? Icons.category_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                Text(
                  '${percentage.toInt()}%',
                  style: AppTextStyles.labelSmall(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              style: AppTextStyles.titleSmall(isDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$currencySymbol${_formatNumber(spent)} / $currencySymbol${_formatNumber(amount)}',
              style: AppTextStyles.labelSmall(isDark).copyWith(
                color: isOverBudget ? colors.error : colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? colors.error : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
      BudgetLogic budgetLogic, AppColorScheme colors, bool isDark) {
    final transactions = budgetLogic.getTransactions();
    final currencySymbol = budgetLogic.getCurrencySymbol();
    final recentTransactions = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions récentes',
          style: AppTextStyles.titleLarge(isDark),
        ),
        const SizedBox(height: AppSpacing.md),
        if (recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: colors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucune transaction',
                    style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: recentTransactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                final budget = budgetLogic.getBudget();
                final categoryData = budget[transaction.category];
                final color =
                    categoryData?['color'] as Color? ?? colors.primary;

                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          categoryData?['icon'] as IconData? ??
                              Icons.category_rounded,
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        transaction.description.isNotEmpty
                            ? transaction.description
                            : transaction.category,
                        style: AppTextStyles.bodyMediumThemed(isDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        transaction.category,
                        style: AppTextStyles.labelSmall(isDark),
                      ),
                      trailing: Text(
                        '-$currencySymbol${_formatNumber(transaction.amount)}',
                        style: AppTextStyles.titleSmall(isDark).copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                    if (index < recentTransactions.length - 1)
                      Divider(height: 1, color: colors.border),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // Méthodes utilitaires
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour 👋';
    if (hour < 18) return 'Bon après-midi ☀️';
    return 'Bonsoir 🌙';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  int _getDaysRemainingInMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.day - now.day;
  }

  // Dialogues
  void _showSalaryDialog(
      BudgetLogic budgetLogic, AppColorScheme colors, bool isDark) {
    final controller = budgetLogic.getSalaryController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Vos revenus mensuels',
                style: AppTextStyles.titleLarge(isDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Entrez votre salaire ou revenus mensuels nets',
                style: AppTextStyles.bodySmallThemed(isDark),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: AppTextStyles.headlineMedium(isDark),
                decoration: InputDecoration(
                  prefixText: '${budgetLogic.getCurrencySymbol()} ',
                  prefixStyle: AppTextStyles.headlineMedium(isDark).copyWith(
                    color: colors.primary,
                  ),
                  hintText: '0',
                  hintStyle: AppTextStyles.headlineMedium(isDark).copyWith(
                    color: colors.textSecondary.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    budgetLogic.calculateBudget();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('Calculer le budget'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(
      BudgetLogic budgetLogic, AppColorScheme colors, bool isDark) {
    final nameController = TextEditingController();
    final percentController = TextEditingController();
    Color selectedColor = colors.primary;
    IconData selectedIcon = Icons.category_rounded;

    final availableIcons = [
      Icons.home_rounded,
      Icons.directions_car_rounded,
      Icons.restaurant_rounded,
      Icons.shopping_bag_rounded,
      Icons.sports_esports_rounded,
      Icons.medical_services_rounded,
      Icons.school_rounded,
      Icons.savings_rounded,
      Icons.receipt_long_rounded,
      Icons.phone_android_rounded,
      Icons.flight_rounded,
      Icons.movie_rounded,
    ];

    final availableColors = [
      const Color(0xFF6366F1),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Nouvelle catégorie',
                    style: AppTextStyles.titleLarge(isDark),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Nom
                  TextField(
                    controller: nameController,
                    style: AppTextStyles.bodyMediumThemed(isDark),
                    decoration: InputDecoration(
                      labelText: 'Nom de la catégorie',
                      filled: true,
                      fillColor: colors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Pourcentage
                  TextField(
                    controller: percentController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMediumThemed(isDark),
                    decoration: InputDecoration(
                      labelText: 'Pourcentage du budget',
                      suffixText: '%',
                      filled: true,
                      fillColor: colors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Icônes
                  Text('Icône', style: AppTextStyles.labelMedium(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: availableIcons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor.withOpacity(0.2)
                                : colors.background,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? selectedColor : colors.border,
                            ),
                          ),
                          child: Icon(icon,
                              color: isSelected
                                  ? selectedColor
                                  : colors.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Couleurs
                  Text('Couleur', style: AppTextStyles.labelMedium(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: availableColors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Bouton
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final percent =
                            int.tryParse(percentController.text) ?? 0;

                        if (name.isNotEmpty && percent > 0) {
                          budgetLogic.addCategory(
                            name,
                            percent / 100,
                            selectedIcon,
                            selectedColor,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: const Text('Ajouter la catégorie'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(BudgetLogic budgetLogic, String name,
      Map<String, dynamic> data, AppColorScheme colors, bool isDark) {
    final currencySymbol = budgetLogic.getCurrencySymbol();
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final spent = (data['spent'] as num?)?.toDouble() ?? 0.0;
    final percentage = data['percentage'] as num;
    final color = data['color'] as Color? ?? colors.primary;
    final remaining = amount - spent;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    data['icon'] as IconData? ?? Icons.category_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.titleLarge(isDark)),
                      Text(
                        '${percentage.toInt()}% du budget',
                        style: AppTextStyles.bodySmallThemed(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildDetailStat(
                    label: 'Budget',
                    value: '$currencySymbol${_formatNumber(amount)}',
                    color: colors.primary,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildDetailStat(
                    label: 'Dépensé',
                    value: '$currencySymbol${_formatNumber(spent)}',
                    color: colors.error,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildDetailStat(
                    label: 'Restant',
                    value: '$currencySymbol${_formatNumber(remaining)}',
                    color: remaining >= 0 ? colors.success : colors.error,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Éditer la catégorie
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      budgetLogic.deleteCategory(name);
                    },
                    icon: Icon(Icons.delete_rounded, color: colors.error),
                    label: Text('Supprimer',
                        style: TextStyle(color: colors.error)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.error),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium(isDark).copyWith(color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall(isDark),
        ),
      ],
    );
  }
}
