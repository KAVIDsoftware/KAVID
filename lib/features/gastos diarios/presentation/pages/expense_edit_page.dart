import 'dart:io'; // <-- NECESARIO para usar File
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/expense_entry.dart';

const kOrange = Color(0xFFFF9800);

class ExpenseEditPage extends StatefulWidget {
  const ExpenseEditPage({
    super.key,
    required this.initial,
    this.imagePath,
  });

  final ExpenseEntry initial;
  final String? imagePath;

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  late TextEditingController _merchantCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _merchantCtrl = TextEditingController(text: widget.initial.merchant);
    _amountCtrl = TextEditingController(
      text: widget.initial.amount == 0.0
          ? ''
          : NumberFormat("#0.00", "es_ES").format(widget.initial.amount),
    );
    _dateTime = widget.initial.date;
    _dateCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_dateTime),
    );
    _timeCtrl = TextEditingController(
      text: DateFormat('HH:mm').format(_dateTime),
    );
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      initialDate: _dateTime,
      helpText: 'Selecciona la fecha del ticket',
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dateTime.hour,
          _dateTime.minute,
        );
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(_dateTime);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _dateTime.hour, minute: _dateTime.minute),
      helpText: 'Selecciona la hora del ticket',
    );
    if (picked != null) {
      setState(() {
        _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          picked.hour,
          picked.minute,
        );
        _timeCtrl.text = DateFormat('HH:mm').format(_dateTime);
      });
    }
  }

  void _save() {
    final merchant = _merchantCtrl.text.trim();
    final amountStr = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '.').trim();
    final amount = double.tryParse(amountStr) ?? 0.0;

    if (merchant.isEmpty) {
      _show('Introduce el establecimiento');
      return;
    }
    if (amount <= 0) {
      _show('Introduce un importe válido');
      return;
    }

    // === Crear ExpenseEntry actualizado SIN copyWith ===
    // ⚠️ NECESITO tu constructor real de ExpenseEntry para rellenarlo correctamente.
    // Ejemplo típico (ajustaré cuando me pases el modelo):
    final updated = ExpenseEntry(
      id: widget.initial.id,
      merchant: merchant,
      description: widget.initial.description,
      amount: amount,
      date: _dateTime,
      category: widget.initial.category,
      paymentMethod: widget.initial.paymentMethod,
    );

    Navigator.of(context).pop(updated);
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        title: const Text('Editar gasto'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.imagePath != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: kOrange),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.file(
                File(widget.imagePath!),
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
          const SizedBox(height: 16),

          Text('Establecimiento', style: _labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _merchantCtrl,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('Introduce el nombre del comercio'),
          ),
          const SizedBox(height: 16),

          Text('Importe', style: _labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('0,00'),
          ),
          const SizedBox(height: 16),

          Text('Fecha y hora', style: _labelStyle),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _inputDecoration('dd/mm/aaaa').copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _timeCtrl,
                  readOnly: true,
                  onTap: _pickTime,
                  decoration: _inputDecoration('hh:mm').copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: _pickTime,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text(
                'Guardar gastos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kOrange, width: 2),
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  TextStyle get _labelStyle => const TextStyle(
    fontWeight: FontWeight.w600,
    color: kOrange,
  );
}
