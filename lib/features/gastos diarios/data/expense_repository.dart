import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String merchant;
  final double amount;
  final DateTime date;
  final String? imagePath;

  Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant': merchant,
    'amount': amount,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
  };

  static Expense fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'],
    merchant: j['merchant'],
    amount: (j['amount'] as num).toDouble(),
    date: DateTime.parse(j['date']),
    imagePath: j['imagePath'],
  );
}

class ExpenseRepository {
  static const _fileName = 'expenses.json';
  static final _uuid = const Uuid();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Expense>> loadAll() async {
    final f = await _file();
    if (!await f.exists()) return [];
    final content = await f.readAsString();
    if (content.trim().isEmpty) return [];
    final list = jsonDecode(content) as List<dynamic>;
    return list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(Expense e) async {
    final list = await loadAll();
    final updated = [...list, e];
    final f = await _file();
    await f.writeAsString(jsonEncode(updated.map((x) => x.toJson()).toList()));
  }

  Expense build({
    required String merchant,
    required double amount,
    required DateTime date,
    String? imagePath,
  }) {
    return Expense(
      id: _uuid.v4(),
      merchant: merchant,
      amount: amount,
      date: date,
      imagePath: imagePath,
    );
  }

  /// ✅ NUEVO: eliminar por ID
  Future<void> deleteById(String id) async {
    final all = await loadAll();
    final updated = all.where((e) => e.id != id).toList();
    final f = await _file();
    await f.writeAsString(jsonEncode(updated.map((x) => x.toJson()).toList()));
  }

  /// ✅ NUEVO: codificar lista completa
  static String encodeList(List<Expense> list) {
    return jsonEncode(list.map((x) => x.toJson()).toList());
  }
}
