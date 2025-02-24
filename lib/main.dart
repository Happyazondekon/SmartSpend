import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(SmartSpendApp());
}

class SmartSpendApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartSpend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: BudgetScreen(),
    );
  }
}

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
    setState(() {
      transactions.add(Transaction(
        category: category,
        amount: amount,
        description: description,
        date: DateTime.now(),
      ));
      budget[category]!['spent'] = (budget[category]!['spent'] as double) + amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onPressed: () => _showAddTransactionDialog(),
        child: Icon(Icons.add),
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
      padding: EdgeInsets.all(16),
      child: Column(
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
          Column(
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
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              budget[transaction.category]!['icon'],
              color: budget[transaction.category]!['color'],
            ),
            title: Text(transaction.description),
            subtitle: Text(
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
            ),
            trailing: Text(
              '${transaction.amount.toStringAsFixed(0)} $currency',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: budget[transaction.category]!['color'],
              ),
            ),
          ),
        );
      },
    );
  }
// ... (code précédent inchangé jusqu'aux méthodes manquantes)

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

        return Container(
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
        );
      }).toList(),
    );
  }

// ... (reste du code inchangé)
  // Autres widgets existants...

  void _showAddTransactionDialog() {
    String selectedCategory = budget.keys.first;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une dépense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              items: budget.keys.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                _addTransaction(
                  selectedCategory,
                  amount,
                  descriptionController.text,
                );
              }
              Navigator.pop(context);
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });
}