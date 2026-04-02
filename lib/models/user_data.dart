import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:smartspend/utils/icon_utils.dart';
import 'transaction.dart';
import 'financial_goal.dart';

/// Données d'un mois clôturé (historique)
class MonthlyData {
  final int year;
  final int month;
  final double salary;
  final Map<String, Map<String, dynamic>> budget;
  final List<Transaction> transactions;
  final DateTime closedAt;

  MonthlyData({
    required this.year,
    required this.month,
    required this.salary,
    required this.budget,
    required this.transactions,
    required this.closedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'salary': salary,
      'budget': budget.map((key, value) => MapEntry(key, {
        'percent': value['percent'],
        'amount': value['amount'],
        'icon': (value['icon'] as IconData).codePoint,
        'color': (value['color'] as Color).value,
        'spent': value['spent'],
      })),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'closedAt': closedAt.toIso8601String(),
    };
  }

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    final Map<String, Map<String, dynamic>> budget = {};
    if (json['budget'] != null) {
      final budgetData = json['budget'] as Map<String, dynamic>;
      budgetData.forEach((key, value) {
        budget[key] = {
          'percent': (value['percent'] as num?)?.toDouble() ?? 0.0,
          'amount': (value['amount'] as num?)?.toDouble() ?? 0.0,
          'icon': IconUtils.getIconFromCode(value['icon'] as int? ?? 0xe88a),
          'color': Color(value['color'] as int? ?? 0xFF00A9A9),
          'spent': (value['spent'] as num?)?.toDouble() ?? 0.0,
        };
      });
    }

    final List<Transaction> transactions = [];
    if (json['transactions'] != null) {
      final transactionsList = json['transactions'] as List<dynamic>;
      transactions.addAll(
          transactionsList.map((t) => Transaction.fromJson(t as Map<String, dynamic>))
      );
    }

    return MonthlyData(
      year: json['year'] as int,
      month: json['month'] as int,
      salary: (json['salary'] as num).toDouble(),
      budget: budget,
      transactions: transactions,
      closedAt: DateTime.parse(json['closedAt'] as String),
    );
  }

  /// Calcul du total des dépenses du mois
  double get totalSpent => transactions.fold(0.0, (sum, t) => sum + t.amount);

  /// Calcul du reste (épargne réelle)
  double get remaining => salary - totalSpent;

  /// Nom du mois en français
  String get monthName {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }
}

class UserData {
  final String userId;
  final double salary;
  final String currency;
  final Map<String, Map<String, dynamic>> budget;
  final List<Transaction> transactions;
  final List<FinancialGoal> financialGoals;
  final DateTime lastUpdated;

  // Gestion des mois
  final int activeMonth; // 1-12
  final int activeYear;
  final List<MonthlyData> monthlyHistory; // Historique des mois clôturés

  // Premium
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
    required this.financialGoals,
    required this.lastUpdated,
    required this.activeMonth,
    required this.activeYear,
    this.monthlyHistory = const [],
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
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'financialGoals': financialGoals.map((g) => g.toJson()).toList(),
      // Gestion des mois
      'activeMonth': activeMonth,
      'activeYear': activeYear,
      'monthlyHistory': monthlyHistory.map((m) => m.toJson()).toList(),
      // Propriétés Premium
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
          'percent': (value['percent'] as num?)?.toDouble() ?? 0.0,
          'amount': (value['amount'] as num?)?.toDouble() ?? 0.0,
          'icon': IconUtils.getIconFromCode(value['icon'] as int? ?? 0xe88a),
          'color': Color(value['color'] as int? ?? 0xFF00A9A9),
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

    // Conversion de l'historique mensuel
    final List<MonthlyData> monthlyHistory = [];
    if (data['monthlyHistory'] != null) {
      final historyList = data['monthlyHistory'] as List<dynamic>;
      monthlyHistory.addAll(
          historyList.map((h) => MonthlyData.fromJson(h as Map<String, dynamic>))
      );
    }

    final now = DateTime.now();

    return UserData(
      userId: userId,
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'XOF',
      budget: budget,
      transactions: transactions,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      financialGoals: financialGoals,
      // Gestion des mois (migration: utiliser le mois actuel si pas défini)
      activeMonth: data['activeMonth'] as int? ?? now.month,
      activeYear: data['activeYear'] as int? ?? now.year,
      monthlyHistory: monthlyHistory,
      // Propriétés Premium
      isPremium: data['isPremium'] as bool? ?? false,
      premiumExpiryDate: (data['premiumExpiryDate'] as Timestamp?)?.toDate(),
      pdfExportsUsed: data['pdfExportsUsed'] as int? ?? 0,
      chatbotUsesUsed: data['chatbotUsesUsed'] as int? ?? 0,
    );
  }

  // Créer une instance vide pour un nouvel utilisateur
  factory UserData.empty(String userId) {
    final now = DateTime.now();
    return UserData(
      userId: userId,
      salary: 0.0,
      currency: 'XOF',
      budget: _getDefaultBudget(),
      transactions: [],
      lastUpdated: now,
      financialGoals: [],
      activeMonth: now.month,
      activeYear: now.year,
      monthlyHistory: [],
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
        'icon': Icons.home_rounded,
        'color': const Color(0xFF00A9A9),
        'spent': 0.0,
      },
      'Transport': {
        'percent': 0.10,
        'amount': 0.0,
        'icon': Icons.directions_car_rounded,
        'color': const Color(0xFF4CAF50),
        'spent': 0.0,
      },
      'Électricité/Eau': {
        'percent': 0.07,
        'amount': 0.0,
        'icon': Icons.lightbulb_rounded,
        'color': const Color(0xFFFFC107),
        'spent': 0.0,
      },
      'Internet': {
        'percent': 0.05,
        'amount': 0.0,
        'icon': Icons.wifi_rounded,
        'color': const Color(0xFF673AB7),
        'spent': 0.0,
      },
      'Nourriture': {
        'percent': 0.15,
        'amount': 0.0,
        'icon': Icons.restaurant_rounded,
        'color': const Color(0xFFE91E63),
        'spent': 0.0,
      },
      'Loisirs': {
        'percent': 0.08,
        'amount': 0.0,
        'icon': Icons.sports_esports_rounded,
        'color': const Color(0xFF9C27B0),
        'spent': 0.0,
      },
      'Épargne': {
        'percent': 0.25,
        'amount': 0.0,
        'icon': Icons.savings_rounded,
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
    DateTime? lastUpdated,
    List<FinancialGoal>? financialGoals,
    int? activeMonth,
    int? activeYear,
    List<MonthlyData>? monthlyHistory,
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
      lastUpdated: lastUpdated ?? this.lastUpdated,
      financialGoals: financialGoals ?? this.financialGoals,
      activeMonth: activeMonth ?? this.activeMonth,
      activeYear: activeYear ?? this.activeYear,
      monthlyHistory: monthlyHistory ?? this.monthlyHistory,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      pdfExportsUsed: pdfExportsUsed ?? this.pdfExportsUsed,
      chatbotUsesUsed: chatbotUsesUsed ?? this.chatbotUsesUsed,
    );
  }

  /// Vérifie si un nouveau mois a commencé (par rapport au mois actif)
  bool get isNewMonthStarted {
    final now = DateTime.now();
    return now.year > activeYear || (now.year == activeYear && now.month > activeMonth);
  }

  /// Nom du mois actif (en français)
  String get activeMonthName {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[activeMonth - 1]} $activeYear';
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