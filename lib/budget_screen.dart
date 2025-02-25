import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction.dart';
import 'theme.dart';
import 'utils.dart';

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
            'spent': value['spent'],
          };
        });
      }

      // Chargement des transactions
      String? savedTransactions = prefs.getString('transactions');
      if (savedTransactions != null) {
        List<dynamic> decodedTransactions = jsonDecode(savedTransactions);
        transactions = decodedTransactions.map((item) => Transaction.fromJson(item)).toList();

        // Recalculer les dépenses par catégorie
        budget.forEach((key, value) {
          budget[key]!['spent'] = 0.0;
        });

        for (var transaction in transactions) {
          if (budget.containsKey(transaction.category)) {
            budget[transaction.category]!['spent'] =
                (budget[transaction.category]!['spent'] as double) + transaction.amount;
          }
        }
      }

      if (salary > 0) {
        _salaryController.text = salary.toString();
        calculateBudget();
      }
    });
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
      budget[category]!['spent'] = (budget[category]!['spent'] as double) + amount;
      _saveData();
    });
  }

  void _editTransaction(Transaction transaction, double newAmount, String newDescription) {
    setState(() {
      // Soustraire l'ancien montant des dépenses de catégorie
      budget[transaction.category]!['spent'] =
          (budget[transaction.category]!['spent'] as double) - transaction.amount;

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

        // Ajouter le nouveau montant aux dépenses de catégorie
        budget[transaction.category]!['spent'] =
            (budget[transaction.category]!['spent'] as double) + newAmount;
      }

      _saveData();
    });
  }

  void _deleteTransaction(Transaction transaction) {
    setState(() {
      transactions.removeWhere((t) => t.id == transaction.id);
      budget[transaction.category]!['spent'] =
          (budget[transaction.category]!['spent'] as double) - transaction.amount;
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
            } else {
              _showAddTransactionDialog();
            }
          },
          child: Icon(_tabController.index == 0 ? Icons.add_chart : Icons.add),
          tooltip: _tabController.index == 0 ? 'Ajouter une catégorie' : 'Ajouter une transaction',
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
      child: budget.isEmpty ?
      Center(child: Text('Aucune catégorie de budget définie')) :
      Column(
        children: [
          Container(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: budget.entries.map((entry) {
                  return PieChartSectionData(
                    color: entry.value['color'],
                    value: entry.value['amount'],
                    title: entry.key,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    radius: 100,
                    showTitle: true,
                    borderSide: BorderSide(
                      width: 0,
                    ),
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
                children: budget.entries.map((entry) {
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
                          '${entry.value['amount'].toStringAsFixed(0)} $currency',
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
      child: transactions.isEmpty ?
      Center(child: Text('Aucune transaction enregistrée')) :
      ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
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
    );
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

  Widget _buildBudgetList() {
    return Column(
      children: budget.entries.map((entry) {
        double progressValue = salary > 0 ? entry.value['amount'] / salary : 0.0;
        progressValue = progressValue.clamp(0.0, 1.0);

        double spentPercentage = entry.value['amount'] > 0
            ? (entry.value['spent'] / entry.value['amount']).clamp(0.0, 1.0)
            : 0.0;

        return GestureDetector(
          onLongPress: () => _showCategoryOptionsDialog(entry.key),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          entry.value['icon'],
                          color: entry.value['color'],
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value['amount'].toStringAsFixed(0)} $currency',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: entry.value['color'],
                          ),
                        ),
                        Text(
                          'Dépensé: ${entry.value['spent'].toStringAsFixed(0)} $currency',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: entry.value['color'].withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(entry.value['color']),
                      minHeight: 8,
                    ),
                    LinearProgressIndicator(
                      value: spentPercentage * progressValue,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.value['color'].withOpacity(0.5),
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(entry.value['percent'] * 100).toStringAsFixed(0)}% du budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${(spentPercentage * 100).toStringAsFixed(0)}% utilisé',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddTransactionDialog() {
    if (budget.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez d\'abord créer au moins une catégorie de budget'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String selectedCategory = budget.keys.first;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Ajouter une dépense',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              items: budget.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(budget[category]!['icon'], color: budget[category]!['color'], size: 20),
                      SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Montant',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Ajouter',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              double amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Veuillez entrer un montant valide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              _addTransaction(
                selectedCategory,
                amount,
                descriptionController.text.isNotEmpty ? descriptionController.text : 'Sans description',
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTransactionOptionsDialog(Transaction transaction) {
    final amountController = TextEditingController(text: transaction.amount.toString());
    final descriptionController = TextEditingController(text: transaction.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Options',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction du ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Montant',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              _deleteTransaction(transaction);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Enregistrer',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              double amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Veuillez entrer un montant valide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              _editTransaction(
                transaction,
                amount,
                descriptionController.text.isNotEmpty ? descriptionController.text : 'Sans description',
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final percentController = TextEditingController();
    IconData selectedIcon = availableIcons.first;
    Color selectedColor = availableColors.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Ajouter une catégorie',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nom de la catégorie',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
              TextField(
                controller: percentController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Pourcentage du budget (%)',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Choisir une icône',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: availableIcons.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? (isDarkMode ? Colors.blue[700] : Colors.blue[100])
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isDarkMode ? Colors.white : Colors.blue[800],
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Choisir une couleur',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: availableColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Ajouter',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              double percent = double.tryParse(percentController.text) ?? 0;
              _addCategory(
                nameController.text,
                percent,
                selectedIcon,
                selectedColor,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryOptionsDialog(String categoryName) {
    final nameController = TextEditingController(text: categoryName);
    final percentController = TextEditingController(
        text: (budget[categoryName]!['percent'] * 100).toStringAsFixed(0));
    IconData selectedIcon = budget[categoryName]!['icon'];
    Color selectedColor = budget[categoryName]!['color'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        title: Text(
          'Modifier la catégorie',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nom de la catégorie',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
              TextField(
                controller: percentController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Pourcentage du budget (%)',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Choisir une icône',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: availableIcons.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? (isDarkMode ? Colors.blue[700] : Colors.blue[100])
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isDarkMode ? Colors.white : Colors.blue[800],
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Choisir une couleur',
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: availableColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              _deleteCategory(categoryName);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Enregistrer',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              double percent = double.tryParse(percentController.text) ?? 0;
              _editCategory(
                categoryName,
                nameController.text,
                percent,
                selectedIcon,
                selectedColor,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}