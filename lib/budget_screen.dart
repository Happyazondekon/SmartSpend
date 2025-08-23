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
import 'services/premium_service.dart';
import 'futuristic_background.dart';

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
  final PremiumService _premiumService = PremiumService();
  bool _isPremiumUser = false;

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
    _checkPremiumStatus();
    _themeProvider.addListener(_onThemeChanged);
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final isPremium = await _premiumService.isPremiumUser();
      setState(() {
        _isPremiumUser = isPremium;
      });
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut Premium: $e');
    }
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
    final isDarkMode = ThemeProvider().isDarkMode;

    return FuturisticBackground(
      isDarkMode: isDarkMode,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildFuturisticAppBar(isDarkMode),
        drawer: _buildGlassmorphicDrawer(isDarkMode),
        body: Column(
          children: [
            // Espace pour l'AppBar
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 48),

            // Contenu principal avec effet glassmorphique futuriste
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12.0),
                decoration: _buildFuturisticGlassDecoration(isDarkMode),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(_budgetWidgets.buildBudgetTab(), isDarkMode),
                      _buildTabContent(_budgetWidgets.buildGoalsTab(), isDarkMode),
                      _buildTabContent(_budgetWidgets.buildStatsTab(), isDarkMode),
                      _buildTabContent(_budgetWidgets.buildTransactionsTab(), isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFuturisticFAB(isDarkMode),
      ),
    );
  }

  PreferredSizeWidget _buildFuturisticAppBar(bool isDarkMode) {
    return PreferredSize(
      // Augmente la hauteur pour inclure la TabBar
      preferredSize: const Size.fromHeight(kToolbarHeight + 48 + 16),
      child: Container(
        // ✅ SUPPRESSION du fond - AppBar entièrement transparente
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar principale
              Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.blue[700]!.withOpacity(0.08),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.15)
                                : Colors.blue[700]!.withOpacity(0.12),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: isDarkMode ? null : Colors.blue[700]!,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ✅ Texte toujours centré avec style futuriste
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: isDarkMode
                                  ? [const Color(0xFF4CDADA), const Color(0xFF70F7F7)]
                                  : [Colors.blue[700]!, const Color(0xFF764BA2)],
                            ).createShader(bounds),
                            child: const Text(
                              'SmartSpend',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // ✅ Badge aligné à droite sans bouger le texte
                          if (_isPremiumUser)
                            Positioned(
                              right: 0,
                              child: _premiumService.buildPremiumBadge(),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFuturisticGlassButton(
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: isDarkMode
                                ? Theme.of(context).colorScheme.primary
                                : Colors.blue[700]!,
                            backgroundImage: AuthService().currentUser?.photoURL != null
                                ? NetworkImage(AuthService().currentUser!.photoURL!)
                                : null,
                            child: AuthService().currentUser?.photoURL == null
                                ? Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              maintainState: true,
                              builder: (context) => const ProfileScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFuturisticGlassButton(
                          child: Icon(
                            isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            color: isDarkMode ? null : Colors.blue[700]!,
                          ),
                          onPressed: () => ThemeProvider().toggleTheme(!isDarkMode),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // TabBar transparente SANS fond
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  // ✅ SUPPRESSION des gradients de fond
                  color: Colors.transparent,
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.blue[700]!.withOpacity(0.15),
                    width: 1.2,
                  ),
                  // ✅ SUPPRESSION complète des ombres pour transparence totale
                  boxShadow: [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                          const Color(0xFF4CDADA).withOpacity(0.3),
                          const Color(0xFF70F7F7).withOpacity(0.2),
                        ]
                            : [
                          // Mode Light - Indicateur élégant violet/doré
                          Colors.blue[700]!.withOpacity(0.15),
                          Colors.blue[700]!.withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? const Color(0xFF4CDADA).withOpacity(0.2)
                              : Colors.blue[700]!.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? null : Colors.blue[700]!,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? null : const Color(0xFF764BA2).withOpacity(0.7),
                    ),
                    labelColor: isDarkMode ? null : Colors.blue[700]!,
                    unselectedLabelColor: isDarkMode ? null : const Color(0xFF764BA2).withOpacity(0.7),
                    tabs: const [
                      Tab(text: 'Budget'),
                      Tab(text: 'Objectifs'),
                      Tab(text: 'Stats'),
                      Tab(text: 'Transactions'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticGlassButton({required Widget child, required VoidCallback onPressed}) {
    final isDarkMode = ThemeProvider().isDarkMode;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ]
              : [
            // Mode Light - Gradient sophistiqué
            const Color(0xFFFFFFFF).withOpacity(0.7),
            Colors.blue[700]!.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.blue[700]!.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.blue[700]!.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: child,
      ),
    );
  }

  Widget _buildGlassmorphicDrawer(bool isDarkMode) {
    return Container(
      child: ClipRRect(
        child: _budgetWidgets.buildDrawer(),
      ),
    );
  }

  BoxDecoration _buildFuturisticGlassDecoration(bool isDarkMode) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [
          // Mode Dark - Gradient avec plus de profondeur
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.03),
        ]
            : [
          // Mode Light - Gradient futuriste élégant
          const Color(0xFFFFFFFF).withOpacity(0.08),
          const Color(0xFFF8F9FF).withOpacity(0.05),
          Colors.blue[300]!.withOpacity(0.03),
        ],
      ),
      border: Border.all(
        color: isDarkMode
            ? Colors.white.withOpacity(0.18)
            : Colors.blue[700]!.withOpacity(0.18),
        width: 1,
      ),
      boxShadow: [
        // Ombre principale
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withOpacity(0.4)
              : const Color(0xFF667EEA).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        // Ombre de profondeur pour le mode dark
        if (isDarkMode)
          BoxShadow(
            color: const Color(0xFF4CDADA).withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        // Effet de profondeur supplémentaire pour le mode light
        if (!isDarkMode)
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
      ],
    );
  }

  Widget _buildTabContent(Widget child, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
            Colors.transparent,
            const Color(0xFF0F1414).withOpacity(0.02),
          ]
              : [
            // Mode Light - Gradient subtil pour le contenu
            Colors.transparent,
            Colors.blue[700]!.withOpacity(0.01),
            const Color(0xFF0F1414).withOpacity(0.02),
          ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildFuturisticFAB(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ]
              : [
            // Mode Light - Gradient futuriste élégant
            Colors.blue[700]!,
            const Color(0xFF764BA2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.blue[700]!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (!isDarkMode) // Effet doré subtil pour le mode light
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () {
          if (_tabController.index == 0) {
            _budgetWidgets.showAddCategoryDialog();
          } else if (_tabController.index == 1) {
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
        child: Icon(
          _tabController.index == 0
              ? Icons.add_chart_rounded
              : _tabController.index == 1
              ? Icons.track_changes_outlined
              : _tabController.index == 3
              ? Icons.add_rounded
              : Icons.calendar_today_outlined,
          size: 24,
        ),
      ),
    );
  }
}