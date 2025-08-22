import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'models/transaction.dart';
import 'notification_service.dart';
import 'firestore_service.dart';
import 'models/user_data.dart';


class BudgetLogic {
  final BuildContext context;
  final VoidCallback updateState;
  final FirestoreService _firestoreService = FirestoreService();

  // Getters et setters pour accéder aux variables d'état
  final Map<String, Map<String, dynamic>> Function() getBudget;
  final Function(Map<String, Map<String, dynamic>>) setBudget;
  final double Function() getSalary;
  final Function(double) setSalary;
  final String Function() getCurrency;
  final Function(String) setCurrency;
  final List<Transaction> Function() getTransactions;
  final Function(List<Transaction>) setTransactions;
  final List<Transaction> Function() getFilteredTransactions;
  final Function(List<Transaction>) setFilteredTransactions;
  final DateTime Function() getSelectedMonth;
  final Function(DateTime) setSelectedMonth;
  final bool Function() getNotificationsEnabled;
  final Function(bool) setNotificationsEnabled;
  final TextEditingController Function() getSalaryController;

  BudgetLogic({
    required this.context,
    required this.updateState,
    required this.getBudget,
    required this.setBudget,
    required this.getSalary,
    required this.setSalary,
    required this.getCurrency,
    required this.setCurrency,
    required this.getTransactions,
    required this.setTransactions,
    required this.getFilteredTransactions,
    required this.setFilteredTransactions,
    required this.getSelectedMonth,
    required this.setSelectedMonth,
    required this.getNotificationsEnabled,
    required this.setNotificationsEnabled,
    required this.getSalaryController,
  });

  // ===================================================================
  // ===================== GESTION DES NOTIFICATIONS ==================
  // ===================================================================

  Future<void> toggleDailyReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (enabled) {
      var scheduleStatus = await Permission.scheduleExactAlarm.status;
      var notificationStatus = await Permission.notification.status;
      var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

      print('Statut permissions:');
      print('- Alarme exacte: $scheduleStatus');
      print('- Notifications: $notificationStatus');
      print('- Optimisation batterie: $batteryStatus');

      if (notificationStatus.isDenied) {
        notificationStatus = await Permission.notification.request();
        if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
          setNotificationsEnabled(false);
          updateState();
          _showSnackBar('Permission de notification refusée. Activez-la dans les paramètres Android.', Colors.red);
          return;
        }
      }

      bool systemEnabled = await NotificationService().areNotificationsEnabled();
      if (!systemEnabled) {
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Les notifications sont désactivées dans les paramètres Android pour cette app', Colors.red);
        return;
      }

      if (scheduleStatus.isDenied) {
        scheduleStatus = await Permission.scheduleExactAlarm.request();
        if (scheduleStatus.isDenied || scheduleStatus.isPermanentlyDenied) {
          setNotificationsEnabled(false);
          updateState();
          _showSnackBar('Permission d\'alarme exacte refusée. Activez "Applications autorisées" dans les paramètres système.', Colors.red);
          return;
        }
      }

      if (batteryStatus.isDenied) {
        _showSnackBar('Pour des rappels fiables, désactivez l\'optimisation de batterie pour SmartSpend', Colors.orange);
      }

      try {
        await NotificationService().scheduleDailyReminder();
        await prefs.setBool('daily_reminders', true);
        setNotificationsEnabled(true);
        updateState();
        _showSnackBar('✅ Rappels quotidiens activés!\nVous recevrez un rappel le soir.', Colors.green);
      } catch (e) {
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Erreur lors de l\'activation des rappels: $e', Colors.red);
      }
    } else {
      try {
        await NotificationService().cancelAllNotifications();
        await prefs.setBool('daily_reminders', false);
        setNotificationsEnabled(false);
        updateState();
        _showSnackBar('Rappels quotidiens désactivés', Colors.orange);
      } catch (e) {
        _showSnackBar('Erreur lors de la désactivation: $e', Colors.red);
      }
    }
  }

  Future<void> loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSetting = prefs.getBool('daily_reminders') ?? false;

    if (savedSetting) {
      var scheduleStatus = await Permission.scheduleExactAlarm.status;
      var notificationStatus = await Permission.notification.status;
      bool systemEnabled = await NotificationService().areNotificationsEnabled();

      if (scheduleStatus.isGranted && notificationStatus.isGranted && systemEnabled) {
        final pending = await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
        bool hasScheduledReminder = pending.any((n) => n.id == 0);

        if (!hasScheduledReminder) {
          try {
            await NotificationService().scheduleDailyReminder();
            print('Rappel quotidien reprogrammé');
          } catch (e) {
            print('Erreur reprogrammation: $e');
            await prefs.setBool('daily_reminders', false);
            setNotificationsEnabled(false);
            updateState();
            return;
          }
        }

        setNotificationsEnabled(true);
        updateState();
        print('Rappels quotidiens chargés et actifs');
      } else {
        print('Permissions révoquées: alarme=$scheduleStatus, notif=$notificationStatus, système=$systemEnabled');
        await prefs.setBool('daily_reminders', false);
        setNotificationsEnabled(false);
        updateState();
      }
    } else {
      setNotificationsEnabled(false);
      updateState();
    }
  }

  Future<void> testNotification() async {
    try {
      bool enabled = await NotificationService().areNotificationsEnabled();
      if (!enabled) {
        _showSnackBar('Les notifications ne sont pas activées au niveau système', Colors.orange);
        return;
      }

      await NotificationService().debugNotifications();
      await NotificationService().showImmediateNotification();
      await NotificationService().scheduleInstantReminder();

      _showSnackBar('Tests de notification lancés:\n• Immédiate\n• Dans 3 secondes\nVérifiez la barre de notification!', Colors.blue);
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
        setNotificationsEnabled(userData.notificationsEnabled);

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
            (budget[transaction.category]!['spent'] as double) + transaction.amount;
      }
    }

    setBudget(budget);
  }

  Future<void> saveData() async {
    try {
      final userData = UserData(
        userId: _firestoreService.currentUserId ?? '',
        salary: getSalary(),
        currency: getCurrency(),
        budget: getBudget(),
        transactions: getTransactions(),
        notificationsEnabled: getNotificationsEnabled(),
        lastUpdated: DateTime.now(),
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
      _showSnackBar('Veuillez entrer un salaire valide', Colors.red);
      return;
    }

    setSalary(inputSalary);
    final budget = getBudget();

    budget.forEach((key, value) {
      budget[key]!['amount'] = inputSalary * value['percent'];
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
    return budget.values.fold(0.0, (sum, item) => sum + (item['percent'] as double));
  }

  String getSpendingRecommendation(String category) {
    final budget = getBudget();
    double spent = budget[category]!['spent'] as double;
    double allocated = budget[category]!['amount'] as double;

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
          'icon': IconData(value['icon'], fontFamily: 'MaterialIcons'),
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

    final budget = getBudget();
    if (oldName != newName && budget.containsKey(newName)) {
      _showSnackBar('Cette catégorie existe déjà', Colors.red);
      return;
    }

    double currentTotal = getTotalBudgetPercentage() - (budget[oldName]!['percent'] as double);
    if (currentTotal + percent / 100 > 1.0) {
      _showSnackBar('Le total des pourcentages ne peut pas dépasser 100%. Après modification: ${((currentTotal + percent / 100) * 100).toStringAsFixed(0)}%', Colors.red);
      return;
    }

    try {
      // 1. Charger les données utilisateur depuis Firestore
      final userData = await _firestoreService.loadUserData();
      if (userData == null) return;

      // 2. Modifier le budget et les transactions dans l'objet UserData
      final updatedBudget = Map<String, dynamic>.from(userData.budget);
      final salary = userData.salary;
      final updatedCategory = {
        'percent': percent / 100,
        'amount': salary * (percent / 100),
        'icon': icon,
        'color': color,
        'spent': updatedBudget[oldName]!['spent'],
      };

      List<Transaction> updatedTransactions = userData.transactions;
      if (oldName != newName) {
        updatedTransactions = userData.transactions.map((t) {
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

        updatedBudget.remove(oldName);
        updatedBudget[newName] = updatedCategory;

      } else {
        updatedBudget[oldName] = updatedCategory;
      }

      // 3. Sauvegarder l'objet UserData complet
      final updatedUserData = userData.copyWith(
        budget: updatedBudget.cast<String, Map<String, dynamic>>(),
        transactions: updatedTransactions,
      );

      await _firestoreService.saveUserData(updatedUserData);
      debugPrint('Catégorie et transactions mises à jour avec succès sur Firestore');

      // Mettre à jour l'état local après la sauvegarde réussie
      setBudget(updatedBudget.cast<String, Map<String, dynamic>>());
      setTransactions(updatedTransactions);
      updateFilteredTransactions();
      updateState();

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
          // En-tête stylé
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
                  'Relevé Financier - ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: pdfWhite,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Informations de génération
          pw.Text(
            'Généré le ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 10,
              color: pdfGrey,
            ),
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
                pw.Text(
                  'VOTRE SITUATION FINANCIÈRE',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfBlue,
                  ),
                ),
                pw.SizedBox(height: 16),
                _infoRow('Salaire mensuel:', '${salary.toStringAsFixed(2)} $currency', bold: true),
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
                  '${(ratioDepenses * 100).toStringAsFixed(1)}% de votre salaire dépensé',
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

          // Conseils personnalisés
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
                pw.Text(
                  'CONSEILS SMARTSPEND',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfBlue,
                  ),
                ),
                pw.SizedBox(height: 12),
                ...generateDetailedAdvice(totalDepenses, totalRestant, depensesParCategorie).map((advice) =>
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('| ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Expanded(child: pw.Text(advice)),
                        ],
                      ),
                    )
                ).toList(),
              ],
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'SmartSpend_Rapport_${DateFormat('yyyy-MM', 'fr_FR').format(selectedMonth)}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareFiles(
      [file.path],
      text: 'Votre rapport financier SmartSpend - ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}',
      subject: fileName,
    );
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

  List<String> generateDetailedAdvice(double totalSpent, double remaining, Map<String, double> byCategory) {
    final advice = <String>[];
    final salary = getSalary();

    if (remaining < 0) {
      advice.add('Attention! Vous avez dépassé votre budget ce mois-ci. Essayez de réduire vos dépenses le mois prochain.');
    } else if (remaining > salary * 0.3) {
      advice.add('Excellent! Vous avez économisé plus de 30% de votre salaire ce mois-ci.');
    } else if (remaining > 0) {
      advice.add('Vous êtes dans les clous avec ${remaining.toStringAsFixed(2)} ${getCurrency()} restants ce mois-ci.');
    }

    final maxCategory = byCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (maxCategory.value > totalSpent * 0.4) {
      advice.add('La catégorie "${maxCategory.key}" représente une part importante (${(maxCategory.value/totalSpent*100).toStringAsFixed(1)}%) de vos dépenses. Pensez à diversifier.');
    }

    if (byCategory.containsKey('Épargne') && byCategory['Épargne']! < salary * 0.1) {
      advice.add('Votre épargne est inférieure à 10% de votre salaire. Essayez d\'augmenter cette part progressivement.');
    }

    if (advice.isEmpty) {
      advice.add('Votre gestion financière est équilibrée ce mois-ci. Continuez ainsi!');
    }

    return advice;
  }
}