import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/local/gastos_local_store.dart';
import '../../data/models/expense_entry.dart';
import '../widgets/ocr_input_tab.dart';
import '../widgets/manual_input_tab.dart';

const kOrange = Color(0xFFFF9800);

enum RangeFilter { today, week, month, all }

class GastosDiariosPage extends StatefulWidget {
  const GastosDiariosPage({super.key});

  @override
  State<GastosDiariosPage> createState() => _GastosDiariosPageState();
}

class _GastosDiariosPageState extends State<GastosDiariosPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _store = GastosLocalStore();

  List<ExpenseEntry> _all = [];
  RangeFilter _filter = RangeFilter.today;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reload();
  }

  Future<void> _reload() async {
    final data = await _store.loadAll();
    setState(() {
      _all = data..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _onSaved() async {
    await _reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto guardado')),
      );
    }
  }

  bool _inToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _inWeek(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: now.weekday - 1)); // lunes
    final end = start.add(const Duration(days: 7));
    return !d.isBefore(start) && d.isBefore(end);
  }

  bool _inMonth(DateTime d) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return !d.isBefore(start) && d.isBefore(end);
  }

  List<ExpenseEntry> get _filtered {
    switch (_filter) {
      case RangeFilter.today:
        return _all.where((e) => _inToday(e.date)).toList();
      case RangeFilter.week:
        return _all.where((e) => _inWeek(e.date)).toList();
      case RangeFilter.month:
        return _all.where((e) => _inMonth(e.date)).toList();
      case RangeFilter.all:
        return _all;
    }
  }

  double get _totalFiltered =>
      _filtered.fold(0.0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        title: const Text('Gastos diarios'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Escanear ticket (OCR)'),
            Tab(text: 'Entrada manual'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Pestañas
          Expanded(
            flex: 4,
            child: TabBarView(
              controller: _tabController,
              children: [
                OcrInputTab(onSaved: _onSaved),
                ManualInputTab(onSaved: _onSaved),
              ],
            ),
          ),

          // Filtro + total del rango
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12.withValues(alpha: 0.08))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    _chip(RangeFilter.today, 'Hoy'),
                    _chip(RangeFilter.week, 'Semana'),
                    _chip(RangeFilter.month, 'Mes'),
                    _chip(RangeFilter.all, 'Todo'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total del rango',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      money.format(_totalFiltered),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Listado
          Expanded(
            flex: 5,
            child: _filtered.isEmpty
                ? const Center(child: Text('No hay gastos en este rango.'))
                : ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = _filtered[i];
                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar gasto'),
                        content: const Text('¿Seguro que deseas eliminar este gasto?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ) ??
                        false;
                  },
                  onDismissed: (_) async {
                    await _store.removeById(e.id);
                    await _reload();
                  },
                  child: ListTile(
                    leading: const Icon(Icons.store_mall_directory_outlined),
                    title: Text(
                      e.merchant.isNotEmpty ? e.merchant : e.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${df.format(e.date)} · ${e.category} · ${e.paymentMethod}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      money.format(e.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kOrange,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(RangeFilter f, String label) {
    final selected = _filter == f;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = f),
      selectedColor: kOrange.withValues(alpha: 0.15),
      side: BorderSide(color: selected ? kOrange : Colors.black12),
      labelStyle: TextStyle(
        color: selected ? kOrange : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
