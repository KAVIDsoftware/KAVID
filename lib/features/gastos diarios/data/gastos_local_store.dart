// lib/features/gastos diarios/data/local/gastos_local_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Ticket {
  final String id;
  final String merchant;
  final double amount;
  final DateTime date;
  final String? imagePath;

  const Ticket({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    this.imagePath,
  });

  Ticket copyWith({
    String? id,
    String? merchant,
    double? amount,
    DateTime? date,
    String? imagePath,
  }) {
    return Ticket(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      date: date != null ? DateTime(date.year, date.month, date.day) : this.date,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant': merchant,
    'amount': amount,
    'date': DateTime(date.year, date.month, date.day).toIso8601String(),
    'imagePath': imagePath,
  };

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
    id: j['id'] as String,
    merchant: (j['merchant'] as String?) ?? '—',
    amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
    date: DateTime.parse(j['date'] as String).toLocal(),
    imagePath: j['imagePath'] as String?,
  );
}

class GastosLocalStore {
  GastosLocalStore._();
  static final GastosLocalStore instance = GastosLocalStore._();

  static const _kKey = 'tickets_store_v1';

  Future<List<Ticket>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final items = list.map((e) => Ticket.fromJson(e)).toList();

    return items
        .map((t) => Ticket(
      id: t.id,
      merchant: t.merchant,
      amount: t.amount,
      date: DateTime(t.date.year, t.date.month, t.date.day),
      imagePath: t.imagePath,
    ))
        .toList();
  }

  Future<void> _saveAll(List<Ticket> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, raw);
  }

  Future<void> add(Ticket t) async {
    final items = await getAll();
    items.add(t);
    await _saveAll(items);
  }

  Future<void> update(Ticket t) async {
    final items = await getAll();
    final idx = items.indexWhere((e) => e.id == t.id);
    if (idx >= 0) {
      items[idx] = t;
      await _saveAll(items);
    }
  }

  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((e) => e.id == id);
    await _saveAll(items);
  }
}
