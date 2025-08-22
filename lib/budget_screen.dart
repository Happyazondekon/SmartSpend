import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartspend/screens/financial_goals_screen.dart';
import 'package:smartspend/screens/profile_screen.dart';
import 'models/transaction.dart';
import 'notification_service.dart';
import 'theme.dart';
import 'faq_chatbot.dart';
import '../services/auth_service.dart';
import 'theme_provider.dart';

// Nouveaux imports pour les fichiers séparés
import 'budget_logic.dart';
import 'budget_widgets.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {

  // === CONTRÔLEURS ET VARIABLES D'ÉTAT ===
  final TextEditingController _salaryController = TextEditingController();
  late TabController _tabController;
  double salary = 0;
  String currency = 'XOF';
  List<String> currencies = ['XOF', 'USD', 'EUR', 'GBP', 'CAD'];
  List<Transaction> transactions = [];
  bool _notificationsEnabled = false;
  final ThemeProvider _themeProvider = ThemeProvider();

  // Filtre par mois
  DateTime selectedMonth = DateTime.now();
  List<Transaction> filteredTransactions = [];

  // Listes pour les sélecteurs de dialogue
  final List<IconData> availableIcons = [
    Icons.home_work_outlined, Icons.directions_bus_outlined, Icons.lightbulb_outline,
    Icons.wifi, Icons.restaurant_menu_outlined, Icons.sports_esports_outlined,
    Icons.savings_outlined, Icons.shopping_cart_outlined, Icons.medical_services_outlined,
    Icons.school_outlined, Icons.pets_outlined, Icons.receipt_long_outlined,
    Icons.phone_android_outlined, Icons.flight_takeoff_outlined, Icons.movie_outlined
  ];

  final List<Color> availableColors = [
    Color(0xFF00A9A9), Color(0xFF4CAF50), Color(0xFFFFC107), Color(0xFF673AB7),
    Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF00796B), Color(0xFF795548),
    Color(0xFF2196F3), Color(0xFFFF5722), Color(0xFF607D8B), Color(0xFF4527A0)
  ];

  Map<String, Map<String, dynamic>> budget = {
    'Loyer': {'percent': 0.30, 'amount': 0.0, 'icon': Icons.home_work_outlined, 'color': Color(0xFF00A9A9), 'spent': 0.0},
    'Transport': {'percent': 0.10, 'amount': 0.0, 'icon': Icons.directions_bus_filled_outlined, 'color': Color(0xFF4CAF50), 'spent': 0.0},
    'Électricité/Eau': {'percent': 0.07, 'amount': 0.0, 'icon': Icons.lightbulb_outline, 'color': Color(0xFFFFC107), 'spent': 0.0},
    'Internet': {'percent': 0.05, 'amount': 0.0, 'icon': Icons.wifi, 'color': Color(0xFF673AB7), 'spent': 0.0},
    'Nourriture': {'percent': 0.15, 'amount': 0.0, 'icon': Icons.restaurant_menu_outlined, 'color': Color(0xFFE91E63), 'spent': 0.0},
    'Loisirs': {'percent': 0.08, 'amount': 0.0, 'icon': Icons.sports_esports_outlined, 'color': Color(0xFF9C27B0), 'spent': 0.0},
    'Épargne': {'percent': 0.25, 'amount': 0.0, 'icon': Icons.savings_outlined, 'color': Color(0xFF00796B), 'spent': 0.0},
  };

  // Instance de la logique métier
  late BudgetLogic _budgetLogic;
  late BudgetWidgets _budgetWidgets;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialiser la logique métier
    _budgetLogic = BudgetLogic(
      context: context,
      updateState: _updateState,
      getBudget: () => budget,
      setBudget: (newBudget) => budget = newBudget,
      getSalary: () => salary,
      setSalary: (newSalary) => salary = newSalary,
      getCurrency: () => currency,
      setCurrency: (newCurrency) => currency = newCurrency,
      getTransactions: () => transactions,
      setTransactions: (newTransactions) => transactions = newTransactions,
      getFilteredTransactions: () => filteredTransactions,
      setFilteredTransactions: (filtered) => filteredTransactions = filtered,
      getSelectedMonth: () => selectedMonth,
      setSelectedMonth: (month) => selectedMonth = month,
      getNotificationsEnabled: () => _notificationsEnabled,
      setNotificationsEnabled: (enabled) => _notificationsEnabled = enabled,
      getSalaryController: () => _salaryController,
    );

    // Initialiser les widgets
    _budgetWidgets = BudgetWidgets(
      context: context,
      budgetLogic: _budgetLogic,
      availableIcons: availableIcons,
      availableColors: availableColors,
    );

    _budgetLogic.loadSavedData();
    _budgetLogic.loadNotificationStatus();
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _salaryController.dispose();
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartSpend'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: AuthService().currentUser?.photoURL != null
                  ? NetworkImage(AuthService().currentUser!.photoURL!)
                  : null,
              child: AuthService().currentUser?.photoURL == null
                  ? Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              )
                  : null,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  maintainState: true,
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              ThemeProvider().isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => ThemeProvider().toggleTheme(!ThemeProvider().isDarkMode),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text('Budget', style: TextStyle(fontSize: 12))),
            Tab(child: Text('Objectifs', style: TextStyle(fontSize: 12))),
            Tab(child: Text('Statistiques', style: TextStyle(fontSize: 11))),
            Tab(child: Text('Transactions', style: TextStyle(fontSize: 10))),
          ],
        ),

      ),
      drawer: _budgetWidgets.buildDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _budgetWidgets.buildBudgetTab(),
          _budgetWidgets.buildGoalsTab(),
          _budgetWidgets.buildStatsTab(),
          _budgetWidgets.buildTransactionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _budgetWidgets.showAddCategoryDialog();
          } else if (_tabController.index == 1) {
            // Naviguer vers l'écran des objectifs
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FinancialGoalsScreen(),
              ),
            );
          } else if (_tabController.index == 3) {
            _budgetWidgets.showAddTransactionDialog();
          } else {
            _budgetLogic.showMonthPicker();
          }
        },
        child: Icon(_tabController.index == 0
            ? Icons.add_chart
            : _tabController.index == 1
            ? Icons.track_changes_outlined
            : _tabController.index == 3
            ? Icons.add
            : Icons.calendar_today_outlined),
      ),
    );
  }
}