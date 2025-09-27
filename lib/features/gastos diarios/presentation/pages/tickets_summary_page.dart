import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../gastos diarios/data/expense_repository.dart';

class TicketsSummaryPage extends StatefulWidget {
  const TicketsSummaryPage({super.key});

  @override
  State<TicketsSummaryPage> createState() => _TicketsSummaryPageState();
}

class _TicketsSummaryPageState extends State<TicketsSummaryPage> {
  final ExpenseRepository _repo = ExpenseRepository();
  List<Expense> _allTickets = [];
  String _filter = 'hoy';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final loaded = await _repo.loadAll();
    setState(() => _allTickets = loaded);
  }

  List<Expense> get _filtered {
    final now = DateTime.now();
    return _allTickets.where((e) {
      if (_filter == 'hoy') {
        return e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day;
      } else if (_filter == 'semana') {
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end.add(const Duration(days: 1)));
      } else {
        return e.date.year == now.year && e.date.month == now.month;
      }
    }).toList();
  }

  double get _total => _filtered.fold(0.0, (sum, e) => sum + e.amount);

  void _setFilter(String f) => setState(() => _filter = f);

  static const kOrange = Color(0xFFFF9800);

  Future<void> _delete(String id) async {
    await _repo.deleteById(id);
    await _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Tickets')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filtros + contador
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterChip('Hoy', 'hoy'),
                const SizedBox(width: 8),
                _filterChip('Semana', 'semana'),
                const SizedBox(width: 8),
                _filterChip('Mes', 'mes'),
                const SizedBox(width: 12),
                Chip(
                  label: Row(
                    children: [
                      const Icon(Icons.receipt_long, size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '${tickets.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: kOrange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total acumulado
            Text(
              'Total: ${_total.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Lista de tickets
            Expanded(
              child: tickets.isEmpty
                  ? const Center(child: Text('No hay tickets en este filtro.'))
                  : ListView.separated(
                itemCount: tickets.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final e = tickets[i];
                  return ListTile(
                    leading: const Icon(Icons.receipt_long, color: kOrange),
                    title: Text(e.merchant),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yyyy').format(e.date)} · ${e.amount.toStringAsFixed(2)} €',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {
                            // TODO: implementar edición
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(e.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: kOrange,
      onSelected: (_) => _setFilter(value),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }
}
