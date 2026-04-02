import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartspend/services/auth_service.dart';
import 'package:smartspend/utils/icon_utils.dart';
import 'dart:convert';
import 'dart:io';
import 'models/transaction.dart';
import 'notification_service.dart';
import 'firestore_service.dart';
import 'models/user_data.dart';
import '../models/financial_goal.dart';


class BudgetLogic extends ChangeNotifier {
  BuildContext? _context;
  final FirestoreService _firestoreService = FirestoreService();

  // État interne pour le mode Provider
  Map<String, Map<String, dynamic>> _budget = {
    'Loyer': {'percentage': 30, 'amount': 0.0, 'icon': Icons.home_work_outlined, 'color': const Color(0xFF6366F1), 'spent': 0.0},
    'Transport': {'percentage': 10, 'amount': 0.0, 'icon': Icons.directions_bus_filled_outlined, 'color': const Color(0xFF3B82F6), 'spent': 0.0},
    'Électricité/Eau': {'percentage': 7, 'amount': 0.0, 'icon': Icons.lightbulb_outline, 'color': const Color(0xFFF59E0B), 'spent': 0.0},
    'Internet': {'percentage': 5, 'amount': 0.0, 'icon': Icons.wifi, 'color': const Color(0xFF8B5CF6), 'spent': 0.0},
    'Nourriture': {'percentage': 15, 'amount': 0.0, 'icon': Icons.restaurant_menu_outlined, 'color': const Color(0xFFEF4444), 'spent': 0.0},
    'Loisirs': {'percentage': 8, 'amount': 0.0, 'icon': Icons.sports_esports_outlined, 'color': const Color(0xFFEC4899), 'spent': 0.0},
    'Épargne': {'percentage': 25, 'amount': 0.0, 'icon': Icons.savings_outlined, 'color': const Color(0xFF10B981), 'spent': 0.0},
  };
  double _salary = 0;
  String _currency = 'XAF';
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  DateTime _selectedMonth = DateTime.now();
  bool _notificationsEnabled = false;
  final TextEditingController _salaryController = TextEditingController();
  List<FinancialGoal> _financialGoals = [];
  List<MonthlyData> _monthlyHistory = [];
  int _activeMonth = DateTime.now().month;
  int _activeYear = DateTime.now().year;
  bool _isPremium = false;
  int _pdfExportsUsed = 0;
  int _chatbotUsesUsed = 0;
  bool _isLoading = true;

  // Getters pour le mode Provider
  Map<String, Map<String, dynamic>> getBudget() => _budget;
  double getSalary() => _salary;
  String getCurrency() => _currency;
  List<Transaction> getTransactions() => _transactions;
  List<Transaction> getFilteredTransactions() => _filteredTransactions;
  DateTime getSelectedMonth() => _selectedMonth;
  bool getNotificationsEnabled() => _notificationsEnabled;
  TextEditingController getSalaryController() => _salaryController;
  List<FinancialGoal> getFinancialGoals() => _financialGoals;
  List<MonthlyData> getMonthlyHistory() => _monthlyHistory;
  bool get isPremium => _isPremium;
  int get pdfExportsUsed => _pdfExportsUsed;
  int get chatbotUsesUsed => _chatbotUsesUsed;
  bool get isLoading => _isLoading;

  // Setters pour le mode Provider
  void setBudget(Map<String, Map<String, dynamic>> budget) {
    _budget = budget;
    notifyListeners();
  }
  void setSalary(double salary) {
    _salary = salary;
    notifyListeners();
  }
  void setCurrency(String currency) {
    _currency = currency;
    _firestoreService.updateCurrency(currency);
    notifyListeners();
  }
  void setTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }
  void setFilteredTransactions(List<Transaction> transactions) {
    _filteredTransactions = transactions;
    notifyListeners();
  }
  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    updateFilteredTransactions();
    notifyListeners();
  }
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Constructeur pour Provider
  BudgetLogic.withContext(BuildContext context) {
    _context = context;
    _initializeData();
  }

  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();
    
    await loadSavedData();
    await loadNotificationStatus();
    
    _isLoading = false;
    notifyListeners();
  }

  void updateState() {
    notifyListeners();
  }

  // Legacy support - pour l'ancien système basé sur callbacks
  late final VoidCallback? _legacyUpdateState;
  late final Map<String, Map<String, dynamic>> Function()? _legacyGetBudget;
  late final Function(Map<String, Map<String, dynamic>>)? _legacySetBudget;
  late final double Function()? _legacyGetSalary;
  late final Function(double)? _legacySetSalary;
  late final String Function()? _legacyGetCurrency;
  late final Function(String)? _legacySetCurrency;
  late final List<Transaction> Function()? _legacyGetTransactions;
  late final Function(List<Transaction>)? _legacySetTransactions;
  late final List<Transaction> Function()? _legacyGetFilteredTransactions;
  late final Function(List<Transaction>)? _legacySetFilteredTransactions;
  late final DateTime Function()? _legacyGetSelectedMonth;
  late final Function(DateTime)? _legacySetSelectedMonth;
  late final bool Function()? _legacyGetNotificationsEnabled;
  late final Function(bool)? _legacySetNotificationsEnabled;
  late final TextEditingController Function()? _legacyGetSalaryController;

  // Ancien constructeur pour rétrocompatibilité
  BudgetLogic({
    required BuildContext context,
    required VoidCallback updateState,
    required Map<String, Map<String, dynamic>> Function() getBudget,
    required Function(Map<String, Map<String, dynamic>>) setBudget,
    required double Function() getSalary,
    required Function(double) setSalary,
    required String Function() getCurrency,
    required Function(String) setCurrency,
    required List<Transaction> Function() getTransactions,
    required Function(List<Transaction>) setTransactions,
    required List<Transaction> Function() getFilteredTransactions,
    required Function(List<Transaction>) setFilteredTransactions,
    required DateTime Function() getSelectedMonth,
    required Function(DateTime) setSelectedMonth,
    required bool Function() getNotificationsEnabled,
    required Function(bool) setNotificationsEnabled,
    required TextEditingController Function() getSalaryController,
  }) {
    _context = context;
    _legacyUpdateState = updateState;
    _legacyGetBudget = getBudget;
    _legacySetBudget = setBudget;
    _legacyGetSalary = getSalary;
    _legacySetSalary = setSalary;
    _legacyGetCurrency = getCurrency;
    _legacySetCurrency = setCurrency;
    _legacyGetTransactions = getTransactions;
    _legacySetTransactions = setTransactions;
    _legacyGetFilteredTransactions = getFilteredTransactions;
    _legacySetFilteredTransactions = setFilteredTransactions;
    _legacyGetSelectedMonth = getSelectedMonth;
    _legacySetSelectedMonth = setSelectedMonth;
    _legacyGetNotificationsEnabled = getNotificationsEnabled;
    _legacySetNotificationsEnabled = setNotificationsEnabled;
    _legacyGetSalaryController = getSalaryController;
  }

  // Contexte actif
  BuildContext get context => _context!;
  set context(BuildContext ctx) => _context = ctx;

  // ===================================================================
  // ===================== GESTION DES NOTIFICATIONS ==================
  // ===================================================================

  /// Active/désactive les rappels quotidiens (stocké en local)
  Future<void> toggleDailyReminders(bool enabled) async {
    final notificationService = NotificationService();

    if (enabled) {
      // Vérifier et demander les permissions
      final hasPermissions = await notificationService.requestPermissions();
      if (!hasPermissions) {
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Permission de notification refusée. Activez-la dans les paramètres.', Colors.red);
        return;
      }

      // Vérifier les permissions système
      final systemEnabled = await notificationService.areSystemNotificationsEnabled();
      if (!systemEnabled) {
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Les notifications sont désactivées dans les paramètres Android', Colors.red);
        return;
      }

      // Vérifier l'optimisation batterie
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      if (batteryStatus.isDenied) {
        _showSnackBar('Pour des rappels fiables, désactivez l\'optimisation de batterie pour SmartSpend', Colors.orange);
      }

      try {
        // Activer et programmer tous les rappels
        await notificationService.setNotificationsEnabled(true);
        await notificationService.scheduleNewMonthReminder();
        setNotificationsEnabled(true);
        updateState();
        _showSnackBar('✅ Rappels activés !\nMatin (8h30) et Soir (20h00)', Colors.green);
      } catch (e) {
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Erreur lors de l\'activation des rappels: $e', Colors.red);
      }
    } else {
      try {
        await notificationService.setNotificationsEnabled(false);
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Rappels désactivés', Colors.orange);
      } catch (e) {
        _showSnackBar('Erreur lors de la désactivation: $e', Colors.red);
      }
    }
  }

  /// Charge l'état des notifications depuis le stockage local
  Future<void> loadNotificationStatus() async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    final enabled = await notificationService.areNotificationsEnabled();
    
    if (enabled) {
      // Vérifier que les permissions sont toujours valides
      final hasPermissions = await notificationService.hasRequiredPermissions();
      final systemEnabled = await notificationService.areSystemNotificationsEnabled();
      
      if (hasPermissions && systemEnabled) {
        // Reprogrammer les rappels si nécessaire
        final pending = await notificationService.getPendingNotifications();
        if (pending.isEmpty) {
          await notificationService.scheduleAllReminders();
          await notificationService.scheduleNewMonthReminder();
        }
        setNotificationsEnabled(true);
      } else {
        // Permissions révoquées
        await notificationService.setNotificationsEnabled(false);
        setNotificationsEnabled(false);
      }
    } else {
      setNotificationsEnabled(false);
    }
    updateState();
  }

  /// Test des notifications
  Future<void> testNotification() async {
    try {
      final notificationService = NotificationService();
      final systemEnabled = await notificationService.areSystemNotificationsEnabled();
      
      if (!systemEnabled) {
        _showSnackBar('Les notifications ne sont pas activées au niveau système', Colors.orange);
        return;
      }

      await notificationService.showTestNotification();
      await notificationService.scheduleTestNotification(delaySeconds: 3);
      
      _showSnackBar('Tests lancés :\n• Notification immédiate\n• Notification dans 3 secondes', Colors.blue);
    } catch (e) {
      _showSnackBar('Erreur test notification: $e', Colors.red);
    }
  }

  // ===================================================================
  // =================== GESTION DES DONNÉES =========================
  // ===================================================================

  Future<void> loadSavedData() async {
    try {
      // Charger depuis Firestore
      final userData = await _firestoreService.loadUserData();

      if (userData != null) {
        setSalary(userData.salary);
        setCurrency(userData.currency);
        setBudget(userData.budget);
        setTransactions(userData.transactions);
        // Les notifications sont gérées localement maintenant
        await loadNotificationStatus();

        // Vérifier si un nouveau mois a commencé
        if (userData.isNewMonthStarted) {
          // Afficher un rappel pour clôturer le mois précédent
          _showNewMonthDialog(userData);
        }

        if (getSalary() > 0) {
          getSalaryController().text = getSalary().toString();
          calculateBudget();
        }

        updateFilteredTransactions();
        updateState();

        debugPrint('Données chargées depuis Firestore avec succès');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement depuis Firestore: $e');
      // Fallback vers SharedPreferences si Firestore échoue
      await _loadFromSharedPreferences();
    }
  }

  /// Affiche un dialogue pour informer l'utilisateur qu'un nouveau mois a commencé
  void _showNewMonthDialog(UserData userData) {
    final now = DateTime.now();
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 Nouveau mois !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue en ${months[now.month - 1]} ${now.year} !',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Voulez-vous clôturer ${months[userData.activeMonth - 1]} ${userData.activeYear} et commencer le nouveau mois ?',
            ),
            const SizedBox(height: 12),
            const Text(
              '• Vos catégories seront conservées\n• Les dépenses seront archivées\n• Vous pourrez entrer vos nouveaux revenus',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await closeCurrentMonth();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A9A9),
            ),
            child: const Text('Clôturer le mois', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Clôturer le mois actuel et passer au nouveau mois
  Future<void> closeCurrentMonth() async {
    try {
      final success = await _firestoreService.closeCurrentMonth();
      
      if (success) {
        // Recharger les données
        await loadSavedData();
        
        // Afficher une notification si activée
        final notificationService = NotificationService();
        await notificationService.showNewMonthNotification();
        
        _showSnackBar('✅ Mois clôturé ! Entrez vos revenus pour ce mois.', Colors.green);
      } else {
        _showSnackBar('Erreur lors de la clôture du mois', Colors.red);
      }
    } catch (e) {
      debugPrint('Erreur clôture mois: $e');
      _showSnackBar('Erreur lors de la clôture du mois', Colors.red);
    }
  }

  void updateFilteredTransactions() {
    final selectedMonth = getSelectedMonth();
    final transactions = getTransactions();
    final budget = getBudget();

    final filtered = transactions.where((t) =>
    t.date.year == selectedMonth.year &&
        t.date.month == selectedMonth.month
    ).toList();

    setFilteredTransactions(filtered);

    // Reset des dépenses
    budget.forEach((key, value) {
      budget[key]!['spent'] = 0.0;
    });

    // Recalcul des dépenses
    for (var transaction in filtered) {
      if (budget.containsKey(transaction.category)) {
        budget[transaction.category]!['spent'] =
            ((budget[transaction.category]!['spent'] as num?)?.toDouble() ?? 0.0) + transaction.amount;
      }
    }

    setBudget(budget);
  }

  Future<void> saveData() async {
    try {
      // Charger d'abord les données existantes pour conserver activeMonth/Year/History
      final existingData = await _firestoreService.loadUserData();
      final now = DateTime.now();
      
      final userData = UserData(
        userId: _firestoreService.currentUserId ?? '',
        salary: getSalary(),
        currency: getCurrency(),
        budget: getBudget(),
        transactions: getTransactions(),
        lastUpdated: now,
        financialGoals: existingData?.financialGoals ?? [],
        activeMonth: existingData?.activeMonth ?? now.month,
        activeYear: existingData?.activeYear ?? now.year,
        monthlyHistory: existingData?.monthlyHistory ?? [],
        isPremium: existingData?.isPremium ?? false,
        premiumExpiryDate: existingData?.premiumExpiryDate,
        pdfExportsUsed: existingData?.pdfExportsUsed ?? 0,
        chatbotUsesUsed: existingData?.chatbotUsesUsed ?? 0,
      );

      await _firestoreService.saveUserData(userData);
      debugPrint('Données sauvegardées dans Firestore avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde dans Firestore: $e');
      // Fallback vers SharedPreferences si Firestore échoue
      await _saveToSharedPreferences();
    }
  }

  // ===================================================================
  // =================== LOGIQUE BUDGET ET CALCULS ===================
  // ===================================================================

  void calculateBudget() async {
    final salaryController = getSalaryController();
    double inputSalary = double.tryParse(salaryController.text) ?? 0;

    if (inputSalary <= 0) {
      _showSnackBar('Veuillez entrer des revenus valides', Colors.red);
      return;
    }

    setSalary(inputSalary);
    final budget = getBudget();

    budget.forEach((key, value) {
      final percent = (value['percent'] as num?)?.toDouble() ?? 0.0;
      budget[key]!['amount'] = inputSalary * percent;
    });

    setBudget(budget);
    updateState();

    // Sauvegarde dans Firestore
    try {
      await _firestoreService.updateSalary(inputSalary);
      await _firestoreService.updateBudget(budget);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du budget: $e');
    }

    FocusScope.of(context).unfocus();
  }

  double getTotalBudgetPercentage() {
    final budget = getBudget();
    return budget.values.fold(0.0, (sum, item) => sum + ((item['percent'] as num?)?.toDouble() ?? 0.0));
  }

  String getSpendingRecommendation(String category) {
    final budget = getBudget();
    if (!budget.containsKey(category)) return "";
    double spent = (budget[category]!['spent'] as num?)?.toDouble() ?? 0.0;
    double allocated = (budget[category]!['amount'] as num?)?.toDouble() ?? 0.0;

    if (allocated <= 0) return "";
    double percentage = (spent / allocated) * 100;

    if (percentage > 100) {
      return "Budget dépassé. Essayez de réduire vos dépenses.";
    }
    if (percentage == 100) {
      return "Attention, vous avez atteint la limite de votre budget.";
    }
    if (percentage >= 95) {
      return "Attention, vous approchez de la limite de votre budget.";
    }
    return "";
  }

  // ===================================================================
  // =================== GESTION DES TRANSACTIONS ====================
  // ===================================================================

  void addTransaction(String category, double amount, String description) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    try {
      // Mise à jour locale immédiate
      final transactions = getTransactions();
      transactions.add(transaction);
      setTransactions(transactions);
      updateFilteredTransactions();
      updateState();

      // Sauvegarde dans Firestore
      await _firestoreService.addTransaction(transaction);

      // Vérifier si le budget de la catégorie est dépassé
      await _checkBudgetWarning(category);

      debugPrint('Transaction ajoutée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la transaction: $e');
      _showSnackBar('Erreur lors de l\'ajout de la transaction', Colors.red);
    }
  }

  void editTransaction(Transaction transaction, double newAmount, String newDescription) async {
    try {
      // Mise à jour locale immédiate
      final transactions = getTransactions();
      int index = transactions.indexWhere((t) => t.id == transaction.id);

      if (index != -1) {
        transactions[index] = Transaction(
          id: transaction.id,
          category: transaction.category,
          amount: newAmount,
          description: newDescription,
          date: transaction.date,
        );
      }

      setTransactions(transactions);
      updateFilteredTransactions();
      updateState();

      // Sauvegarde dans Firestore
      await _firestoreService.updateTransaction(transaction.id, newAmount, newDescription);

      debugPrint('Transaction modifiée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la modification de la transaction: $e');
      _showSnackBar('Erreur lors de la modification de la transaction', Colors.red);
    }
  }

  void deleteTransaction(Transaction transaction) async {
    try {
      // Mise à jour locale immédiate
      final transactions = getTransactions();
      transactions.removeWhere((t) => t.id == transaction.id);
      setTransactions(transactions);
      updateFilteredTransactions();
      updateState();

      // Suppression dans Firestore
      await _firestoreService.deleteTransaction(transaction.id);

      debugPrint('Transaction supprimée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la transaction: $e');
      _showSnackBar('Erreur lors de la suppression de la transaction', Colors.red);
    }
  }

  /// Vérifier si le budget d'une catégorie est dépassé et envoyer une notification
  Future<void> _checkBudgetWarning(String category) async {
    try {
      final categoryData = _budget[category];
      if (categoryData == null) return;

      final budgetAmount = (categoryData['amount'] as num?)?.toDouble() ?? 0.0;
      final spentAmount = (categoryData['spent'] as num?)?.toDouble() ?? 0.0;

      // Ne pas envoyer si pas de budget défini
      if (budgetAmount <= 0) return;

      final percentUsed = (spentAmount / budgetAmount) * 100;
      
      debugPrint('📊 Budget "$category": ${spentAmount.toStringAsFixed(0)}/${budgetAmount.toStringAsFixed(0)} (${percentUsed.toStringAsFixed(0)}%)');

      // Envoyer notification si >= 80%
      if (percentUsed >= 80) {
        await NotificationService().showBudgetWarningNotification(category, percentUsed);
        debugPrint('⚠️ Notification budget envoyée pour "$category" (${percentUsed.toStringAsFixed(0)}%)');
      }
    } catch (e) {
      debugPrint('Erreur vérification budget: $e');
    }
  }

  // ===================================================================
  // =================== MÉTHODES FALLBACK ============================
  // ===================================================================

  // Méthodes de fallback pour SharedPreferences (à conserver pour la compatibilité)
  Future<void> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setSalary(prefs.getDouble('salary') ?? 0);
    setCurrency(prefs.getString('currency') ?? 'XOF');

    String? savedBudget = prefs.getString('budget');
    if (savedBudget != null) {
      Map<String, dynamic> decodedBudget = jsonDecode(savedBudget);
      Map<String, Map<String, dynamic>> newBudget = {};
      decodedBudget.forEach((key, value) {
        newBudget[key] = {
          'percent': value['percent'],
          'amount': value['amount'],
          'icon': IconUtils.getIconFromCode(value['icon']),
          'color': Color(value['color']),
          'spent': value['spent'] ?? 0.0,
        };
      });
      setBudget(newBudget);
    }

    String? savedTransactions = prefs.getString('transactions');
    if (savedTransactions != null) {
      List<dynamic> decodedTransactions = jsonDecode(savedTransactions);
      setTransactions(decodedTransactions.map((item) => Transaction.fromJson(item)).toList());
      updateFilteredTransactions();
    }

    if (getSalary() > 0) {
      getSalaryController().text = getSalary().toString();
      calculateBudget();
    }

    updateState();
  }

  Future<void> _saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final salary = getSalary();
    final currency = getCurrency();
    final budget = getBudget();
    final transactions = getTransactions();

    await prefs.setDouble('salary', salary);
    await prefs.setString('currency', currency);

    Map<String, dynamic> encodableBudget = {};
    budget.forEach((key, value) {
      encodableBudget[key] = {
        'percent': value['percent'],
        'amount': value['amount'],
        'icon': (value['icon'] as IconData).codePoint,
        'color': (value['color'] as Color).value,
        'spent': value['spent'],
      };
    });
    await prefs.setString('budget', jsonEncode(encodableBudget));

    List<Map<String, dynamic>> encodableTransactions =
    transactions.map((t) => t.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(encodableTransactions));
  }

  // ===================================================================
  // =================== SYNCHRONISATION ==============================
  // ===================================================================

  // Nouvelle méthode pour forcer la synchronisation
  Future<void> forceSynchronization() async {
    try {
      await _firestoreService.forceSynchronization();
      await loadSavedData();
      _showSnackBar('Synchronisation terminée', Colors.green);
    } catch (e) {
      _showSnackBar('Erreur de synchronisation', Colors.red);
    }
  }

  // Vérifier le statut de connexion
  Future<bool> checkConnectionStatus() async {
    return await _firestoreService.isOnline();
  }

  // Initialiser les données utilisateur (première connexion)
  Future<void> initializeUserData() async {
    try {
      await _firestoreService.initializeUserData();
      await loadSavedData();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation: $e');
      _showSnackBar('Erreur lors de l\'initialisation des données', Colors.red);
    }
  }

  // Écouter les changements de données en temps réel
  Stream<UserData?> getUserDataStream() {
    return _firestoreService.userDataStream();
  }

  // Supprimer toutes les données utilisateur
  Future<void> deleteAllUserData() async {
    try {
      await _firestoreService.deleteUserData();
      _showSnackBar('Toutes les données ont été supprimées', Colors.green);
    } catch (e) {
      debugPrint('Erreur lors de la suppression des données: $e');
      _showSnackBar('Erreur lors de la suppression des données', Colors.red);
    }
  }
  // ===================================================================
  // =================== GESTION DES CATÉGORIES ======================
  // ===================================================================

  void addCategory(String name, double percent, IconData icon, Color color) async {
    if (name.isEmpty || percent <= 0) {
      _showSnackBar('Nom ou pourcentage invalide', Colors.red);
      return;
    }

    final budget = getBudget();
    if (budget.containsKey(name)) {
      _showSnackBar('Cette catégorie existe déjà', Colors.red);
      return;
    }

    double currentTotal = getTotalBudgetPercentage();
    if (currentTotal + (percent / 100) > 1.001) {
      _showSnackBar('Le total des pourcentages ne peut pas dépasser 100%.', Colors.red);
      return;
    }

    final salary = getSalary();
    budget[name] = {
      'percent': percent / 100,
      'amount': salary * (percent / 100),
      'icon': icon,
      'color': color,
      'spent': 0.0,
    };

    setBudget(budget);
    updateState();

    // Sauvegarde dans Firestore
    try {
      await _firestoreService.updateBudget(budget);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la catégorie: $e');
    }
  }

  void editCategory(String oldName, String newName, double percent, IconData icon, Color color) async {
    if (newName.isEmpty || percent <= 0) {
      _showSnackBar('Veuillez entrer un nom valide et un pourcentage supérieur à 0', Colors.red);
      return;
    }

    // Utiliser l'état local au lieu de recharger depuis Firestore
    final budget = getBudget();
    if (oldName != newName && budget.containsKey(newName)) {
      _showSnackBar('Cette catégorie existe déjà', Colors.red);
      return;
    }

    double currentTotal = getTotalBudgetPercentage() - ((budget[oldName]!['percent'] as num?)?.toDouble() ?? 0.0);
    if (currentTotal + percent / 100 > 1.0) {
      _showSnackBar('Le total des pourcentages ne peut pas dépasser 100%. Après modification: ${((currentTotal + percent / 100) * 100).toStringAsFixed(0)}%', Colors.red);
      return;
    }

    try {
      final salary = getSalary();
      final transactions = getTransactions();
      
      // Créer la catégorie mise à jour
      final updatedCategory = {
        'percent': percent / 100,
        'amount': salary * (percent / 100),
        'icon': icon,
        'color': color,
        'spent': budget[oldName]!['spent'],
      };

      // Mettre à jour les transactions si le nom de catégorie change
      List<Transaction> updatedTransactions = transactions;
      if (oldName != newName) {
        updatedTransactions = transactions.map((t) {
          if (t.category == oldName) {
            return Transaction(
              id: t.id,
              category: newName,
              amount: t.amount,
              description: t.description,
              date: t.date,
            );
          }
          return t;
        }).toList();

        budget.remove(oldName);
        budget[newName] = updatedCategory;
      } else {
        budget[oldName] = updatedCategory;
      }

      // Mettre à jour l'état local immédiatement
      setBudget(budget);
      setTransactions(updatedTransactions);
      updateFilteredTransactions();
      updateState();

      // Sauvegarder dans Firestore
      await _firestoreService.updateBudget(budget);
      if (oldName != newName) {
        // Sauvegarder aussi les transactions mises à jour
        await saveData();
      }
      debugPrint('Catégorie et transactions mises à jour avec succès');

    } catch (e) {
      debugPrint('Erreur lors de la modification de la catégorie: $e');
      _showSnackBar('Erreur lors de la modification sur le serveur', Colors.red);
    }
  }

  void deleteCategory(String name) async {
    final transactions = getTransactions();
    bool hasTransactions = transactions.any((t) => t.category == name);

    if (hasTransactions) {
      _showSnackBar('Impossible de supprimer une catégorie avec des transactions', Colors.red);
      return;
    }

    final budget = getBudget();
    budget.remove(name);
    setBudget(budget);
    updateState();

    // Sauvegarde dans Firestore
    try {
      await _firestoreService.updateBudget(budget);
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la catégorie: $e');
      _showSnackBar('Erreur lors de la suppression sur le serveur', Colors.red);
    }
  }

  // ===================================================================
  // =================== EXPORT ET RAPPORTS =========================
  // ===================================================================

  Future<void> exportTransactions() async {
    final selectedMonth = getSelectedMonth();
    final transactions = getTransactions();
    final currency = getCurrency();

    final monthTransactions = transactions.where((t) =>
    t.date.month == selectedMonth.month &&
        t.date.year == selectedMonth.year
    ).toList();

    if (monthTransactions.isEmpty) {
      _showSnackBar('Aucune transaction à exporter', Colors.orange);
      return;
    }

    final csvData = StringBuffer()
      ..writeln('Date,Catégorie,Description,Montant ($currency)');

    for (final t in monthTransactions) {
      csvData.writeln(
          '${t.date.day}/${t.date.month}/${t.date.year},'
              '${t.category},'
              '${t.description.replaceAll(',', ';')},'
              '${t.amount.toStringAsFixed(2)}'
      );
    }

    await Share.share(
      csvData.toString(),
      subject: 'Transactions_${DateFormat('yyyy-MM').format(selectedMonth)}.csv',
    );
  }


  Future<void> exportTransactionsToPDF() async {
    // Couleurs personnalisées
    final pdfBlue = PdfColor.fromInt(Colors.blue[700]!.value);
    final pdfLightBlue = PdfColor.fromInt(Colors.blue[100]!.value);
    final pdfWhite = PdfColors.white;
    final pdfBlack = PdfColors.black;
    final pdfGrey = PdfColors.grey;
    final pdfGreen = PdfColor.fromInt(Colors.green[700]!.value);
    final pdfRed = PdfColor.fromInt(Colors.red[700]!.value);

    final selectedMonth = getSelectedMonth();
    final transactions = getTransactions();
    final salary = getSalary();
    final currency = getCurrency();
    final budget = getBudget();

    // Récupérer les informations utilisateur
    final user = AuthService().currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'Utilisateur';

    final monthTransactions = transactions.where((t) =>
    t.date.month == selectedMonth.month &&
        t.date.year == selectedMonth.year
    ).toList();

    if (monthTransactions.isEmpty) {
      _showSnackBar('Aucune transaction à exporter', Colors.orange);
      return;
    }

    // Calculs financiers
    final totalDepenses = monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalRestant = salary - totalDepenses;
    final depensesParCategorie = calculateExpensesByCategory(monthTransactions);
    final ratioDepenses = salary > 0 ? (totalDepenses / salary) : 0;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 1.5 * PdfPageFormat.cm,
          marginBottom: 1.5 * PdfPageFormat.cm,
          marginLeft: 1.0 * PdfPageFormat.cm,
          marginRight: 1.0 * PdfPageFormat.cm,
        ),
        build: (pw.Context context) => [
          // En-tête stylé avec nom d'utilisateur
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: pdfBlue,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'SmartSpend',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfWhite,
                  ),
                ),

                pw.SizedBox(height: 8),
                pw.Text(
                  'Relevé Financier de : ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: pdfWhite,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Informations de génération avec nom utilisateur
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Généré le ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: pdfGrey,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          // Section Résumé Financier
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: pdfLightBlue,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: pdfBlue, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SITUATION FINANCIÈRE',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfBlue,
                      ),
                    ),
                    // 🆕 Icône utilisateur stylisée avec alternative visuelle
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFE8F4FD), // Bleu très clair
                        borderRadius: pw.BorderRadius.circular(15),
                        border: pw.Border.all(color: PdfColor.fromInt(0xFFB3D9F2), width: 1.5),
                      ),
                      child: pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          // Alternative visuelle à l'icône utilisateur
                          pw.Container(
                            width: 12,
                            height: 12,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: pdfBlue,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  color: pdfWhite,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text(
                            userName,
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: pdfBlue,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                _infoRow('Revenus mensuels:', '${salary.toStringAsFixed(2)} $currency', bold: true),
                pw.Divider(color: pdfBlue, height: 20),
                _infoRow('Total des dépenses:', '${totalDepenses.toStringAsFixed(2)} $currency',
                    bold: true, colorValue: pdfRed),
                pw.SizedBox(height: 8),
                _infoRow('Solde restant:', '${totalRestant.toStringAsFixed(2)} $currency',
                    bold: true, colorValue: totalRestant >= 0 ? pdfGreen : pdfRed),
                pw.SizedBox(height: 16),
                pw.LinearProgressIndicator(
                  value: ratioDepenses.clamp(0.0, 1.0).toDouble(),
                  minHeight: 10,
                  backgroundColor: pdfWhite,
                  valueColor: ratioDepenses > 0.9
                      ? pdfRed
                      : ratioDepenses > 0.7
                      ? PdfColor.fromInt(Colors.orange[700]!.value)
                      : pdfGreen,
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${(ratioDepenses * 100).toStringAsFixed(1)}% de vos revenus dépensés',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Tableau des transactions
          pw.Text(
            'DÉTAIL DES TRANSACTIONS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: pdfBlue,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            border: null,
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(
              color: pdfBlue,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            headerHeight: 25,
            cellHeight: 20,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
            },
            headerStyle: pw.TextStyle(
              color: pdfWhite,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(
              fontSize: 10,
              color: pdfBlack,
            ),
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: pdfGrey,
                  width: 0.5,
                ),
              ),
            ),
            headers: ['Date', 'Catégorie', 'Description', 'Montant ($currency)'],
            data: monthTransactions.map((t) {
              final categoryData = budget[t.category];
              final color = categoryData?['color'] != null
                  ? PdfColor.fromInt((categoryData!['color'] as Color).value)
                  : pdfBlack;

              return [
                DateFormat('dd/MM/yyyy', 'fr_FR').format(t.date),
                pw.Text(t.category, style: pw.TextStyle(color: color)),
                t.description,
                pw.Text('${t.amount.toStringAsFixed(2)}', style: pw.TextStyle(color: color)),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 30),

          // Analyse par catégorie
          pw.Text(
            'ANALYSE PAR CATÉGORIE',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: pdfBlue,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildCategoryTable(depensesParCategorie, budget, currency, pdfLightBlue, pdfGrey, pdfGreen, pdfRed),

          pw.SizedBox(height: 30),

          // Conseils personnalisés avec mention du nom
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(Colors.grey[50]!.value),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: pdfBlue, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'CONSEILS SMARTSPEND',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfBlue,
                      ),
                    ),
                    // 🆕 Badge personnalisé pour l'utilisateur
                    pw.Text(
                      'Pour $userName',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColor.fromInt(0xFF7A9CC6), // Bleu moyen
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                ...generateDetailedAdvice(totalDepenses, totalRestant, depensesParCategorie, userName).map((advice) =>
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Alternative visuelle à la puce
                          pw.Container(
                            width: 8,
                            height: 8,
                            margin: const pw.EdgeInsets.only(top: 6, right: 8),
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: pdfBlue,
                            ),
                          ),
                          pw.Expanded(child: pw.Text(advice)),
                        ],
                      ),
                    )
                ).toList(),
              ],
            ),
          ),

          // 🆕 Pied de page avec informations utilisateur
          pw.SizedBox(height: 40),
          pw.Divider(color: pdfGrey),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'SmartSpend - Gestion financière intelligente',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: pdfGrey,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                'Rapport financier personnel de $userName',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: pdfBlue,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    // 🆕 Nom de fichier personnalisé avec nom d'utilisateur
    final fileName = 'SmartSpend_${userName.replaceAll(' ', '_')}_${DateFormat('yyyy-MM', 'fr_FR').format(selectedMonth)}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareFiles(
      [file.path],
      text: 'Rapport financier SmartSpend de $userName - ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}',
      subject: fileName,
    );
  }

// 🆕 Méthode generateDetailedAdvice modifiée pour inclure le nom d'utilisateur
  List<String> generateDetailedAdvice(double totalSpent, double remaining, Map<String, double> byCategory, String userName) {
    final advice = <String>[];
    final salary = getSalary();

    if (remaining < 0) {
      advice.add('$userName, attention ! Vous avez dépassé votre budget ce mois-ci. Essayez de réduire vos dépenses le mois prochain.');
    } else if (remaining > salary * 0.3) {
      advice.add('Excellent travail, $userName ! Vous avez économisé plus de 30% de vos revenus ce mois-ci.');
    } else if (remaining > 0) {
      advice.add('$userName, vous êtes dans les clous avec ${remaining.toStringAsFixed(2)} ${getCurrency()} restants ce mois-ci.');
    }

    final maxCategory = byCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (maxCategory.value > totalSpent * 0.4) {
      advice.add('$userName, la catégorie "${maxCategory.key}" représente une part importante (${(maxCategory.value/totalSpent*100).toStringAsFixed(1)}%) de vos dépenses. Pensez à diversifier.');
    }

    if (byCategory.containsKey('Épargne') && byCategory['Épargne']! < salary * 0.1) {
      advice.add('$userName, votre épargne est inférieure à 10% de vos revenus. Essayez d\'augmenter cette part progressivement.');
    }

    if (advice.isEmpty) {
      advice.add('$userName, votre gestion financière est équilibrée ce mois-ci. Continuez ainsi !');
    }

    return advice;
  }

// Méthodes helper pour le PDF
  pw.Widget _infoRow(String label, String value, {bool bold = false, PdfColor? colorValue}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: colorValue,
        )),
      ],
    );
  }

  pw.Widget _buildCategoryTable(Map<String, double> depenses, Map budget, String currency,
      PdfColor headerColor, PdfColor borderColor, PdfColor green, PdfColor red) {
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: ['Catégorie', 'Montant', 'Budget', 'Écart'].map((text) =>
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              )
          ).toList(),
        ),
        ...depenses.entries.map((e) {
          final budgetAmount = (budget[e.key]?['amount'] as double?) ?? 0;
          final difference = budgetAmount - e.value;
          final isOverBudget = difference < 0;

          return pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(e.key)),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${e.value.toStringAsFixed(2)} $currency')),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${budgetAmount.toStringAsFixed(2)} $currency')),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${difference.toStringAsFixed(2)} $currency',
                  style: pw.TextStyle(color: isOverBudget ? red : green),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // ===================================================================
  // =================== UTILITAIRES =================================
  // ===================================================================

  void showMonthPicker() {
    showDatePicker(
      context: context,
      initialDate: getSelectedMonth(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    ).then((date) {
      if (date != null) {
        setSelectedMonth(DateTime(date.year, date.month));
        updateFilteredTransactions();
        updateState();
      }
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Méthodes d'aide pour les calculs
  Map<String, double> calculateExpensesByCategory(List<Transaction> transactions) {
    final Map<String, double> result = {};
    for (final t in transactions) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }


  // ===================================================================
  // =================== GESTION DES OBJECTIFS FINANCIERS =============
  // ===================================================================

  Future<void> addFinancialGoal(FinancialGoal goal) async {
    try {
      await _firestoreService.addFinancialGoal(goal);
      _showSnackBar('Objectif financier créé avec succès !', Colors.green);
      updateState();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de l\'objectif: $e');
      _showSnackBar('Erreur lors de la création de l\'objectif', Colors.red);
    }
  }

  Future<void> updateFinancialGoal(FinancialGoal goal) async {
    try {
      await _firestoreService.updateFinancialGoal(goal);
      _showSnackBar('Objectif modifié avec succès !', Colors.green);
      updateState();
    } catch (e) {
      debugPrint('Erreur lors de la modification de l\'objectif: $e');
      _showSnackBar('Erreur lors de la modification', Colors.red);
    }
  }

  Future<void> deleteFinancialGoal(String goalId) async {
    try {
      await _firestoreService.deleteFinancialGoal(goalId);
      _showSnackBar('Objectif supprimé', Colors.orange);
      updateState();
    } catch (e) {
      debugPrint('Erreur lors de la suppression de l\'objectif: $e');
      _showSnackBar('Erreur lors de la suppression', Colors.red);
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount) async {
    try {
      await _firestoreService.updateGoalProgress(goalId, amount);

      // Vérifier si l'objectif est maintenant atteint
      final userData = await _firestoreService.loadUserData();
      if (userData != null) {
        final goal = userData.financialGoals.firstWhere(
              (g) => g.id == goalId,
          orElse: () => throw 'Objectif non trouvé',
        );

        if (goal.currentAmount >= goal.targetAmount) {
          _showSnackBar('🎉 Félicitations ! Objectif "${goal.name}" atteint !', Colors.green);

          // Envoyer une notification
          await NotificationService().showGoalAchievedNotification(goal.name);
          debugPrint('🎯 Notification objectif atteint envoyée: ${goal.name}');

          // Optionnel : marquer automatiquement comme terminé
          await _firestoreService.completeFinancialGoal(goalId);
        } else {
          _showSnackBar('Montant ajouté avec succès !', Colors.green);
        }
      }

      updateState();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout d\'argent: $e');
      _showSnackBar('Erreur lors de l\'ajout', Colors.red);
    }
  }

  Future<void> completeFinancialGoal(String goalId) async {
    try {
      await _firestoreService.completeFinancialGoal(goalId);
      _showSnackBar('🎉 Objectif marqué comme terminé !', Colors.green);
      updateState();
    } catch (e) {
      debugPrint('Erreur lors de la finalisation: $e');
      _showSnackBar('Erreur lors de la finalisation', Colors.red);
    }
  }

  // Méthode pour suggérer l'épargne automatique vers les objectifs
  Future<void> suggestGoalSaving(double availableMoney) async {
    try {
      final userData = await _firestoreService.loadUserData();
      if (userData == null) return;

      final activeGoals = userData.financialGoals
          .where((g) => !g.isCompleted && !g.isOverdue)
          .toList();

      if (activeGoals.isEmpty) return;

      // Trier par priorité (échéance proche)
      activeGoals.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

      final urgentGoals = activeGoals.where((g) => g.isNearDeadline).toList();

      if (urgentGoals.isNotEmpty && availableMoney > 0) {
        final goal = urgentGoals.first;
        final suggestedAmount = (availableMoney * 0.3).clamp(0, goal.remainingAmount);

        if (suggestedAmount > 1000) {
          _showGoalSuggestionDialog(goal, suggestedAmount.toDouble(), userData.currency);
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la suggestion d\'épargne: $e');
    }
  }
  void _showGoalSuggestionDialog(FinancialGoal goal, double suggestedAmount, String currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Suggestion d\'épargne'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre objectif "${goal.name}" arrive bientôt à échéance !',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
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
                  Text('Progression: ${goal.progressPercentage.toStringAsFixed(1)}%'),
                  Text('Restant: ${goal.remainingAmount.toStringAsFixed(0)} $currency'),
                  Text('Échéance: ${DateFormat('dd/MM/yyyy').format(goal.targetDate)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Voulez-vous épargner ${suggestedAmount.toStringAsFixed(0)} $currency pour cet objectif ?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              addMoneyToGoal(goal.id, suggestedAmount);
            },
            child: const Text('Épargner'),
          ),
        ],
      ),
    );
  }

  // Méthode pour calculer les statistiques des objectifs
  Map<String, dynamic> getGoalsStatistics() {
    // Cette méthode peut être utilisée pour afficher des stats dans l'interface
    // Elle sera implémentée en fonction des besoins spécifiques
    return {
      'totalGoals': 0,
      'completedGoals': 0,
      'totalTargetAmount': 0.0,
      'totalSavedAmount': 0.0,
      'overallProgress': 0.0,
    };
  }

  // Vérifier les objectifs proches de l'échéance (pour les notifications)
  Future<List<FinancialGoal>> checkUpcomingDeadlines() async {
    try {
      final userData = await _firestoreService.loadUserData();
      if (userData == null) return [];

      final upcomingGoals = userData.financialGoals
          .where((g) => !g.isCompleted && g.isNearDeadline)
          .toList();

      return upcomingGoals;
    } catch (e) {
      debugPrint('Erreur lors de la vérification des échéances: $e');
      return [];
    }
  }

  // ===================================================================
  // =================== NOUVELLES MÉTHODES POUR LE PROVIDER ==========
  // ===================================================================

  /// Retourne le symbole de la devise
  String getCurrencySymbol() {
    final symbols = {
      'XAF': 'FCFA ',
      'XOF': 'FCFA ',
      'EUR': '€',
      'USD': '\$',
      'GBP': '£',
      'NGN': '₦',
      'GHS': 'GH₵',
      'CAD': 'CA\$',
      'AUD': 'AU\$',
      'JPY': '¥',
      'CNY': '¥',
    };
    return symbols[_currency] ?? _currency;
  }

  /// Incrémente le compteur d'utilisations du chatbot
  Future<void> incrementChatbotUses() async {
    if (!_isPremium) {
      _chatbotUsesUsed++;
      notifyListeners();
      await _firestoreService.incrementChatbotUses();
    }
  }

  /// Incrémente le compteur d'exports PDF
  Future<void> incrementPdfExports() async {
    if (!_isPremium) {
      _pdfExportsUsed++;
      notifyListeners();
      await _firestoreService.incrementPDFExports();
    }
  }

  /// Ouvre l'écran d'achat Premium
  void openPremiumPurchase(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('⭐', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('SmartSpend Premium'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Débloquez toutes les fonctionnalités :'),
            SizedBox(height: 12),
            Text('✓ Exports PDF illimités'),
            Text('✓ Assistant IA illimité'),
            Text('✓ Analyses avancées'),
            Text('✓ Pas de publicités'),
            SizedBox(height: 16),
            Text('2,99€ / mois ou 24,99€ / an',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Intégrer l'achat in-app
              _showSnackBar('Achat Premium bientôt disponible', Colors.blue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black87,
            ),
            child: const Text('S\'abonner'),
          ),
        ],
      ),
    );
  }

  /// Réinitialise toutes les données de l'utilisateur
  Future<void> resetAllData() async {
    try {
      _budget = {
        'Loyer': {'percentage': 30, 'amount': 0.0, 'icon': Icons.home_work_outlined, 'color': const Color(0xFF6366F1), 'spent': 0.0},
        'Transport': {'percentage': 10, 'amount': 0.0, 'icon': Icons.directions_bus_filled_outlined, 'color': const Color(0xFF3B82F6), 'spent': 0.0},
        'Électricité/Eau': {'percentage': 7, 'amount': 0.0, 'icon': Icons.lightbulb_outline, 'color': const Color(0xFFF59E0B), 'spent': 0.0},
        'Internet': {'percentage': 5, 'amount': 0.0, 'icon': Icons.wifi, 'color': const Color(0xFF8B5CF6), 'spent': 0.0},
        'Nourriture': {'percentage': 15, 'amount': 0.0, 'icon': Icons.restaurant_menu_outlined, 'color': const Color(0xFFEF4444), 'spent': 0.0},
        'Loisirs': {'percentage': 8, 'amount': 0.0, 'icon': Icons.sports_esports_outlined, 'color': const Color(0xFFEC4899), 'spent': 0.0},
        'Épargne': {'percentage': 25, 'amount': 0.0, 'icon': Icons.savings_outlined, 'color': const Color(0xFF10B981), 'spent': 0.0},
      };
      _salary = 0;
      _transactions = [];
      _filteredTransactions = [];
      _financialGoals = [];
      _monthlyHistory = [];
      _salaryController.clear();
      _activeMonth = DateTime.now().month;
      _activeYear = DateTime.now().year;

      await saveData();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur reset: $e');
    }
  }

  /// Export vers PDF (simplifié pour le nouveau design)
  Future<void> exportToPDF(BuildContext ctx) async {
    if (!_isPremium && _pdfExportsUsed >= 3) {
      showDialog(
        context: ctx,
        builder: (context) => AlertDialog(
          title: const Text('Limite atteinte'),
          content: const Text(
            'Vous avez utilisé vos 3 exports gratuits. Passez à Premium pour des exports illimités.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openPremiumPurchase(ctx);
              },
              child: const Text('Voir Premium'),
            ),
          ],
        ),
      );
      return;
    }

    await exportTransactionsToPDF();
    if (!_isPremium) {
      await incrementPdfExports();
    }
  }
}