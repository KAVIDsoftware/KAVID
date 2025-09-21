import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_entry.dart';

class GastosLocalStore {
  static const _key = 'kavid_gastos_diarios';

  Future<List<ExpenseEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = json.decode(raw) as List;
      return decoded
          .map((e) => ExpenseEntry.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Si JSON corrupto o mal formato, limpiamos
      await prefs.remove(_key);
      return [];
    }
  }

  Future<void> saveAll(List<ExpenseEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> add(ExpenseEntry entry) async {
    final all = await loadAll();
    all.add(entry);
    await saveAll(all);
  }

  Future<void> removeById(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }
}
