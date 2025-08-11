import 'package:flutter/material.dart';
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
import 'models/transaction.dart';
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
  // --- LISTES POUR LES SÉLECTEURS DE DIALOGUE ---
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
  // ----------------------------------------------

  Map<String, Map<String, dynamic>> budget = {
    'Loyer': {'percent': 0.30, 'amount': 0.0, 'icon': Icons.home_work_outlined, 'color': Color(0xFF00A9A9), 'spent': 0.0},
    'Transport': {'percent': 0.10, 'amount': 0.0, 'icon': Icons.directions_bus_filled_outlined, 'color': Color(0xFF4CAF50), 'spent': 0.0},
    'Électricité/Eau': {'percent': 0.07, 'amount': 0.0, 'icon': Icons.lightbulb_outline, 'color': Color(0xFFFFC107), 'spent': 0.0},
    'Internet': {'percent': 0.05, 'amount': 0.0, 'icon': Icons.wifi, 'color': Color(0xFF673AB7), 'spent': 0.0},
    'Nourriture': {'percent': 0.15, 'amount': 0.0, 'icon': Icons.restaurant_menu_outlined, 'color': Color(0xFFE91E63), 'spent': 0.0},
    'Loisirs': {'percent': 0.08, 'amount': 0.0, 'icon': Icons.sports_esports_outlined, 'color': Color(0xFF9C27B0), 'spent': 0.0},
    'Épargne': {'percent': 0.20, 'amount': 0.0, 'icon': Icons.savings_outlined, 'color': Color(0xFF00796B), 'spent': 0.0},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  // ===================================================================
  // ===================== LOGIQUE MÉTIER (INCHANGÉE) ==================
  // ===================================================================

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      salary = prefs.getDouble('salary') ?? 0;
      currency = prefs.getString('currency') ?? 'XOF';
      isDarkMode = prefs.getBool('isDarkMode') ?? false;

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
    filteredTransactions = transactions.where((t) =>
    t.date.year == selectedMonth.year &&
        t.date.month == selectedMonth.month
    ).toList();

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

  void calculateBudget() {
    double inputSalary = double.tryParse(_salaryController.text) ?? 0;
    if (inputSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un salaire valide'), backgroundColor: Colors.red),
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
    // Fermer le clavier
    FocusScope.of(context).unfocus();
  }

  double _getTotalBudgetPercentage() {
    return budget.values.fold(0.0, (sum, item) => sum + (item['percent'] as double));
  }

  String _getSpendingRecommendation(String category) {
    double spent = budget[category]!['spent'] as double;
    double allocated = budget[category]!['amount'] as double;
    if (allocated <= 0) return "";
    double percentage = (spent / allocated) * 100;

    if (percentage > 100) return "Budget dépassé. Essayez de réduire vos dépenses.";
    if (percentage >= 95) return "Attention, vous approchez de la limite de votre budget.";
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nom ou pourcentage invalide')));
      return;
    }
    if (budget.containsKey(name)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cette catégorie existe déjà')));
      return;
    }
    double currentTotal = _getTotalBudgetPercentage();
    if (currentTotal + (percent / 100) > 1.001) { // Tolérance pour les imprécisions de double
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le total des pourcentages ne peut pas dépasser 100%.')));
      return;
    }
    setState(() {
      budget[name] = {
        'percent': percent / 100,
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
  // Fonction pour exporter les transactions du mois sélectionné
  Future<void> _exportTransactionsToPDF() async {
    // Couleurs personnalisées
    final pdfBlue = PdfColor.fromInt(Colors.blue[700]!.value);
    final pdfLightBlue = PdfColor.fromInt(Colors.blue[100]!.value);
    final pdfWhite = PdfColors.white;
    final pdfBlack = PdfColors.black;
    final pdfGrey = PdfColors.grey;
    final pdfGreen = PdfColor.fromInt(Colors.green[700]!.value);
    final pdfRed = PdfColor.fromInt(Colors.red[700]!.value);

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

    // Calculs financiers
    final totalDepenses = monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalRestant = salary - totalDepenses;
    final depensesParCategorie = _calculateExpensesByCategory(monthTransactions);
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
                ..._generateDetailedAdvice(totalDepenses, totalRestant, depensesParCategorie).map((advice) =>
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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

// Helpers
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


// Fonctions helper améliorées
  Map<String, double> _calculateExpensesByCategory(List<Transaction> transactions) {
    final Map<String, double> result = {};
    for (final t in transactions) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  List<String> _generateDetailedAdvice(double totalSpent, double remaining, Map<String, double> byCategory) {
    final advice = <String>[];

    // Conseils généraux
    if (remaining < 0) {
      advice.add('Attention! Vous avez dépassé votre budget ce mois-ci. Essayez de réduire vos dépenses le mois prochain.');
    } else if (remaining > salary * 0.3) {
      advice.add('Excellent! Vous avez économisé plus de 30% de votre salaire ce mois-ci.');
    } else if (remaining > 0) {
      advice.add('Vous êtes dans les clous avec ${remaining.toStringAsFixed(2)} $currency restants ce mois-ci.');
    }

    // Conseils par catégorie
    final maxCategory = byCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (maxCategory.value > totalSpent * 0.4) {
      advice.add('La catégorie "${maxCategory.key}" représente une part importante (${(maxCategory.value/totalSpent*100).toStringAsFixed(1)}%) de vos dépenses. Pensez à diversifier.');
    }

    // Conseils d'épargne
    if (byCategory.containsKey('Épargne') && byCategory['Épargne']! < salary * 0.1) {
      advice.add('Votre épargne est inférieure à 10% de votre salaire. Essayez d\'augmenter cette part progressivement.');
    }

    // Conseils positifs
    if (advice.isEmpty) {
      advice.add('Votre gestion financière est équilibrée ce mois-ci. Continuez ainsi!');
    }

    return advice;
  }


  // ===================================================================
  // ====================== INTERFACE UTILISATEUR ======================
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartSpend',
      theme: AppTheme.getTheme(false),
      darkTheme: AppTheme.getTheme(true),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', 'FR'),
        const Locale('en', 'US'),
      ],
      locale: Locale('fr', 'FR'),
      home: Scaffold(
        appBar: AppBar(
          title: Text('SmartSpend'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              onPressed: () => setState(() { isDarkMode = !isDarkMode; _saveData(); }),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(child: Text('Budget')),
              Tab(child: Text('Statistiques')),
              Tab(child: Text('Transactions')),
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
            if (_tabController.index == 0) _showAddCategoryDialog();
            else if (_tabController.index == 2) _showAddTransactionDialog();
            else _showMonthPicker();
          },
          child: Icon(_tabController.index == 0
              ? Icons.add_chart
              : _tabController.index == 2
              ? Icons.add
              : Icons.calendar_today_outlined),
          tooltip: _tabController.index == 0 ? 'Ajouter une catégorie'
              : _tabController.index == 2 ? 'Ajouter une transaction'
              : 'Changer de mois',
        ),
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          _buildSalaryCard(),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Répartition du Budget", style: Theme.of(context).textTheme.titleLarge),
          ),
          SizedBox(height: 8),
          _buildBudgetList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue,',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          Text(
            'Gérez vos finances',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: InputDecoration(
                labelText: 'Votre salaire mensuel net',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Theme.of(context).colorScheme.primary),
                suffix: DropdownButton<String>(
                  value: currency,
                  underline: Container(),
                  items: currencies.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() { currency = newValue!; _saveData(); }),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: calculateBudget, child: Text('Calculer & Mettre à jour'))),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList() {
    if (salary <= 0) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
              "Entrez votre salaire pour voir votre budget.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)
              )
          ),
        ),
      );
    }
    return Column(
      children: budget.entries.map((entry) {
        double spent = entry.value['spent'] as double;
        double allocated = entry.value['amount'] as double;
        double progress = allocated > 0 ? (spent / allocated) : 0.0;
        double remaining = allocated - spent;
        String recommendation = _getSpendingRecommendation(entry.key);

        Color progressColor = entry.value['color'];
        if(progress > 1) progressColor = Theme.of(context).colorScheme.error;
        else if (progress > 0.9) progressColor = Colors.orangeAccent;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (entry.value['color'] as Color).withOpacity(0.15),
                      child: Icon(entry.value['icon'], color: entry.value['color']),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            'Alloué : ${allocated.toStringAsFixed(0)} $currency',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _showEditCategoryDialog(entry.key);
                        if (value == 'delete') _deleteCategory(entry.key);
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Modifier'))),
                        PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), title: Text('Supprimer', style: TextStyle(color: Theme.of(context).colorScheme.error)))),
                      ],
                      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dépensé : ${spent.toStringAsFixed(0)} $currency', style: Theme.of(context).textTheme.bodySmall),
                    Text('Restant : ${remaining.toStringAsFixed(0)} $currency', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: remaining < 0 ? Theme.of(context).colorScheme.error : Colors.green)),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                if (recommendation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(recommendation, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: progressColor)),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsTab() {
    double totalSpent = filteredTransactions.fold(0, (sum, item) => sum + item.amount);
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMonthSelectorHeader(),
            SizedBox(height: 24),
            filteredTransactions.isEmpty
                ? Expanded(child: Center(child: Text("Aucune dépense pour ce mois.")))
                : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              startDegreeOffset: -90,
                              pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
                              sections: budget.entries
                                  .where((entry) => entry.value['spent'] > 0)
                                  .map((entry) {
                                final double value = entry.value['spent'];
                                return PieChartSectionData(
                                  color: entry.value['color'],
                                  value: value,
                                  title: '${(value / totalSpent * 100).toStringAsFixed(0)}%',
                                  radius: 50,
                                  titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              }).toList(),
                            )
                        ),
                      ),
                      SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: budget.entries
                            .where((entry) => entry.value['spent'] > 0)
                            .map((entry) => _buildLegendItem(entry.value['color'], entry.key))
                            .toList(),
                      ),
                    ],
                  ),
                )
            ),
          ],
        )
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      SizedBox(width: 8), Text(text),
    ],
    );
  }

  Widget _buildTransactionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildMonthSelectorHeader(showExport: false),
        ),
        Expanded(
          child: filteredTransactions.isEmpty ?
          Center(child: Text('Aucune transaction pour ce mois')) :
          ListView.builder(
            padding: EdgeInsets.only(bottom: 80), // Espace pour le FAB
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              final categoryData = budget[transaction.category];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (categoryData?['color'] as Color?)?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.1),
                    child: Icon(categoryData?['icon'] ?? Icons.error_outline, color: categoryData?['color'] ?? Colors.grey),
                  ),
                  title: Text(transaction.description, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(DateFormat('d MMMM yyyy', 'fr_FR').format(transaction.date)),
                  trailing: Text(
                    '${transaction.amount.toStringAsFixed(0)} $currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: categoryData?['color'] ?? Theme.of(context).colorScheme.onSurface),
                  ),
                  onTap: () => _showTransactionOptionsDialog(transaction),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelectorHeader({bool showExport = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton de sélection du mois
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _showMonthPicker,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Bouton d'export (seulement si showExport=true et il y a des transactions)
          if (showExport && filteredTransactions.isNotEmpty)
            PopupMenuButton<String>(
              icon: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.ios_share_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              position: PopupMenuPosition.under,
              offset: Offset(0, 10),
              onSelected: (value) {
                if (value == 'csv') _exportTransactions();
                if (value == 'pdf') _exportTransactionsToPDF();
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      SizedBox(width: 12),
                      Text('Exporter en CSV'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      SizedBox(width: 12),
                      Text('Exporter en PDF'),
                    ],
                  ),
                ),
              ],
              tooltip: 'Options d\'export',
            ),
        ],
      ),
    );
  }

  // ===================================================================
  // ======================= DIALOGUES & POPUPS ========================
  // ===================================================================

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

  void _showAddTransactionDialog() {
    if(budget.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez d\'abord créer une catégorie.')));
      return;
    }
    String selectedCategory = budget.keys.first;
    double amount = 0;
    String description = '';

    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Ajouter une transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: budget.keys.map((String category) => DropdownMenuItem<String>(
                value: category,
                child: Row(children: [
                  Icon(budget[category]!['icon'], color: budget[category]!['color']),
                  SizedBox(width: 8),
                  Text(category),
                ],
                ),
              )).toList(),
              onChanged: (String? value) => selectedCategory = value!,
              decoration: InputDecoration(labelText: 'Catégorie'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Montant ($currency)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? 0,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(child: Text('Ajouter'), onPressed: () {
          Navigator.of(context).pop();
          _addTransaction(selectedCategory, amount, description);
        },
        ),
      ],
    ));
  }

  void _showTransactionOptionsDialog(Transaction transaction) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Options de la transaction'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: Icon(Icons.edit_outlined), title: Text('Modifier'), onTap: () {
          Navigator.of(context).pop();
          _showEditTransactionDialog(transaction);
        }),
        ListTile(leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), title: Text('Supprimer'), onTap: () {
          Navigator.of(context).pop();
          _deleteTransaction(transaction);
        }),
      ]),
      actions: [TextButton(child: Text('Fermer'), onPressed: () => Navigator.of(context).pop())],
    ));
  }

  void _showEditTransactionDialog(Transaction transaction) {
    double amount = transaction.amount;
    String description = transaction.description;

    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Modifier la transaction'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Catégorie: ${transaction.category}'),
          SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: amount.toString()),
            decoration: InputDecoration(labelText: 'Montant ($currency)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => amount = double.tryParse(value) ?? 0,
          ),
          SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: description),
            decoration: InputDecoration(labelText: 'Description'),
            onChanged: (value) => description = value,
          ),
        ]),
      ),
      actions: [
        TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(child: Text('Modifier'), onPressed: () {
          Navigator.of(context).pop();
          _editTransaction(transaction, amount, description);
        }),
      ],
    ));
  }

// ===================================================================
// =================== DIALOGUES (VERSION DESIGN) ====================
// ===================================================================

  void _showAddCategoryDialog() {
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez d\'abord définir votre salaire.')));
      return;
    }
    String name = '';
    double percent = 0.0;
    bool isUsingPercent = true;
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    final double totalUsedPercent = _getTotalBudgetPercentage() * 100;
    final double remainingPercent = 100 - totalUsedPercent;
    final double remainingAmount = salary * (remainingPercent / 100);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double amount = isUsingPercent ? (percent * salary) / 100 : percent;

            return AlertDialog(
              title: Text('Nouvelle Catégorie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Budget restant:', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            '${remainingPercent.toStringAsFixed(1)}% (${remainingAmount.toStringAsFixed(0)} $currency)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: remainingPercent < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(labelText: 'Nom de la catégorie'),
                      onChanged: (value) => name = value,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: isUsingPercent ? 'Pourcentage (%)' : 'Montant ($currency)',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                          tooltip: 'Changer en ${isUsingPercent ? "Montant" : "Pourcentage"}',
                          onPressed: () => setState(() => isUsingPercent = !isUsingPercent),
                        ),
                        helperText: 'Valeur: ${isUsingPercent ? amount.toStringAsFixed(0) + " " + currency : (amount / salary * 100).toStringAsFixed(1) + "%"}',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        percent = double.tryParse(value) ?? 0;
                        setState((){});
                      },
                    ),
                    SizedBox(height: 24),

                    // Sélecteur d'icônes
                    Text('Icône', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableIcons.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedIconIndex == index ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                  width: 2),
                            ),
                            child: Icon(
                              availableIcons[index],
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24),

                    // Sélecteur de couleurs
                    Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableColors.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedColorIndex = index),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: availableColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  width: selectedColorIndex == index ? 3 : 0),
                            ),
                            child: selectedColorIndex == index ? Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
                ElevatedButton(
                  child: Text('Ajouter'),
                  onPressed: () {
                    final calculatedPercent = isUsingPercent ? percent : (percent / salary * 100);
                    if (name.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le nom ne peut pas être vide.')));
                      return;
                    }
                    if (calculatedPercent > remainingPercent + 0.01) { // Tolérance
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le montant dépasse le budget restant disponible !')));
                      return;
                    }
                    Navigator.of(context).pop();
                    _addCategory(name, calculatedPercent, availableIcons[selectedIconIndex], availableColors[selectedColorIndex]);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showEditCategoryDialog(String categoryName) {
    Map<String, dynamic> currentCategory = budget[categoryName]!;
    String name = categoryName;
    double originalPercent = (currentCategory['percent'] as double) * 100;
    double percent = originalPercent;
    bool isUsingPercent = true;

    IconData currentIcon = currentCategory['icon'] as IconData;
    Color currentColor = currentCategory['color'] as Color;

    int selectedIconIndex = availableIcons.indexWhere((icon) => icon.codePoint == currentIcon.codePoint);
    if (selectedIconIndex == -1) selectedIconIndex = 0;

    int selectedColorIndex = availableColors.indexWhere((color) => color.value == currentColor.value);
    if (selectedColorIndex == -1) selectedColorIndex = 0;

    double totalUsedPercent = (_getTotalBudgetPercentage() * 100) - originalPercent;
    double remainingPercent = 100 - totalUsedPercent;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double amount = isUsingPercent ? (percent * salary) / 100 : percent;

            return AlertDialog(
              title: Text('Modifier la Catégorie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Budget total dispo.:', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            '${remainingPercent.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: TextEditingController(text: name),
                      decoration: InputDecoration(labelText: 'Nom de la catégorie'),
                      onChanged: (value) => name = value,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: percent.toString()),
                      decoration: InputDecoration(
                        labelText: isUsingPercent ? 'Pourcentage (%)' : 'Montant ($currency)',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                          tooltip: 'Changer en ${isUsingPercent ? "Montant" : "Pourcentage"}',
                          onPressed: () => setState(() => isUsingPercent = !isUsingPercent),
                        ),
                        helperText: 'Valeur: ${isUsingPercent ? amount.toStringAsFixed(0) + " " + currency : (amount / salary * 100).toStringAsFixed(1) + "%"}',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        percent = double.tryParse(value) ?? 0;
                        setState((){});
                      },
                    ),
                    SizedBox(height: 24),

                    // Sélecteur d'icônes
                    Text('Icône', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableIcons.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedIconIndex == index ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                  width: 2),
                            ),
                            child: Icon(
                              availableIcons[index],
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24),

                    // Sélecteur de couleurs
                    Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableColors.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedColorIndex = index),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: availableColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  width: selectedColorIndex == index ? 3 : 0),
                            ),
                            child: selectedColorIndex == index ? Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
                ElevatedButton(
                  child: Text('Modifier'),
                  onPressed: () {
                    final calculatedPercent = isUsingPercent ? percent : (percent / salary * 100);
                    if (calculatedPercent > remainingPercent + 0.01) { // Tolérance
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le montant dépasse le budget restant disponible !')));
                      return;
                    }
                    Navigator.of(context).pop();
                    _editCategory(categoryName, name, calculatedPercent, availableIcons[selectedIconIndex], availableColors[selectedColorIndex]);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}