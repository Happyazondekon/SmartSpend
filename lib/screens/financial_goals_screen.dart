// screens/financial_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/financial_goal.dart';
import '../firestore_service.dart';
import '../models/user_data.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

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
      _showSnackBar('Erreur lors du chargement des objectifs', Colors.red);
    } finally {
      setState(() => _isLoading = false);
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
        title: const Text('Objectifs Financiers'),
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
            Icon(
              Icons.track_changes_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun objectif défini',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez votre premier objectif financier pour commencer à épargner avec un but précis !',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showAddGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Créer un objectif'),
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
                      const PopupMenuItem(
                        value: 'add_money',
                        child: ListTile(
                          leading: Icon(Icons.add_circle_outline),
                          title: Text('Ajouter de l\'argent'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (goal.currentAmount >= goal.targetAmount)
                        const PopupMenuItem(
                          value: 'complete',
                          child: ListTile(
                            leading: Icon(Icons.check_circle_outline, color: Colors.green),
                            title: Text('Marquer comme terminé'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Modifier'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        title: Text('Supprimer', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
                  'Échéance: ${DateFormat('dd/MM/yyyy').format(goal.targetDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  goal.isCompleted
                      ? 'Terminé ✓'
                      : isOverdue
                      ? 'En retard'
                      : '${goal.daysRemaining} jours restants',
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
                      'Pour atteindre votre objectif:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ${goal.dailySavingsNeeded.toStringAsFixed(0)} $_currency par jour',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '• ${goal.monthlySavingsNeeded.toStringAsFixed(0)} $_currency par mois',
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
    String name = '';
    String description = '';
    double targetAmount = 0;
    DateTime targetDate = DateTime.now().add(const Duration(days: 365));
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouvel Objectif Financier'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'objectif',
                        hintText: 'ex: Visiter le Bénin',
                      ),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        hintText: 'Plus de détails sur votre objectif...',
                      ),
                      maxLines: 2,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Montant cible ($_currency)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => targetAmount = double.tryParse(value) ?? 0,
                    ),
                    const SizedBox(height: 16),

                    // Sélecteur de date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date limite'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(targetDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 ans
                        );
                        if (date != null) {
                          setState(() => targetDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sélecteur d'icône
                    Text('Icône', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_availableIcons.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIconIndex == index
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedIconIndex == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2
                              ),
                            ),
                            child: Icon(
                              _availableIcons[index],
                              color: selectedIconIndex == index
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Sélecteur de couleur
                    Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_availableColors.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedColorIndex = index),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _availableColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onBackground,
                                width: selectedColorIndex == index ? 3 : 0,
                              ),
                            ),
                            child: selectedColorIndex == index
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (name.trim().isEmpty || targetAmount <= 0) {
                      _showSnackBar('Veuillez remplir tous les champs obligatoires', Colors.red);
                      return;
                    }
                    Navigator.of(context).pop();
                    _addGoal(name, description, targetAmount, targetDate,
                        _availableIcons[selectedIconIndex], _availableColors[selectedColorIndex]);
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMoneyDialog(FinancialGoal goal) {
    double amount = 0;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter à "${goal.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Montant actuel: ${goal.currentAmount.toStringAsFixed(0)} $_currency',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Objectif: ${goal.targetAmount.toStringAsFixed(0)} $_currency',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Montant à ajouter ($_currency)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => amount = double.tryParse(value) ?? 0,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (amount <= 0) {
                  _showSnackBar('Veuillez entrer un montant valide', Colors.red);
                  return;
                }
                Navigator.of(context).pop();
                _addMoneyToGoal(goal.id, amount);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showEditGoalDialog(FinancialGoal goal) {
    String name = goal.name;
    String description = goal.description;
    double targetAmount = goal.targetAmount;
    DateTime targetDate = goal.targetDate;

    int selectedIconIndex = _availableIcons.indexWhere((icon) =>
    icon.codePoint == goal.icon.codePoint);
    if (selectedIconIndex == -1) selectedIconIndex = 0;

    int selectedColorIndex = _availableColors.indexWhere((color) =>
    color.value == goal.color.value);
    if (selectedColorIndex == -1) selectedColorIndex = 0;

    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: description);
    final amountController = TextEditingController(text: targetAmount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier l\'Objectif'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nom de l\'objectif'),
                      onChanged: (value) => name = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Montant cible ($_currency)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => targetAmount = double.tryParse(value) ?? 0,
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date limite'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(targetDate)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setState(() => targetDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sélecteur d'icône et couleur (même code que pour l'ajout)
                    Text('Icône', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_availableIcons.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIconIndex == index
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedIconIndex == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2
                              ),
                            ),
                            child: Icon(_availableIcons[index]),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_availableColors.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedColorIndex = index),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _availableColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onBackground,
                                width: selectedColorIndex == index ? 3 : 0,
                              ),
                            ),
                            child: selectedColorIndex == index
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (name.trim().isEmpty || targetAmount <= 0) {
                      _showSnackBar('Veuillez remplir tous les champs obligatoires', Colors.red);
                      return;
                    }
                    Navigator.of(context).pop();
                    _updateGoal(goal.copyWith(
                      name: name,
                      description: description,
                      targetAmount: targetAmount,
                      targetDate: targetDate,
                      icon: _availableIcons[selectedIconIndex],
                      color: _availableColors[selectedColorIndex],
                    ));
                  },
                  child: const Text('Modifier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer l\'objectif'),
          content: Text('Êtes-vous sûr de vouloir supprimer "${goal.name}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGoal(goal.id);
              },
              child: const Text('Supprimer'),
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
      _showSnackBar('Objectif créé avec succès !', Colors.green);
      _loadData();
    } catch (e) {
      _showSnackBar('Erreur lors de la création de l\'objectif', Colors.red);
    }
  }

  Future<void> _updateGoal(FinancialGoal goal) async {
    try {
      await _firestoreService.updateFinancialGoal(goal);
      _showSnackBar('Objectif modifié avec succès !', Colors.green);
      _loadData();
    } catch (e) {
      _showSnackBar('Erreur lors de la modification', Colors.red);
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      await _firestoreService.deleteFinancialGoal(goalId);
      _showSnackBar('Objectif supprimé', Colors.orange);
      _loadData();
    } catch (e) {
      _showSnackBar('Erreur lors de la suppression', Colors.red);
    }
  }

  Future<void> _addMoneyToGoal(String goalId, double amount) async {
    try {
      await _firestoreService.updateGoalProgress(goalId, amount);

      // Vérifier si l'objectif est maintenant atteint
      final updatedGoal = _goals.firstWhere((g) => g.id == goalId);
      final newAmount = updatedGoal.currentAmount + amount;

      if (newAmount >= updatedGoal.targetAmount) {
        _showSnackBar('🎉 Félicitations ! Objectif atteint !', Colors.green);
      } else {
        _showSnackBar('Montant ajouté avec succès !', Colors.green);
      }

      _loadData();
    } catch (e) {
      _showSnackBar('Erreur lors de l\'ajout', Colors.red);
    }
  }

  Future<void> _completeGoal(FinancialGoal goal) async {
    try {
      await _firestoreService.completeFinancialGoal(goal.id);
      _showSnackBar('🎉 Objectif marqué comme terminé !', Colors.green);
      _loadData();
    } catch (e) {
      _showSnackBar('Erreur lors de la finalisation', Colors.red);
    }
  }
}