import 'package:flutter/material.dart';import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'transaction.dart';
import 'theme.dart';


class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _salaryController = TextEditingController();
  late TabController _tabController;
  double salary = 0;
  String currency = 'XOF';
  List<String> currencies = ['XOF', 'USD', 'EUR', 'GBP', 'CAD'];
  bool isDarkMode = false;
  List<Transaction> transactions = [];

  // Filtre par mois
  DateTime selectedMonth = DateTime.now();
  List<Transaction> filteredTransactions = [];

  Map<String, Map<String, dynamic>> budget = {
    'Loyer': {'percent': 0.30, 'amount': 0.0, 'icon': Icons.home, 'color': Colors.blue, 'spent': 0.0},
    'Transport': {'percent': 0.10, 'amount': 0.0, 'icon': Icons.directions_car, 'color': Colors.green, 'spent': 0.0},
    'Électricité/Eau': {'percent': 0.07, 'amount': 0.0, 'icon': Icons.bolt, 'color': Colors.orange, 'spent': 0.0},
    'Internet': {'percent': 0.05, 'amount': 0.0, 'icon': Icons.wifi, 'color': Colors.purple, 'spent': 0.0},
    'Nourriture': {'percent': 0.15, 'amount': 0.0, 'icon': Icons.restaurant, 'color': Colors.red, 'spent': 0.0},
    'Loisirs': {'percent': 0.08, 'amount': 0.0, 'icon': Icons.sports_esports, 'color': Colors.pink, 'spent': 0.0},
    'Épargne': {'percent': 0.20, 'amount': 0.0, 'icon': Icons.savings, 'color': Colors.teal, 'spent': 0.0},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      salary = prefs.getDouble('salary') ?? 0;
      currency = prefs.getString('currency') ?? 'XOF';
      isDarkMode = prefs.getBool('isDarkMode') ?? false;

      // Chargement du budget
      String? savedBudget = prefs.getString('budget');
      if (savedBudget != null) {
        Map<String, dynamic> decodedBudget = jsonDecode(savedBudget);
        budget = {};
        decodedBudget.forEach((key, value) {
          budget[key] = {
            'percent': value['percent'],
            'amount': value['amount'],
            'icon': IconData(value['icon'], fontFamily: 'MaterialIcons'),
            'color': Color(value['color']),
            'spent': value['spent'] ?? 0.0,
          };
        });
      }

      // Chargement des transactions
      String? savedTransactions = prefs.getString('transactions');
      if (savedTransactions != null) {
        List<dynamic> decodedTransactions = jsonDecode(savedTransactions);
        transactions = decodedTransactions.map((item) => Transaction.fromJson(item)).toList();

        _updateFilteredTransactions();
      }

      if (salary > 0) {
        _salaryController.text = salary.toString();
        calculateBudget();
      }
    });
  }

  void _updateFilteredTransactions() {
    // Filtrer les transactions du mois sélectionné
    filteredTransactions = transactions.where((t) =>
    t.date.year == selectedMonth.year &&
        t.date.month == selectedMonth.month
    ).toList();

    // Recalculer les dépenses par catégorie pour le mois sélectionné
    budget.forEach((key, value) {
      budget[key]!['spent'] = 0.0;
    });

    for (var transaction in filteredTransactions) {
      if (budget.containsKey(transaction.category)) {
        budget[transaction.category]!['spent'] =
            (budget[transaction.category]!['spent'] as double) + transaction.amount;
      }
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('salary', salary);
    await prefs.setString('currency', currency);
    await prefs.setBool('isDarkMode', isDarkMode);

    // Sauvegarde du budget
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

    // Sauvegarde des transactions
    List<Map<String, dynamic>> encodableTransactions =
    transactions.map((t) => t.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(encodableTransactions));
  }

  void calculateBudget() {
    double inputSalary = double.tryParse(_salaryController.text) ?? 0;
    if (inputSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un salaire valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      salary = inputSalary;
      budget.forEach((key, value) {
        budget[key]!['amount'] = salary * value['percent'];
      });
      _saveData();
    });
  }

  // Fonction pour vérifier si le total des pourcentages dépasse 100%
  double _getTotalBudgetPercentage() {
    double total = 0.0;
    budget.forEach((key, value) {
      total += value['percent'] as double;
    });
    return total;
  }

  // Nouvelle fonction pour obtenir des recommandations de dépenses
  String _getSpendingRecommendation(String category) {
    double spent = budget[category]!['spent'] as double;
    double allocated = budget[category]!['amount'] as double;
    double percentage = allocated > 0 ? (spent / allocated) * 100 : 0;

    if (percentage > 100) {
      return "Vous avez dépassé votre budget pour cette catégorie. Essayez de réduire vos dépenses.";
    } else if (percentage >= 95) {
      return "Vous approchez de la limite de votre budget. Soyez prudent avec vos prochaines dépenses.";
    } else if (percentage < 30 && percentage > 0) {
      return "Vous utilisez peu de votre budget alloué. C'est une bonne occasion d'épargner.";
    }
    return "";
  }

  void _addTransaction(String category, double amount, String description) {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    setState(() {
      transactions.add(transaction);
      _updateFilteredTransactions();
      _saveData();
    });
  }

  void _editTransaction(Transaction transaction, double newAmount, String newDescription) {
    setState(() {
      // Mettre à jour la transaction
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

      _updateFilteredTransactions();
      _saveData();
    });
  }

  void _deleteTransaction(Transaction transaction) {
    setState(() {
      transactions.removeWhere((t) => t.id == transaction.id);
      _updateFilteredTransactions();
      _saveData();
    });
  }

  void _addCategory(String name, double percent, IconData icon, Color color) {
    if (name.isEmpty || percent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un nom valide et un pourcentage supérieur à 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier si le nom existe déjà
    if (budget.containsKey(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cette catégorie existe déjà'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier si le total des pourcentages dépasse 100%
    double currentTotal = _getTotalBudgetPercentage();
    if (currentTotal + percent/100 > 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le total des pourcentages ne peut pas dépasser 100%. Actuellement: ${(currentTotal * 100).toStringAsFixed(0)}%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      budget[name] = {
        'percent': percent / 100, // Convertir en pourcentage décimal
        'amount': salary * (percent / 100),
        'icon': icon,
        'color': color,
        'spent': 0.0,
      };
      _saveData();
    });
  }

  void _editCategory(String oldName, String newName, double percent, IconData icon, Color color) {
    if (newName.isEmpty || percent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un nom valide et un pourcentage supérieur à 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier si le nouveau nom existe déjà (sauf s'il s'agit du même nom)
    if (oldName != newName && budget.containsKey(newName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cette catégorie existe déjà'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier si le total des pourcentages dépasse 100%
    double currentTotal = _getTotalBudgetPercentage() - (budget[oldName]!['percent'] as double);
    if (currentTotal + percent/100 > 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le total des pourcentages ne peut pas dépasser 100%. Après modification: ${((currentTotal + percent/100) * 100).toStringAsFixed(0)}%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // Créer la nouvelle catégorie avec les valeurs modifiées
      Map<String, dynamic> updatedCategory = {
        'percent': percent / 100, // Convertir en pourcentage décimal
        'amount': salary * (percent / 100),
        'icon': icon,
        'color': color,
        'spent': budget[oldName]!['spent'],
      };

      // Si le nom a changé, supprimer l'ancienne catégorie et ajouter la nouvelle
      if (oldName != newName) {
        // Mettre à jour les transactions qui utilisaient l'ancien nom de catégorie
        for (int i = 0; i < transactions.length; i++) {
          if (transactions[i].category == oldName) {
            transactions[i] = Transaction(
              id: transactions[i].id,
              category: newName,
              amount: transactions[i].amount,
              description: transactions[i].description,
              date: transactions[i].date,
            );
          }
        }

        budget.remove(oldName);
        budget[newName] = updatedCategory;
      } else {
        // Sinon, juste mettre à jour les valeurs
        budget[oldName] = updatedCategory;
      }

      _updateFilteredTransactions();
      _saveData();
    });
  }

  void _deleteCategory(String name) {
    // Vérifier si la catégorie existe et si elle a des transactions
    bool hasTransactions = transactions.any((t) => t.category == name);

    if (hasTransactions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de supprimer une catégorie avec des transactions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      budget.remove(name);
      _saveData();
    });
  }

  // Fonction pour exporter les transactions du mois sélectionné
  Future<void> _exportTransactions() async {
    final monthTransactions = transactions.where((t) =>
    t.date.month == selectedMonth.month &&
        t.date.year == selectedMonth.year
    ).toList();

    if (monthTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune transaction à exporter'),
          backgroundColor: Colors.orange,
        ),
      );
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
  @override
  Widget build(BuildContext context) {
    ThemeData theme = getAppTheme(isDarkMode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartSpend',
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('SmartSpend'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                  _saveData();
                });
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Budget'),
              Tab(text: 'Statistiques'),
              Tab(text: 'Transactions'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBudgetTab(),
            _buildStatsTab(),
            _buildTransactionsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_tabController.index == 0) {
              _showAddCategoryDialog();
            } else if (_tabController.index == 2) {
              _showAddTransactionDialog();
            } else {
              // Pour l'onglet statistiques
              _showMonthPicker();
            }
          },
          child: Icon(_tabController.index == 0
              ? Icons.add_chart
              : _tabController.index == 2
              ? Icons.add
              : Icons.calendar_month),
          tooltip: _tabController.index == 0
              ? 'Ajouter une catégorie'
              : _tabController.index == 2
              ? 'Ajouter une transaction'
              : 'Changer de mois',
        ),
      ),
    );
  }

  Widget _buildBudgetTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.blue[50]!, Colors.blue[100]!],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildSalaryInput(),
              SizedBox(height: 24),
              _buildCalculateButton(),
              SizedBox(height: 24),
              _buildBudgetList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.blue[50]!, Colors.blue[100]!],
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Sélecteur de mois
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mois: ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: filteredTransactions.isEmpty ? null : _exportTransactions,
                tooltip: 'Exporter les transactions',
                color: isDarkMode ? Colors.white : Colors.blue[800],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Graphique des dépenses réelles
          budget.isEmpty || filteredTransactions.isEmpty ?
          Center(child: Text('Aucune dépense pour ce mois')) :
          Container(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: budget.entries
                    .where((entry) => entry.value['spent'] > 0) // Ne montrer que les catégories avec des dépenses
                    .map((entry) {
                  return PieChartSectionData(
                    color: entry.value['color'],
                    value: entry.value['spent'], // Utiliser les dépenses réelles
                    title: '${(entry.value['spent'] as double).toStringAsFixed(0)}',
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 100,
                    showTitle: true,
                    borderSide: BorderSide(width: 0),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: 180,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Légende
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: budget.entries
                    .where((entry) => entry.value['spent'] > 0) // Ne montrer que les catégories avec des dépenses
                    .map((entry) {
                  double spentPercent = salary > 0
                      ? ((entry.value['spent'] as double) / salary) * 100
                      : 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: entry.value['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${(entry.value['spent'] as double).toStringAsFixed(0)} $currency (${spentPercent.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.blue[50]!, Colors.blue[100]!],
        ),
      ),
      child: Column(
        children: [
          // Sélecteur de mois
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mois: ${DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () => _showMonthPicker(),
                  color: isDarkMode ? Colors.white : Colors.blue[800],
                ),
              ],
            ),
          ),

          // Liste des transactions
          Expanded(
            child: filteredTransactions.isEmpty ?
            Center(child: Text('Aucune transaction pour ce mois')) :
            ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      budget[transaction.category]?['icon'] ?? Icons.error,
                      color: budget[transaction.category]?['color'] ?? Colors.grey,
                    ),
                    title: Text(
                      transaction.description,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    trailing: Text(
                      '${transaction.amount.toStringAsFixed(0)} $currency',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: budget[transaction.category]?['color'] ?? Colors.grey,
                      ),
                    ),
                    onTap: () => _showTransactionOptionsDialog(transaction),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedMonth = DateTime(date.year, date.month);
          _updateFilteredTransactions();
        });
      }
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SmartSpend',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.blue[800],
          ),
        ),
        Text(
          'Planifiez vos dépenses intelligemment',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.blue[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Votre salaire mensuel',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
                icon: Icon(
                  Icons.account_balance_wallet,
                  color: isDarkMode ? Colors.white70 : Colors.blue,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.blue[100]!,
                ),
              ),
            ),
            child: DropdownButton<String>(
              value: currency,
              underline: Container(),
              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              items: currencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  currency = newValue!;
                  _saveData();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: calculateBudget,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Calculer mon budget',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Complétion de la fonction _buildBudgetList() et le reste du code

  Widget _buildBudgetList() {
    return Column(
      children: budget.entries.map((entry) {
        double progressValue = salary > 0 ? entry.value['amount'] / salary : 0.0;
        progressValue = progressValue.clamp(0.0, 1.0);

        double spentPercentage = entry.value['amount'] > 0
            ? (entry.value['spent'] / entry.value['amount']).clamp(0.0, 2.0) // Limite à 200% pour l'affichage
            : 0.0;

        // Calcul du montant restant
        double remaining = (entry.value['amount'] as double) - (entry.value['spent'] as double);
        String recommendation = _getSpendingRecommendation(entry.key);

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    entry.value['icon'],
                    color: entry.value['color'],
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${(entry.value['percent'] * 100).toStringAsFixed(0)}% - ${entry.value['amount'].toStringAsFixed(0)} $currency',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: isDarkMode ? Colors.white70 : Colors.blue),
                    onPressed: () => _showEditCategoryDialog(entry.key),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: isDarkMode ? Colors.white70 : Colors.red),
                    onPressed: () => _deleteCategory(entry.key),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Affichage détaillé des dépenses et du montant restant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dépensé: ${entry.value['spent'].toStringAsFixed(0)} $currency',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Restant: ${remaining.toStringAsFixed(0)} $currency',
                    style: TextStyle(
                      color: remaining < 0
                          ? Colors.red
                          : (isDarkMode ? Colors.white70 : Colors.green[700]),
                      fontWeight: remaining < 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Barre de progression
              Stack(
                children: [
                  // Fond de la barre
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Progression des dépenses
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.7 * spentPercentage,
                    decoration: BoxDecoration(
                      color: spentPercentage > 1
                          ? Colors.red
                          : (spentPercentage > 0.95 ? Colors.orange : entry.value['color']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              // Afficher la recommandation si elle existe
              if (recommendation.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: spentPercentage > 1
                          ? Colors.red
                          : (spentPercentage > 0.95 ? Colors.orange : isDarkMode ? Colors.white60 : Colors.grey[600]),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Au lieu d'utiliser des objets Color directement, utilisons un index ou une Map
// pour stocker les couleurs dans les fonctions de dialogue

  // Mise à jour de la fonction _showAddCategoryDialog()
  void _showAddCategoryDialog() {
    String name = '';
    double percent = 0;
    double amount = 0;
    bool isUsingPercent = true; // Mode de saisie par défaut
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    // Définir la liste des couleurs disponibles
    List<Color> availableColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
    ];

    // Calculer le pourcentage total déjà utilisé
    double totalUsedPercent = 0;
    budget.forEach((category, data) {
      totalUsedPercent += (data['percent'] as double) * 100;
    });
    double remainingPercent = 100 - totalUsedPercent;
    double remainingAmount = salary * (remainingPercent / 100);

    // Définir une liste d'icônes disponibles
    List<IconData> availableIcons = [
      Icons.home,
      Icons.directions_car,
      Icons.bolt,
      Icons.wifi,
      Icons.restaurant,
      Icons.sports_esports,
      Icons.savings,
      Icons.shopping_cart,
      Icons.medical_services,
      Icons.school,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Fonctions de conversion entre pourcentage et montant
            void updateAmountFromPercent() {
              if (salary > 0) {
                amount = (percent * salary) / 100;
              }
            }

            void updatePercentFromAmount() {
              if (salary > 0) {
                percent = (amount / salary) * 100;
              }
            }

            return AlertDialog(
              title: Text('Ajouter une catégorie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Affichage du pourcentage et montant restants
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Restant:'),
                              Text(
                                '${remainingPercent.toStringAsFixed(1)}% (${remainingAmount.toStringAsFixed(0)} $currency)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: remainingPercent < 0 ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // Switch pour choisir entre pourcentage et montant
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Montant'),
                        Switch(
                          value: isUsingPercent,
                          onChanged: (value) {
                            setState(() {
                              isUsingPercent = value;
                              if (isUsingPercent) {
                                updatePercentFromAmount();
                              } else {
                                updateAmountFromPercent();
                              }
                            });
                          },
                        ),
                        Text('Pourcentage'),
                      ],
                    ),
                    SizedBox(height: 8),
                    isUsingPercent
                        ? TextField(
                      decoration: InputDecoration(
                        labelText: 'Pourcentage (%)',
                        border: OutlineInputBorder(),
                        helperText: 'Restant: ${remainingPercent.toStringAsFixed(1)}%',
                        suffixText: 'Montant: ${(percent * salary / 100).toStringAsFixed(0)} $currency',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          percent = double.tryParse(value) ?? 0;
                          updateAmountFromPercent();
                        });
                      },
                    )
                        : TextField(
                      decoration: InputDecoration(
                        labelText: 'Montant ($currency)',
                        border: OutlineInputBorder(),
                        helperText: 'Restant: ${remainingAmount.toStringAsFixed(0)} $currency',
                        suffixText: 'Pourcentage: ${(amount / salary * 100).toStringAsFixed(1)}%',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          amount = double.tryParse(value) ?? 0;
                          updatePercentFromAmount();
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Icône:'),
                        DropdownButton<int>(
                          value: selectedIconIndex,
                          items: List.generate(availableIcons.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Icon(availableIcons[index]),
                            );
                          }),
                          onChanged: (int? value) {
                            setState(() {
                              selectedIconIndex = value ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Couleur:'),
                        DropdownButton<int>(
                          value: selectedColorIndex,
                          items: List.generate(availableColors.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Container(width: 24, height: 24, color: availableColors[index]),
                            );
                          }),
                          onChanged: (int? value) {
                            setState(() {
                              selectedColorIndex = value ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Ajouter'),
                  onPressed: () {
                    // Vérifier si les valeurs sont valides
                    double calculatedPercent = isUsingPercent ? percent : (amount / salary * 100);

                    if (calculatedPercent > remainingPercent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Le montant dépasse la valeur restante disponible!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop();
                    _addCategory(
                        name,
                        calculatedPercent,
                        availableIcons[selectedIconIndex],
                        availableColors[selectedColorIndex]
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

// Mise à jour de la fonction _showEditCategoryDialog()
  void _showEditCategoryDialog(String categoryName) {
    String name = categoryName;
    double percent = (budget[categoryName]!['percent'] as double) * 100;
    double originalPercent = percent; // Sauvegarder le pourcentage original
    double amount = budget[categoryName]!['amount'] as double;
    double originalAmount = amount; // Sauvegarder le montant original
    bool isUsingPercent = true; // Mode de saisie par défaut
    IconData currentIcon = budget[categoryName]!['icon'] as IconData;
    Color currentColor = budget[categoryName]!['color'] as Color;

    // Définir la liste des couleurs disponibles
    List<Color> availableColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
    ];

    // Trouver l'index de la couleur actuelle ou utiliser 0
    int selectedColorIndex = 0;
    for (int i = 0; i < availableColors.length; i++) {
      if (availableColors[i].value == currentColor.value) {
        selectedColorIndex = i;
        break;
      }
    }

    // Calculer le pourcentage total déjà utilisé (sans compter la catégorie actuelle)
    double totalUsedPercent = 0;
    budget.forEach((category, data) {
      if (category != categoryName) {
        totalUsedPercent += (data['percent'] as double) * 100;
      }
    });
    double remainingPercent = 100 - totalUsedPercent;
    double remainingAmount = salary * (remainingPercent / 100);

    // Définir une liste d'icônes disponibles
    List<IconData> availableIcons = [
      Icons.home,
      Icons.directions_car,
      Icons.bolt,
      Icons.wifi,
      Icons.restaurant,
      Icons.sports_esports,
      Icons.savings,
      Icons.shopping_cart,
      Icons.medical_services,
      Icons.school,
    ];

    // Trouver l'index de l'icône actuelle ou utiliser 0
    int selectedIconIndex = 0;
    for (int i = 0; i < availableIcons.length; i++) {
      if (availableIcons[i].codePoint == currentIcon.codePoint) {
        selectedIconIndex = i;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Fonctions de conversion entre pourcentage et montant
            void updateAmountFromPercent() {
              if (salary > 0) {
                amount = (percent * salary) / 100;
              }
            }

            void updatePercentFromAmount() {
              if (salary > 0) {
                percent = (amount / salary) * 100;
              }
            }

            return AlertDialog(
              title: Text('Modifier la catégorie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Affichage du pourcentage restant + pourcentage actuel
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Actuel:'),
                              Text(
                                '${originalPercent.toStringAsFixed(1)}% (${originalAmount.toStringAsFixed(0)} $currency)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Restant:'),
                              Text(
                                '${remainingPercent.toStringAsFixed(1)}% (${remainingAmount.toStringAsFixed(0)} $currency)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: remainingPercent < 0 ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total disponible:'),
                              Text(
                                '${(remainingPercent + originalPercent).toStringAsFixed(1)}% (${(remainingAmount + originalAmount).toStringAsFixed(0)} $currency)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: name),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(height: 16),
                    // Switch pour choisir entre pourcentage et montant
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Montant'),
                        Switch(
                          value: isUsingPercent,
                          onChanged: (value) {
                            setState(() {
                              isUsingPercent = value;
                              if (isUsingPercent) {
                                updatePercentFromAmount();
                              } else {
                                updateAmountFromPercent();
                              }
                            });
                          },
                        ),
                        Text('Pourcentage'),
                      ],
                    ),
                    SizedBox(height: 8),
                    isUsingPercent
                        ? TextField(
                      decoration: InputDecoration(
                        labelText: 'Pourcentage (%)',
                        border: OutlineInputBorder(),
                        helperText: 'Maximum: ${(remainingPercent + originalPercent).toStringAsFixed(1)}%',
                        suffixText: 'Montant: ${(percent * salary / 100).toStringAsFixed(0)} $currency',
                      ),
                      controller: TextEditingController(text: percent.toString()),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          percent = double.tryParse(value) ?? 0;
                          updateAmountFromPercent();
                        });
                      },
                    )
                        : TextField(
                      decoration: InputDecoration(
                        labelText: 'Montant ($currency)',
                        border: OutlineInputBorder(),
                        helperText: 'Maximum: ${(remainingAmount + originalAmount).toStringAsFixed(0)} $currency',
                        suffixText: 'Pourcentage: ${(amount / salary * 100).toStringAsFixed(1)}%',
                      ),
                      controller: TextEditingController(text: amount.toString()),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          amount = double.tryParse(value) ?? 0;
                          updatePercentFromAmount();
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Icône:'),
                        DropdownButton<int>(
                          value: selectedIconIndex,
                          items: List.generate(availableIcons.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Icon(availableIcons[index]),
                            );
                          }),
                          onChanged: (int? value) {
                            setState(() {
                              selectedIconIndex = value ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Couleur:'),
                        DropdownButton<int>(
                          value: selectedColorIndex,
                          items: List.generate(availableColors.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Container(width: 24, height: 24, color: availableColors[index]),
                            );
                          }),
                          onChanged: (int? value) {
                            setState(() {
                              selectedColorIndex = value ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Modifier'),
                  onPressed: () {
                    // Vérifier si les valeurs sont valides
                    double calculatedPercent = isUsingPercent ? percent : (amount / salary * 100);

                    if (calculatedPercent > remainingPercent + originalPercent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Le montant dépasse la valeur restante disponible!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop();
                    _editCategory(
                        categoryName,
                        name,
                        calculatedPercent,
                        availableIcons[selectedIconIndex],
                        availableColors[selectedColorIndex]
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTransactionDialog() {
    String selectedCategory = budget.keys.first;
    double amount = 0;
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ajouter une transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      items: budget.keys.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(budget[category]!['icon'], color: budget[category]!['color']),
                              SizedBox(width: 8),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Montant ($currency)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        amount = double.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Ajouter'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addTransaction(selectedCategory, amount, description);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTransactionOptionsDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Modifier'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditTransactionDialog(transaction);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteTransaction(transaction);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTransactionDialog(Transaction transaction) {
    double amount = transaction.amount;
    String description = transaction.description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Catégorie: ${transaction.category}'),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Montant ($currency)',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: amount.toString()),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    amount = double.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: description),
                  onChanged: (value) {
                    description = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Modifier'),
              onPressed: () {
                Navigator.of(context).pop();
                _editTransaction(transaction, amount, description);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _salaryController.dispose();
    super.dispose();
  }
}