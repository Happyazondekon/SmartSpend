// screens/financial_goals_screen.dart
import 'package:flutter/material.dart';
import '../generated/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../models/financial_goal.dart';
import '../firestore_service.dart';
import '../models/user_data.dart';
import '../new_design_system.dart';

class FinancialGoalsScreen extends StatefulWidget {
  final bool openAddDialog;
  
  const FinancialGoalsScreen({super.key, this.openAddDialog = false});

  @override
  _FinancialGoalsScreenState createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<FinancialGoal> _goals = [];
  String _currency = 'XOF';
  bool _isLoading = true;

  // Icônes disponibles pour les objectifs
  final List<IconData> _availableIcons = [
    Icons.flight_takeoff_outlined,    // Voyage
    Icons.home_outlined,              // Maison
    Icons.directions_car_outlined,    // Voiture
    Icons.school_outlined,            // Éducation
    Icons.medical_services_outlined,  // Santé
    Icons.celebration_outlined,       // Mariage/Événement
    Icons.laptop_outlined,            // Technologie
    Icons.fitness_center_outlined,    // Sport/Fitness
    Icons.pets_outlined,              // Animaux
    Icons.savings_outlined,           // Épargne générale
    Icons.business_outlined,          // Business
    Icons.favorite_outlined,          // Personnel
  ];

  // Couleurs disponibles
  final List<Color> _availableColors = [
    const Color(0xFF4CAF50), // Vert
    const Color(0xFF2196F3), // Bleu
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Violet
    const Color(0xFFE91E63), // Rose
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF5722), // Rouge-Orange
    const Color(0xFF607D8B), // Bleu-Gris
    const Color(0xFF795548), // Marron
    const Color(0xFF3F51B5), // Indigo
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _firestoreService.loadUserData();
      if (userData != null) {
        setState(() {
          _goals = userData.financialGoals;
          _currency = userData.currency;
        });
      }
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.goalsLoadError, Colors.red);
    } finally {
      setState(() => _isLoading = false);
      // Ouvrir automatiquement le dialogue si demandé
      if (widget.openAddDialog && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAddGoalDialog();
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.goalsScreenTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
          ? _buildEmptyState()
          : _buildGoalsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Illustrations/empty_goals.webp',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.goalsEmptyTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.goalsEmptyDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showAddGoalDialog,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.goalsCreateButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    // Trier les objectifs : actifs d'abord, puis terminés
    final sortedGoals = [..._goals]
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.targetDate.compareTo(b.targetDate);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedGoals.length,
      itemBuilder: (context, index) {
        final goal = sortedGoals[index];
        return _buildGoalCard(goal);
      },
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    final progress = goal.progressPercentage / 100;
    final isNearDeadline = goal.isNearDeadline;
    final isOverdue = goal.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: goal.color.withOpacity(0.15),
                  child: Icon(goal.icon, color: goal.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (goal.isCompleted)
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                          if (isOverdue && !goal.isCompleted)
                            Icon(Icons.warning, color: Colors.red, size: 20),
                          if (isNearDeadline && !goal.isCompleted)
                            Icon(Icons.schedule, color: Colors.orange, size: 20),
                        ],
                      ),
                      if (goal.description.isNotEmpty)
                        Text(
                          goal.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'add_money':
                        _showAddMoneyDialog(goal);
                        break;
                      case 'edit':
                        _showEditGoalDialog(goal);
                        break;
                      case 'complete':
                        _completeGoal(goal);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(goal);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!goal.isCompleted) ...[
                      PopupMenuItem(
                        value: 'add_money',
                        child: ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: Text(AppLocalizations.of(context)!.goalsAddMoney),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (goal.currentAmount >= goal.targetAmount)
                        PopupMenuItem(
                          value: 'complete',
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                            title: Text(AppLocalizations.of(context)!.goalsMarkComplete),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                    if (!goal.isCompleted)
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(AppLocalizations.of(context)!.goalsEditButton),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        title: Text(AppLocalizations.of(context)!.goalsDeleteButton, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted ? Colors.green : goal.color,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Informations sur le progrès
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} $_currency',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal.isCompleted ? Colors.green : goal.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Informations sur l'échéance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.goalsDeadlineLabel}: ${DateFormat('dd/MM/yyyy').format(goal.targetDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  goal.isCompleted
                      ? AppLocalizations.of(context)!.goalsCompleted
                      : isOverdue
                      ? AppLocalizations.of(context)!.goalsOverdue
                      : AppLocalizations.of(context)!.goalsDaysRemaining(goal.daysRemaining),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: goal.isCompleted
                        ? Colors.green
                        : isOverdue
                        ? Colors.red
                        : isNearDeadline
                        ? Colors.orange
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Suggestions d'épargne
            if (!goal.isCompleted && goal.remainingAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.goalsToReachObjective,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.goalsDailyAmount(goal.dailySavingsNeeded.toStringAsFixed(0), _currency),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      AppLocalizations.of(context)!.goalsMonthlyAmount(goal.monthlySavingsNeeded.toStringAsFixed(0), _currency),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    
    DateTime targetDate = DateTime.now().add(const Duration(days: 365));
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

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
              maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                  // Indicateur de drag
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
                  
                  // Titre
                  Text(
                    AppLocalizations.of(context)!.goalsNewTitle,
                    style: AppTextStyles.titleLarge(isDark),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Nom de l'objectif
                  Text(
                    AppLocalizations.of(context)!.goalsNameLabel,
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: nameController,
                    style: AppTextStyles.bodyMediumThemed(isDark),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.goalsNameHint,
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

                  // Montant cible
                  Text(
                    AppLocalizations.of(context)!.goalsAmountLabel,
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
                      prefixText: '$_currency ',
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

                  // Description (optionnel)
                  Text(
                    AppLocalizations.of(context)!.goalsDescriptionLabel,
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: descriptionController,
                    style: AppTextStyles.bodyMediumThemed(isDark),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.goalsDescriptionHint,
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

                  // Date limite
                  Text(
                    AppLocalizations.of(context)!.goalsDeadlineDateLabel,
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setModalState(() => targetDate = picked);
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
                            DateFormat('dd/MM/yyyy').format(targetDate),
                            style: AppTextStyles.bodyMediumThemed(isDark),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Icônes
                  Text(AppLocalizations.of(context)!.goalsIconLabel, style: AppTextStyles.labelMedium(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: List.generate(_availableIcons.length, (index) {
                      final isSelected = selectedIconIndex == index;
                      final selectedColor = _availableColors[selectedColorIndex];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIconIndex = index),
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
                          child: Icon(
                            _availableIcons[index],
                            color: isSelected ? selectedColor : colors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Couleurs
                  Text(AppLocalizations.of(context)!.goalsColorLabel, style: AppTextStyles.labelMedium(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: List.generate(_availableColors.length, (index) {
                      final isSelected = selectedColorIndex == index;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColorIndex = index),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _availableColors[index],
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
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Bouton Créer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final targetAmount = double.tryParse(amountController.text) ?? 0;
                        
                        if (name.isEmpty || targetAmount <= 0) {
                          _showSnackBar(AppLocalizations.of(context)!.goalsValidationError, Colors.red);
                          return;
                        }
                        Navigator.pop(context);
                        _addGoal(
                          name,
                          descriptionController.text,
                          targetAmount,
                          targetDate,
                          _availableIcons[selectedIconIndex],
                          _availableColors[selectedColorIndex],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.goalsCreateButtonLabel),
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

  void _showAddMoneyDialog(FinancialGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final amountController = TextEditingController();
    final remaining = goal.targetAmount - goal.currentAmount;
    final progress = goal.progressPercentage;

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
              // Indicateur de drag
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
              
              // Titre avec icône
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(goal.icon, color: goal.color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: AppTextStyles.titleMedium(isDark),
                        ),
                        Text(
                          AppLocalizations.of(context)!.goalsPercentReached(progress.toStringAsFixed(0)),
                          style: AppTextStyles.labelSmall(isDark).copyWith(
                            color: goal.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: colors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Montants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.currentAmount.toStringAsFixed(0)} $_currency',
                    style: AppTextStyles.labelMedium(isDark).copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    '${goal.targetAmount.toStringAsFixed(0)} $_currency',
                    style: AppTextStyles.labelMedium(isDark).copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Champ montant
              Text(
                AppLocalizations.of(context)!.goalsAmountToAdd,
                style: AppTextStyles.labelMedium(isDark).copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: AppTextStyles.headlineMedium(isDark),
                decoration: InputDecoration(
                  prefixText: '$_currency ',
                  prefixStyle: AppTextStyles.headlineMedium(isDark).copyWith(
                    color: goal.color,
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
              
              // Info restant
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  AppLocalizations.of(context)!.goalsRemainingToReach(remaining.toStringAsFixed(0), _currency),
                  style: AppTextStyles.labelSmall(isDark).copyWith(color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Bouton Ajouter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      _showSnackBar(AppLocalizations.of(context)!.goalsInvalidAmount, Colors.red);
                      return;
                    }
                    Navigator.pop(context);
                    _addMoneyToGoal(goal.id, amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goal.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.goalsAddMoney),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGoalDialog(FinancialGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    
    DateTime targetDate = goal.targetDate;

    int selectedIconIndex = _availableIcons.indexWhere((icon) =>
        icon.codePoint == goal.icon.codePoint);
    if (selectedIconIndex == -1) selectedIconIndex = 0;

    int selectedColorIndex = _availableColors.indexWhere((color) =>
        color.value == goal.color.value);
    if (selectedColorIndex == -1) selectedColorIndex = 0;

    final nameController = TextEditingController(text: goal.name);
    final descriptionController = TextEditingController(text: goal.description);
    final amountController = TextEditingController(text: goal.targetAmount.toStringAsFixed(0));

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
              maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                  // Indicateur de drag
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
                  
                  // Titre
                  Text(
                    AppLocalizations.of(context)!.goalsEditTitle,
                    style: AppTextStyles.titleLarge(isDark),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Nom de l'objectif
                  Text(
                    AppLocalizations.of(context)!.goalsNameLabel,
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: nameController,
                    style: AppTextStyles.bodyMediumThemed(isDark),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.goalsNameHint,
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

                  // Montant cible
                  Text(
                    AppLocalizations.of(context)!.goalsAmountLabel,
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
                      prefixText: '$_currency ',
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
                    AppLocalizations.of(context)!.goalsDescriptionLabel,
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: descriptionController,
                    style: AppTextStyles.bodyMediumThemed(isDark),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.goalsDescriptionHint,
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

                  // Date limite
                  Text(
                    AppLocalizations.of(context)!.goalsDeadlineDateLabel,
                    style: AppTextStyles.labelMedium(isDark).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setModalState(() => targetDate = picked);
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
                            DateFormat('dd/MM/yyyy').format(targetDate),
                            style: AppTextStyles.bodyMediumThemed(isDark),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Icônes
                  Text(AppLocalizations.of(context)!.goalsIconLabel, style: AppTextStyles.labelMedium(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: List.generate(_availableIcons.length, (index) {
                      final isSelected = selectedIconIndex == index;
                      final selectedColor = _availableColors[selectedColorIndex];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIconIndex = index),
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
                          child: Icon(
                            _availableIcons[index],
                            color: isSelected ? selectedColor : colors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Couleurs
                  Text(AppLocalizations.of(context)!.goalsColorLabel, style: AppTextStyles.labelMedium(isDark)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: List.generate(_availableColors.length, (index) {
                      final isSelected = selectedColorIndex == index;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColorIndex = index),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _availableColors[index],
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
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Bouton Enregistrer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final targetAmount = double.tryParse(amountController.text) ?? 0;
                        
                        if (name.isEmpty || targetAmount <= 0) {
                          _showSnackBar(AppLocalizations.of(context)!.goalsValidationError, Colors.red);
                          return;
                        }
                        Navigator.pop(context);
                        _updateGoal(goal.copyWith(
                          name: name,
                          description: descriptionController.text,
                          targetAmount: targetAmount,
                          targetDate: targetDate,
                          icon: _availableIcons[selectedIconIndex],
                          color: _availableColors[selectedColorIndex],
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.goalsSaveButtonLabel),
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

  void _showDeleteConfirmation(FinancialGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            AppLocalizations.of(context)!.goalsDeleteConfirm,
            style: AppTextStyles.titleLarge(isDark),
          ),
          content: Text(
            AppLocalizations.of(context)!.goalsDeleteConfirmMessage(goal.name),
            style: AppTextStyles.bodyMediumThemed(isDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancelButton,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGoal(goal.id);
              },
              child: Text(AppLocalizations.of(context)!.deleteButton),
            ),
          ],
        );
      },
    );
  }

  // Méthodes pour les opérations CRUD
  Future<void> _addGoal(String name, String description, double targetAmount,
      DateTime targetDate, IconData icon, Color color) async {
    try {
      final goal = FinancialGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        targetAmount: targetAmount,
        targetDate: targetDate,
        createdDate: DateTime.now(),
        icon: icon,
        color: color,
      );

      await _firestoreService.addFinancialGoal(goal);
      _showSnackBar(AppLocalizations.of(context)!.goalsCreateSuccess, Colors.green);
      _loadData();
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.goalsCreateError, Colors.red);
    }
  }

  Future<void> _updateGoal(FinancialGoal goal) async {
    try {
      await _firestoreService.updateFinancialGoal(goal);
      _showSnackBar(AppLocalizations.of(context)!.goalsEditSuccess, Colors.green);
      _loadData();
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.goalsEditError, Colors.red);
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      await _firestoreService.deleteFinancialGoal(goalId);
      _showSnackBar(AppLocalizations.of(context)!.goalsDeleteSuccess, Colors.orange);
      _loadData();
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.goalsDeleteError, Colors.red);
    }
  }

  Future<void> _addMoneyToGoal(String goalId, double amount) async {
    try {
      // Trouver l'objectif localement
      final goal = _goals.firstWhere((g) => g.id == goalId, orElse: () => throw 'Objectif non trouvé');
      final montantRestant = goal.targetAmount - goal.currentAmount;

      if (amount > montantRestant) {
        _showSnackBar(
          AppLocalizations.of(context)!.goalsAmountExceedsRemaining(montantRestant.toStringAsFixed(2)),
          Colors.red,
        );
        return;
      }

      await _firestoreService.updateGoalProgress(goalId, amount);

      final newAmount = goal.currentAmount + amount;

      if (newAmount >= goal.targetAmount) {
        _showGoalAchievedDialog(goal.name);
      } else {
        _showSuccessDialog(AppLocalizations.of(context)!.goalsAmountAdded);
      }

      _loadData();
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.goalsAddError, Colors.red);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/Illustrations/success_check.webp',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGoalAchievedDialog(String goalName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/Illustrations/goal_achieved.webp',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.goalsCongratulations,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.goalsAchievedMessage(goalName),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(AppLocalizations.of(context)!.goalsGreatButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeGoal(FinancialGoal goal) async {
    try {
      await _firestoreService.completeFinancialGoal(goal.id);
      _showSnackBar(AppLocalizations.of(context)!.goalsAchieved, Colors.green);
      _loadData();
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.goalsFinalizeError, Colors.red);
    }
  }
}