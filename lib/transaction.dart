class Transaction {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  // Conversion en JSON pour sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  // Création depuis JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      category: json['category'],
      amount: json['amount'],
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}