import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/gastos_local_store.dart';
import '../../data/models/expense_entry.dart';

const kOrange = Color(0xFFFF9800);

class ManualInputTab extends StatefulWidget {
  final Future<void> Function() onSaved;
  const ManualInputTab({super.key, required this.onSaved});

  @override
  State<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends State<ManualInputTab> {
  final _formKey = GlobalKey<FormState>();

  final _descCtrl = TextEditingController();
  final _catCtrl = TextEditingController(text: 'General');
  final _amountCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  String _payment = 'Tarjeta';

  final _store = GastosLocalStore();

  @override
  void dispose() {
    _descCtrl.dispose();
    _catCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
      helpText: 'Selecciona fecha del gasto',
      locale: const Locale('es', 'ES'),
    );
    if (d != null) {
      setState(() {
        _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importe inválido')),
      );
      return;
    }

    final entry = ExpenseEntry(
      id: const Uuid().v4(),
      description: _descCtrl.text.trim().isEmpty ? 'Gasto' : _descCtrl.text.trim(),
      category: _catCtrl.text.trim().isEmpty ? 'General' : _catCtrl.text.trim(),
      amount: amount,
      date: _date,
      paymentMethod: _payment,
      merchant: '',
      imagePath: null,
    );

    await _store.add(entry);
    await widget.onSaved();

    _formKey.currentState?.reset();
    setState(() {
      _catCtrl.text = 'General';
      _payment = 'Tarjeta';
      _date = DateTime.now();
      _amountCtrl.clear();
      _descCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Descripción
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // Categoría
            TextFormField(
              controller: _catCtrl,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // Importe
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Importe (€)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Importe inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Fecha
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(df.format(_date)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _pickDate,
                  child: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Método de pago (usar initialValue)
            DropdownButtonFormField<String>(
              initialValue: _payment,
              items: const [
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (v) => setState(() => _payment = v ?? 'Tarjeta'),
              decoration: const InputDecoration(
                labelText: 'Método de pago',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Guardar
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: _save,
              child: const Text('Guardar gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
