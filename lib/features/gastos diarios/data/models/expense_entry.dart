import 'dart:convert';

class ExpenseEntry {
  final String id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String merchant;
  final String? imagePath;

  ExpenseEntry({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.merchant,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'paymentMethod': paymentMethod,
    'merchant': merchant,
    'imagePath': imagePath,
  };

  factory ExpenseEntry.fromMap(Map<String, dynamic> map) {
    return ExpenseEntry(
      id: map['id'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      paymentMethod: map['paymentMethod'] as String? ?? 'Tarjeta',
      merchant: map['merchant'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseEntry.fromJson(String source) =>
      ExpenseEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
