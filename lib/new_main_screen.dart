import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_logic.dart';
import 'new_design_system.dart';
import 'theme_provider.dart';
import 'services/auth_service.dart';
import 'faq_chatbot.dart' show ElegantFAQChatBot;
import 'screens/new_budget_screen.dart';
import 'screens/new_transactions_screen.dart';
import 'screens/new_reports_screen.dart';
import 'screens/new_settings_screen.dart';
import 'screens/financial_goals_screen.dart';

class NewMainScreen extends StatefulWidget {
  const NewMainScreen({super.key});

  @override
  State<NewMainScreen> createState() => _NewMainScreenState();
}

class _NewMainScreenState extends State<NewMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    const NewBudgetScreen(),
    const NewTransactionsScreen(),
    const NewReportsScreen(),
    const NewSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colors, isDark),
      floatingActionButton: _buildFAB(colors, isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav(AppColorScheme colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(child: _buildNavItem(0, Icons.pie_chart_rounded, 'Budget', colors, isDark)),
              Flexible(child: _buildNavItem(1, Icons.receipt_long_rounded, 'Transactions', colors, isDark)),
              const SizedBox(width: 56), // Espace pour le FAB
              Flexible(child: _buildNavItem(2, Icons.bar_chart_rounded, 'Rapports', colors, isDark)),
              Flexible(child: _buildNavItem(3, Icons.settings_rounded, 'Paramètres', colors, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    AppColorScheme colors,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppAnimations.fast,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall(isDark).copyWith(
                color: isSelected ? colors.primary : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(AppColorScheme colors, bool isDark) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary, colors.secondary],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () => _showQuickActions(context, colors, isDark),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickActions(
      BuildContext context, AppColorScheme colors, bool isDark) {
    // Capturer le BudgetLogic AVANT d'ouvrir le bottom sheet
    final budgetLogic = Provider.of<BudgetLogic>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
          return Container(
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Actions rapides',
                  style: AppTextStyles.titleLarge(isDark),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      icon: Icons.add_card_rounded,
                      label: 'Transaction',
                      color: colors.primary,
                      colors: colors,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _showAddTransactionDialog(context, budgetLogic);
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.flag_rounded,
                      label: 'Objectif',
                      color: colors.secondary,
                      colors: colors,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FinancialGoalsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.smart_toy_rounded,
                      label: 'Assistant',
                      color: colors.warning,
                      colors: colors,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _openChatbot(context, budgetLogic);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required AppColorScheme colors,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelMedium(isDark),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, BudgetLogic budgetLogic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final categories = budgetLogic.getBudget().keys.toList();
    String selectedCategory = categories.isNotEmpty ? categories.first : '';
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
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
                  'Nouvelle transaction',
                  style: AppTextStyles.titleLarge(isDark),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Catégorie
                Text(
                  'Catégorie',
                  style: AppTextStyles.labelMedium(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedCategory = cat),
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
                          cat,
                          style: AppTextStyles.labelMedium(isDark).copyWith(
                            color: isSelected ? Colors.white : colors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Montant
                Text(
                  'Montant',
                  style: AppTextStyles.labelMedium(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: amountController,
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
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  'Description (optionnel)',
                  style: AppTextStyles.labelMedium(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: descriptionController,
                  style: AppTextStyles.bodyMediumThemed(isDark),
                  decoration: InputDecoration(
                    hintText: 'Ex: Courses du weekend',
                    hintStyle: AppTextStyles.bodyMediumThemed(isDark).copyWith(
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
                const SizedBox(height: AppSpacing.md),

                // Date de la transaction
                Text(
                  'Date',
                  style: AppTextStyles.labelMedium(isDark).copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    // Limiter au mois actif (pas de dates futures)
                    final firstDay = DateTime(now.year, now.month, 1);
                    final lastDay = now; // Aujourd'hui max
                    
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
                      firstDate: firstDay,
                      lastDate: lastDay,
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: colors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                          style: AppTextStyles.bodyMediumThemed(isDark),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null && amount > 0 && selectedCategory.isNotEmpty) {
                        budgetLogic.addTransaction(
                          selectedCategory,
                          amount,
                          descriptionController.text,
                          date: selectedDate,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Transaction ajoutée'),
                            backgroundColor: colors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text('Ajouter'),
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

  void _openChatbot(BuildContext context, BudgetLogic budgetLogic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (!budgetLogic.isPremium && budgetLogic.chatbotUsesUsed >= 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_rounded, color: colors.warning),
              const SizedBox(width: AppSpacing.sm),
              const Text('Limite atteinte'),
            ],
          ),
          content: const Text(
            'Vous avez utilisé vos 3 sessions gratuites de l\'assistant IA. Passez à Premium pour un accès illimité.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                budgetLogic.openPremiumPurchase(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.warning,
              ),
              child: const Text('Voir Premium'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ElegantFAQChatBot(),
      ),
    );
  }
}
