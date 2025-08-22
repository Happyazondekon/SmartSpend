// models/financial_goal.dart
import 'package:flutter/material.dart';

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdDate;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.createdDate,
    this.description = '',
    this.icon = Icons.savings_outlined,
    this.color = const Color(0xFF4CAF50),
    this.isCompleted = false,
  });

  // Calculer le pourcentage de progression
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  // Calculer le montant restant à épargner
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  // Calculer le nombre de jours restants
  int get daysRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  // Calculer le montant à épargner par jour
  double get dailySavingsNeeded {
    if (daysRemaining <= 0) return remainingAmount;
    return remainingAmount / daysRemaining;
  }

  // Calculer le montant à épargner par mois
  double get monthlySavingsNeeded {
    if (daysRemaining <= 0) return remainingAmount;
    final monthsRemaining = (daysRemaining / 30.0).ceil();
    return remainingAmount / monthsRemaining;
  }

  // Vérifier si l'objectif est en retard
  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && !isCompleted;
  }

  // Vérifier si l'objectif est proche de l'échéance (moins de 30 jours)
  bool get isNearDeadline {
    return daysRemaining <= 30 && daysRemaining > 0 && !isCompleted;
  }

  // Convertir en JSON pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'isCompleted': isCompleted,
    };
  }

  // Créer depuis JSON
  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      name: json['name'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate']),
      createdDate: DateTime.parse(json['createdDate']),
      description: json['description'] ?? '',
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Créer une copie avec des modifications
  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdDate,
    String? description,
    IconData? icon,
    Color? color,
    bool? isCompleted,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdDate: createdDate ?? this.createdDate,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}