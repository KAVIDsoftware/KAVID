import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/gastos_local_store.dart';

const kOrange = Color(0xFFFF9800);

class ManualInputTab extends StatefulWidget {
  const ManualInputTab({super.key});

  @override
  State<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends State<ManualInputTab> {
  final _merchantCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      helpText: 'Selecciona fecha',
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    final merchant = _merchantCtrl.text.trim().isEmpty ? '—' : _merchantCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    final ticket = Ticket(
      id: const Uuid().v4(),
      merchant: merchant,
      amount: amount,
      date: _date,
      imagePath: null,
    );

    await GastosLocalStore.instance.add(ticket);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto guardado')),
    );

    setState(() {
      _merchantCtrl.clear();
      _amountCtrl.clear();
      _date = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dd = _date.day.toString().padLeft(2, '0');
    final mm = _date.month.toString().padLeft(2, '0');
    final yyyy = _date.year.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _merchantCtrl,
          decoration: const InputDecoration(
            labelText: 'Establecimiento',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Importe',
            hintText: 'Ej: 7.44',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: kOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$dd/$mm/$yyyy'),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _pickDate,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kOrange,
              ),
              child: const Text('Cambiar fecha'),
            )
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: kOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: const Text('Guardar manual'),
        ),
      ],
    );
  }
}
