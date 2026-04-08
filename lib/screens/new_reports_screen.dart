import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../budget_logic.dart';
import '../new_design_system.dart';

class NewReportsScreen extends StatefulWidget {
  const NewReportsScreen({super.key});

  @override
  State<NewReportsScreen> createState() => _NewReportsScreenState();
}

class _NewReportsScreenState extends State<NewReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _selectedPeriod = 0; // 0: Ce mois, 1: 3 mois, 2: 6 mois

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
        final currencySymbol = budgetLogic.getCurrencySymbol();
        final budget = budgetLogic.getBudget();

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Rapports',
                  style: AppTextStyles.displaySmall(isDark),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Analysez vos dépenses',
                  style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Sélecteur de période
                _buildPeriodSelector(colors, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Graphique circulaire
                _buildPieChart(budget, colors, isDark, currencySymbol),
                const SizedBox(height: AppSpacing.lg),

                // Statistiques clés
                _buildKeyStats(budgetLogic, colors, isDark, currencySymbol),
                const SizedBox(height: AppSpacing.lg),

                // Graphique en barres
                _buildBarChart(budget, colors, isDark),
                const SizedBox(height: AppSpacing.lg),

                // Détails par catégorie
                _buildCategoryDetails(
                    budget, colors, isDark, currencySymbol, budgetLogic),
                const SizedBox(height: AppSpacing.xl),

                // Bouton export PDF
                _buildExportButton(colors, isDark, budgetLogic),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector(AppColorScheme colors, bool isDark) {
    final periods = ['Ce mois', '3 mois', '6 mois'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedPeriod == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMedium(isDark).copyWith(
                    color: isSelected ? Colors.white : colors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(Map<String, Map<String, dynamic>> budget,
      AppColorScheme colors, bool isDark, String currencySymbol) {
    final categories = budget.entries.toList();
    final totalSpent =
        categories.fold(0.0, (sum, e) => sum + ((e.value['spent'] as num?) ?? 0));

    if (totalSpent == 0) {
      return _buildEmptyChartState(colors, isDark);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text(
            'Répartition des dépenses',
            style: AppTextStyles.titleMedium(isDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final e = entry.value;
                      final spent = (e.value['spent'] as num?)?.toDouble() ?? 0.0;
                      final percentage =
                          totalSpent > 0 ? (spent / totalSpent) * 100 : 0;

                      return PieChartSectionData(
                        color: _getCategoryColor(index),
                        value: spent,
                        title: percentage >= 5 ? '${percentage.toInt()}%' : '',
                        radius: 35,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currencySymbol${_formatNumber(totalSpent)}',
                      style: AppTextStyles.headlineMedium(isDark).copyWith(
                        color: colors.primary,
                      ),
                    ),
                    Text(
                      'Total dépensé',
                      style: AppTextStyles.labelSmall(isDark).copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Légende
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(index),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.key,
                    style: AppTextStyles.labelSmall(isDark),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState(AppColorScheme colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 64,
            color: colors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucune donnée',
            style: AppTextStyles.titleMedium(isDark),
          ),
          Text(
            'Ajoutez des transactions pour voir vos rapports',
            style: AppTextStyles.bodySmallThemed(isDark).copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStats(BudgetLogic budgetLogic, AppColorScheme colors,
      bool isDark, String currencySymbol) {
    final salary = budgetLogic.getSalary();
    final budget = budgetLogic.getBudget();
    final totalSpent =
        budget.values.fold(0.0, (sum, v) => sum + ((v['spent'] as num?) ?? 0));
    final remaining = salary - totalSpent;
    final savingsRate = salary > 0 ? (remaining / salary) * 100 : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_down_rounded,
            label: 'Dépensé',
            value: '$currencySymbol${_formatNumber(totalSpent)}',
            color: colors.error,
            colors: colors,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Restant',
            value: '$currencySymbol${_formatNumber(remaining)}',
            color: remaining >= 0 ? colors.success : colors.error,
            colors: colors,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            icon: Icons.savings_rounded,
            label: 'Épargne',
            value: '${savingsRate.toStringAsFixed(0)}%',
            color: colors.secondary,
            colors: colors,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required AppColorScheme colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleMedium(isDark).copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall(isDark).copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, Map<String, dynamic>> budget,
      AppColorScheme colors, bool isDark) {
    final categories = budget.entries.toList();
    if (categories.isEmpty) return const SizedBox.shrink();

    final maxAmount = categories.fold(
        0.0, (max, e) => ((e.value['amount'] as num?) ?? 0) > max ? (e.value['amount'] as num?)?.toDouble() ?? 0.0 : max);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget vs Dépenses',
            style: AppTextStyles.titleMedium(isDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < categories.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              categories[value.toInt()]
                                  .key
                                  .substring(0, categories[value.toInt()].key.length > 4 ? 4 : categories[value.toInt()].key.length),
                              style: AppTextStyles.labelSmall(isDark).copyWith(
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;
                  final amount = (e.value['amount'] as num?)?.toDouble() ?? 0.0;
                  final spent = (e.value['spent'] as num?)?.toDouble() ?? 0.0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: colors.primary.withOpacity(0.3),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: spent,
                        color: _getCategoryColor(index),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Budget', colors.primary.withOpacity(0.3), isDark),
              const SizedBox(width: AppSpacing.lg),
              _buildLegendItem('Dépensé', colors.secondary, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelSmall(isDark)),
      ],
    );
  }

  Widget _buildCategoryDetails(
    Map<String, Map<String, dynamic>> budget,
    AppColorScheme colors,
    bool isDark,
    String currencySymbol,
    BudgetLogic budgetLogic,
  ) {
    final categories = budget.entries.toList()
      ..sort((a, b) =>
          ((b.value['spent'] as num?) ?? 0).compareTo((a.value['spent'] as num?) ?? 0));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails par catégorie',
            style: AppTextStyles.titleMedium(isDark),
          ),
          const SizedBox(height: AppSpacing.md),
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            final amount = (e.value['amount'] as num?)?.toDouble() ?? 0.0;
            final spent = (e.value['spent'] as num?)?.toDouble() ?? 0.0;
            final percentage = (e.value['percentage'] as num?) ?? 0;
            final progress = amount > 0 ? spent / amount : 0.0;
            final isOverBudget = spent > amount;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(index),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: Text(
                                e.key,
                                style: AppTextStyles.bodyMediumThemed(isDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '(${percentage.toInt()}%)',
                              style: AppTextStyles.labelSmall(isDark).copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$currencySymbol${_formatNumber(spent)} / $currencySymbol${_formatNumber(amount)}',
                        style: AppTextStyles.labelMedium(isDark).copyWith(
                          color: isOverBudget ? colors.error : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? colors.error : _getCategoryColor(index),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExportButton(
      AppColorScheme colors, bool isDark, BudgetLogic budgetLogic) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => budgetLogic.exportToPDF(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: const Text('Exporter en PDF'),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final categoryColors = [
      const Color(0xFF6366F1),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFF6B7280),
    ];
    return categoryColors[index % categoryColors.length];
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
