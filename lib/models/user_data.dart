import 'package:flutter/material.dart';
import 'transaction.dart';
import 'financial_goal.dart';


class UserData {
  final String userId;
  final double salary;
  final String currency;
  final Map<String, Map<String, dynamic>> budget;
  final List<Transaction> transactions;
  final List<FinancialGoal> financialGoals; // NOUVEAU
  final bool notificationsEnabled;
  final DateTime lastUpdated;

  UserData({
    required this.userId,
    required this.salary,
    required this.currency,
    required this.budget,
    required this.transactions,
    required this.financialGoals, // NOUVEAU
    required this.notificationsEnabled,
    required this.lastUpdated,
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    // Convertir le budget en format encodable
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

    return {
      'userId': userId,
      'salary': salary,
      'currency': currency,
      'budget': encodableBudget,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'financialGoals': financialGoals.map((g) => g.toJson()).toList(), // NOUVEAU
      'notificationsEnabled': notificationsEnabled,
      'lastUpdated': lastUpdated,
    };
  }

  // Créer depuis Firestore
  factory UserData.fromFirestore(Map<String, dynamic> doc, String docId) {
    // Décoder le budget
    Map<String, Map<String, dynamic>> decodedBudget = {};
    if (doc['budget'] != null) {
      Map<String, dynamic> budgetData = doc['budget'];
      budgetData.forEach((key, value) {
        decodedBudget[key] = {
          'percent': (value['percent'] as num).toDouble(),
          'amount': (value['amount'] as num).toDouble(),
          'icon': IconData(value['icon'], fontFamily: 'MaterialIcons'),
          'color': Color(value['color']),
          'spent': (value['spent'] as num?)?.toDouble() ?? 0.0,
        };
      });
    }

    // Décoder les transactions
    List<Transaction> decodedTransactions = [];
    if (doc['transactions'] != null) {
      List<dynamic> transactionsData = doc['transactions'];
      decodedTransactions = transactionsData
          .map((item) => Transaction.fromJson(item))
          .toList();
    }

    // Décoder les objectifs financiers - NOUVEAU
    List<FinancialGoal> decodedGoals = [];
    if (doc['financialGoals'] != null) {
      List<dynamic> goalsData = doc['financialGoals'];
      decodedGoals = goalsData
          .map((item) => FinancialGoal.fromJson(item))
          .toList();
    }

    return UserData(
      userId: doc['userId'] ?? docId,
      salary: (doc['salary'] as num?)?.toDouble() ?? 0.0,
      currency: doc['currency'] ?? 'XOF',
      budget: decodedBudget,
      transactions: decodedTransactions,
      financialGoals: decodedGoals, // NOUVEAU
      notificationsEnabled: doc['notificationsEnabled'] ?? false,
      lastUpdated: doc['lastUpdated']?.toDate() ?? DateTime.now(),
    );
  }

  // Créer une instance vide pour un nouvel utilisateur
  factory UserData.empty(String userId) {
    return UserData(
      userId: userId,
      salary: 0.0,
      currency: 'XOF',
      budget: _getDefaultBudget(),
      transactions: [],
      financialGoals: [], // NOUVEAU
      notificationsEnabled: false,
      lastUpdated: DateTime.now(),
    );
  }

  // Budget par défaut
  static Map<String, Map<String, dynamic>> _getDefaultBudget() {
    return {
      'Loyer': {
        'percent': 0.30,
        'amount': 0.0,
        'icon': Icons.home_work_outlined,
        'color': const Color(0xFF00A9A9),
        'spent': 0.0,
      },
      'Transport': {
        'percent': 0.10,
        'amount': 0.0,
        'icon': Icons.directions_bus_filled_outlined,
        'color': const Color(0xFF4CAF50),
        'spent': 0.0,
      },
      'Électricité/Eau': {
        'percent': 0.07,
        'amount': 0.0,
        'icon': Icons.lightbulb_outline,
        'color': const Color(0xFFFFC107),
        'spent': 0.0,
      },
      'Internet': {
        'percent': 0.05,
        'amount': 0.0,
        'icon': Icons.wifi,
        'color': const Color(0xFF673AB7),
        'spent': 0.0,
      },
      'Nourriture': {
        'percent': 0.15,
        'amount': 0.0,
        'icon': Icons.restaurant_menu_outlined,
        'color': const Color(0xFFE91E63),
        'spent': 0.0,
      },
      'Loisirs': {
        'percent': 0.08,
        'amount': 0.0,
        'icon': Icons.sports_esports_outlined,
        'color': const Color(0xFF9C27B0),
        'spent': 0.0,
      },
      'Épargne': {
        'percent': 0.25,
        'amount': 0.0,
        'icon': Icons.savings_outlined,
        'color': const Color(0xFF00796B),
        'spent': 0.0,
      },
    };
  }

  // Créer une copie avec des modifications
  UserData copyWith({
    double? salary,
    String? currency,
    Map<String, Map<String, dynamic>>? budget,
    List<Transaction>? transactions,
    List<FinancialGoal>? financialGoals, // NOUVEAU
    bool? notificationsEnabled,
  }) {
    return UserData(
      userId: userId,
      salary: salary ?? this.salary,
      currency: currency ?? this.currency,
      budget: budget ?? this.budget,
      transactions: transactions ?? this.transactions,
      financialGoals: financialGoals ?? this.financialGoals, // NOUVEAU
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: DateTime.now(),
    );
  }
}