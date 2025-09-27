import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/gastos_local_store.dart';

const kOrange = Color(0xFFFF9800);

class TicketsSummaryPage extends StatefulWidget {
  const TicketsSummaryPage({super.key});

  @override
  State<TicketsSummaryPage> createState() => _TicketsSummaryPageState();
}

enum TicketFilter { today, week, month }

class _TicketsSummaryPageState extends State<TicketsSummaryPage> {
  TicketFilter _filter = TicketFilter.today;
  List<Ticket> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await GastosLocalStore.instance.getAll();
    setState(() => _all = list);
  }

  bool _sameYmd(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Ticket> get _filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_filter == TicketFilter.today) {
      return _all.where((t) => _sameYmd(t.date, today)).toList();
    } else if (_filter == TicketFilter.week) {
      final start = today.subtract(Duration(days: (today.weekday - 1) % 7));
      final end = start.add(const Duration(days: 7));
      return _all.where((t) => !t.date.isBefore(start) && t.date.isBefore(end)).toList();
    } else {
      final start = DateTime(today.year, today.month, 1);
      final end = DateTime(today.year, today.month + 1, 1);
      return _all.where((t) => !t.date.isBefore(start) && t.date.isBefore(end)).toList();
    }
  }

  double get _total => _filtered.fold(0.0, (s, t) => s + t.amount);

  Future<void> _delete(Ticket t) async {
    await GastosLocalStore.instance.delete(t.id);
    await _load();
  }

  Future<void> _edit(Ticket t) async {
    final merchantCtrl = TextEditingController(text: t.merchant == '—' ? '' : t.merchant);
    final amountCtrl = TextEditingController(text: t.amount.toStringAsFixed(2));
    DateTime selectedDate = t.date;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: merchantCtrl,
              decoration: const InputDecoration(labelText: 'Establecimiento'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Importe'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(DateFormat('dd/MM/yyyy').format(selectedDate))),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(now.year - 3),
                      lastDate: DateTime(now.year + 3),
                      helpText: 'Selecciona fecha',
                    );
                    if (picked != null) {
                      selectedDate = DateTime(picked.year, picked.month, picked.day);
                      (ctx as Element).markNeedsBuild();
                    }
                  },
                  child: const Text('Cambiar fecha'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final newMerchant = merchantCtrl.text.trim().isEmpty ? '—' : merchantCtrl.text.trim();
    final newAmount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '.')) ?? t.amount;

    final updated = t.copyWith(
      merchant: newMerchant,
      amount: newAmount,
      date: selectedDate,
    );

    await GastosLocalStore.instance.update(updated);
    await _load();
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  String _money(double v) =>
      NumberFormat.currency(symbol: '€', decimalDigits: 2, locale: 'es_ES').format(v);

  Widget _chip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? kOrange : Colors.white,
          border: Border.all(color: kOrange),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : kOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _chip('Hoy', _filter == TicketFilter.today,
                          () => setState(() => _filter = TicketFilter.today)),
                  _chip('Semana', _filter == TicketFilter.week,
                          () => setState(() => _filter = TicketFilter.week)),
                  _chip('Mes', _filter == TicketFilter.month,
                          () => setState(() => _filter = TicketFilter.month)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: kOrange),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.receipt_long, size: 18, color: kOrange),
                      const SizedBox(width: 6),
                      Text('${items.length}',
                          style: const TextStyle(color: kOrange, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kOrange),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total acumulado', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(_money(_total), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ...items.map((t) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kOrange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt, color: kOrange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.merchant,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('${_money(t.amount)} · ${_fmt(t.date)}',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black54),
                      onPressed: () => _edit(t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async => _delete(t),
                    ),
                  ],
                ),
              );
            }),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No hay tickets en este periodo',
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
