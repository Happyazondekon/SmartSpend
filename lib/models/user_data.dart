import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
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

  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final int pdfExportsUsed;
  final int chatbotUsesUsed;

  UserData({
    required this.userId,
    required this.salary,
    required this.currency,
    required this.budget,
    required this.transactions,
    required this.financialGoals, // NOUVEAU
    required this.notificationsEnabled,
    required this.lastUpdated,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.pdfExportsUsed = 0,
    this.chatbotUsesUsed = 0,
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'salary': salary,
      'currency': currency,
      'budget': budget.map((key, value) => MapEntry(key, {
        'percent': value['percent'],
        'amount': value['amount'],
        'icon': (value['icon'] as IconData).codePoint,
        'color': (value['color'] as Color).value,
        'spent': value['spent'],
      })),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'notificationsEnabled': notificationsEnabled,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'financialGoals': financialGoals.map((g) => g.toJson()).toList(),
      // Nouvelles propriétés Premium
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate != null ? Timestamp.fromDate(premiumExpiryDate!) : null,
      'pdfExportsUsed': pdfExportsUsed,
      'chatbotUsesUsed': chatbotUsesUsed,
    };
  }

  // Créer depuis Firestore
  factory UserData.fromFirestore(Map<String, dynamic> data, String userId) {
    // Conversion du budget
    final Map<String, Map<String, dynamic>> budget = {};
    if (data['budget'] != null) {
      final budgetData = data['budget'] as Map<String, dynamic>;
      budgetData.forEach((key, value) {
        budget[key] = {
          'percent': (value['percent'] as num).toDouble(),
          'amount': (value['amount'] as num).toDouble(),
          'icon': IconData(value['icon'] as int, fontFamily: 'MaterialIcons'),
          'color': Color(value['color'] as int),
          'spent': (value['spent'] as num?)?.toDouble() ?? 0.0,
        };
      });
    }

    // Conversion des transactions
    final List<Transaction> transactions = [];
    if (data['transactions'] != null) {
      final transactionsList = data['transactions'] as List<dynamic>;
      transactions.addAll(
          transactionsList.map((t) => Transaction.fromJson(t as Map<String, dynamic>))
      );
    }

    // Conversion des objectifs financiers
    final List<FinancialGoal> financialGoals = [];
    if (data['financialGoals'] != null) {
      final goalsList = data['financialGoals'] as List<dynamic>;
      financialGoals.addAll(
          goalsList.map((g) => FinancialGoal.fromJson(g as Map<String, dynamic>))
      );
    }

    return UserData(
      userId: userId,
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'XOF',
      budget: budget,
      transactions: transactions,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      financialGoals: financialGoals,
      // Nouvelles propriétés Premium
      isPremium: data['isPremium'] as bool? ?? false,
      premiumExpiryDate: (data['premiumExpiryDate'] as Timestamp?)?.toDate(),
      pdfExportsUsed: data['pdfExportsUsed'] as int? ?? 0,
      chatbotUsesUsed: data['chatbotUsesUsed'] as int? ?? 0,
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
      notificationsEnabled: false,
      lastUpdated: DateTime.now(),
      financialGoals: [],
      isPremium: false,
      premiumExpiryDate: null,
      pdfExportsUsed: 0,
      chatbotUsesUsed: 0,
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
    String? userId,
    double? salary,
    String? currency,
    Map<String, Map<String, dynamic>>? budget,
    List<Transaction>? transactions,
    bool? notificationsEnabled,
    DateTime? lastUpdated,
    List<FinancialGoal>? financialGoals,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    int? pdfExportsUsed,
    int? chatbotUsesUsed,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      salary: salary ?? this.salary,
      currency: currency ?? this.currency,
      budget: budget ?? this.budget,
      transactions: transactions ?? this.transactions,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      financialGoals: financialGoals ?? this.financialGoals,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      pdfExportsUsed: pdfExportsUsed ?? this.pdfExportsUsed,
      chatbotUsesUsed: chatbotUsesUsed ?? this.chatbotUsesUsed,
    );
  }
  // Méthode pour vérifier si l'utilisateur est Premium actif
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return isPremium;
    return premiumExpiryDate!.isAfter(DateTime.now());
  }

  // Méthode pour obtenir les jours restants de Premium
  int get premiumDaysRemaining {
    if (!isPremium || premiumExpiryDate == null) return 0;
    final difference = premiumExpiryDate!.difference(DateTime.now());
    return difference.inDays.clamp(0, double.infinity).toInt();
  }
}