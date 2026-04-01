import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../budget_logic.dart';
import '../new_design_system.dart';
import '../models/transaction.dart' as models;

class NewTransactionsScreen extends StatefulWidget {
  const NewTransactionsScreen({super.key});

  @override
  State<NewTransactionsScreen> createState() => _NewTransactionsScreenState();
}

class _NewTransactionsScreenState extends State<NewTransactionsScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'Tout';
  String _selectedSort = 'Date';
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetLogic>(
      builder: (context, budgetLogic, _) {
        final categories = budgetLogic.getBudget().keys.toList();
        final transactions = _getFilteredTransactions(budgetLogic);
        final currencySymbol = budgetLogic.getCurrencySymbol();

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header avec recherche
              _buildHeader(categories),

              // Résumé
              _buildSummary(budgetLogic, currencySymbol),

              // Liste des transactions
              Expanded(
                child: transactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionsList(
                        transactions, budgetLogic, currencySymbol),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(List<String> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Transactions',
            style: AppTextStyles.displaySmall(isDark),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMediumThemed(isDark),
              decoration: InputDecoration(
                hintText: 'Rechercher une transaction...',
                hintStyle: AppTextStyles.bodyMediumThemed(isDark).copyWith(
                  color: colors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tout', Icons.apps_rounded),
                const SizedBox(width: AppSpacing.sm),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _buildFilterChip(cat, _getCategoryIcon(cat)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium(isDark).copyWith(
                color: isSelected ? Colors.white : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BudgetLogic budgetLogic, String currencySymbol) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final transactions = budgetLogic.getTransactions();
    final now = DateTime.now();
    final thisMonthTransactions = transactions.where((t) {
      return t.date.month == now.month && t.date.year == now.year;
    }).toList();

    final totalSpent =
        thisMonthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final transactionCount = thisMonthTransactions.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withOpacity(0.1),
              colors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ce mois',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$currencySymbol${_formatNumber(totalSpent)}',
                    style: AppTextStyles.headlineMedium(isDark).copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: colors.border,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Transactions',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$transactionCount',
                    style: AppTextStyles.headlineMedium(isDark).copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: colors.border,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Moyenne/jour',
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$currencySymbol${_formatNumber(totalSpent / (now.day > 0 ? now.day : 1))}',
                    style: AppTextStyles.headlineMedium(isDark).copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Aucune transaction',
            style: AppTextStyles.titleLarge(isDark),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vos transactions apparaîtront ici',
            style: AppTextStyles.bodyMediumThemed(isDark).copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    List<models.Transaction> transactions,
    BudgetLogic budgetLogic,
    String currencySymbol,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    // Grouper par date
    final grouped = <String, List<models.Transaction>>{};
    for (var t in transactions) {
      final dateKey = _formatDateKey(t.date);
      grouped.putIfAbsent(dateKey, () => []).add(t);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayTransactions = grouped[dateKey]!;
        final dayTotal = dayTransactions.fold(0.0, (sum, t) => sum + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la date
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateDisplay(dateKey),
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    '-$currencySymbol${_formatNumber(dayTotal)}',
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.error,
                    ),
                  ),
                ],
              ),
            ),

            // Transactions du jour
            ...dayTransactions.asMap().entries.map((entry) {
              final t = entry.value;
              final transactionIndex = transactions.indexOf(t);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildTransactionCard(
                  t,
                  currencySymbol,
                  budgetLogic,
                  transactionIndex,
                ),
              );
            }),

            if (index < sortedKeys.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(
    models.Transaction transaction,
    String currencySymbol,
    BudgetLogic budgetLogic,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final categoryColor = _getCategoryColor(transaction.category);

    return Dismissible(
      key: Key('transaction_${transaction.date}_${transaction.amount}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            title: Text(
              'Supprimer la transaction ?',
              style: AppTextStyles.titleLarge(isDark),
            ),
            content: Text(
              'Cette action est irréversible.',
              style: AppTextStyles.bodyMediumThemed(isDark),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style:
                      TextStyle(color: colors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        budgetLogic.deleteTransaction(transaction);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            // Icône catégorie
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : transaction.category,
                    style: AppTextStyles.titleSmall(isDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.category,
                    style: AppTextStyles.labelSmall(isDark).copyWith(
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Montant
            Text(
              '-$currencySymbol${_formatNumber(transaction.amount)}',
              style: AppTextStyles.titleMedium(isDark).copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<models.Transaction> _getFilteredTransactions(BudgetLogic budgetLogic) {
    var transactions = budgetLogic.getTransactions();
    final searchQuery = _searchController.text.toLowerCase();

    // Filtrer par catégorie
    if (_selectedFilter != 'Tout') {
      transactions = transactions
          .where((t) => t.category == _selectedFilter)
          .toList();
    }

    // Filtrer par recherche
    if (searchQuery.isNotEmpty) {
      transactions = transactions.where((t) {
        return t.category.toLowerCase().contains(searchQuery) ||
            t.description.toLowerCase().contains(searchQuery) ||
            t.amount.toString().contains(searchQuery);
      }).toList();
    }

    // Trier par date (plus récent en premier)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Loyer': Icons.home_rounded,
      'Nourriture': Icons.restaurant_rounded,
      'Transport': Icons.directions_car_rounded,
      'Loisirs': Icons.sports_esports_rounded,
      'Santé': Icons.medical_services_rounded,
      'Éducation': Icons.school_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Factures': Icons.receipt_long_rounded,
      'Épargne': Icons.savings_rounded,
      'Autres': Icons.more_horiz_rounded,
    };
    return icons[category] ?? Icons.category_rounded;
  }

  Color _getCategoryColor(String category) {
    final categoryColors = {
      'Loyer': const Color(0xFF6366F1),
      'Nourriture': const Color(0xFFF59E0B),
      'Transport': const Color(0xFF3B82F6),
      'Loisirs': const Color(0xFF8B5CF6),
      'Santé': const Color(0xFFEF4444),
      'Éducation': const Color(0xFF10B981),
      'Shopping': const Color(0xFFEC4899),
      'Factures': const Color(0xFF6B7280),
      'Épargne': const Color(0xFF14B8A6),
      'Autres': const Color(0xFF9CA3AF),
    };
    return categoryColors[category] ?? const Color(0xFF6366F1);
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;

    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Aujourd'hui";
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Hier';
    }

    final months = [
      '',
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];

    return '${date.day} ${months[date.month]}';
  }
}
