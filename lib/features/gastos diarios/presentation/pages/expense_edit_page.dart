// lib/features/gastos diarios/presentation/pages/expense_edit_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../gastos diarios/data/models/expense_entry.dart';
import '../../data/local/ocr_corrections_store.dart';

class ExpenseEditPage extends StatefulWidget {
  final ExpenseEntry? initial;
  final String? imagePath;
  final File? imageFile;
  final String? initialMerchant;
  final double? initialAmount;
  final DateTime? initialDate;
  final String? ocrCif;
  final String? ocrHash;

  const ExpenseEditPage({
    super.key,
    this.initial,
    this.imagePath,
    this.imageFile,
    this.initialMerchant,
    this.initialAmount,
    this.initialDate,
    this.ocrCif,
    this.ocrHash,
  });

  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _amountCtrl;
  late DateTime _date;
  File? _image;
  final _store = const OcrCorrectionsStore();

  bool _has(String? s) => s != null && s.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _image = widget.imageFile ?? (_has(widget.imagePath) ? File(widget.imagePath!) : null);

    final a = widget.initial;
    final merchant = _has(a?.merchant) ? a!.merchant : (_has(widget.initialMerchant) ? widget.initialMerchant! : '');
    final amount = a?.amount ?? widget.initialAmount ?? 0.0;
    final date = a?.date ?? widget.initialDate ?? DateUtils.dateOnly(DateTime.now());

    _merchantCtrl = TextEditingController(text: merchant);
    _amountCtrl = TextEditingController(text: amount == 0.0 ? '' : amount.toStringAsFixed(2));
    _date = DateUtils.dateOnly(date);
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _editField(String title, TextEditingController c, {TextInputType? input}) async {
    final nav = Navigator.of(context);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final t = TextEditingController(text: c.text);
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: t,
            keyboardType: input,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(t.text.trim()), child: const Text('Aceptar')),
          ],
        );
      },
    );
    if (!mounted) return;
    if (res != null) {
      setState(() => c.text = res);
      ScaffoldMessenger.of(nav.context).showSnackBar(const SnackBar(content: Text('Campo actualizado')));
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (d != null) setState(() => _date = DateUtils.dateOnly(d));
  }

  ExpenseEntry _buildEntry() {
    final base = widget.initial ??
        ExpenseEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          merchant: '',
          description: '',
          amount: 0.0,
          date: DateUtils.dateOnly(DateTime.now()),
          category: 'General',
          paymentMethod: 'Desconocido',
        );

    final amt = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;

    return ExpenseEntry(
      id: base.id,
      merchant: _merchantCtrl.text.trim(),
      description: base.description,
      amount: amt,
      date: _date,
      category: base.category,
      paymentMethod: base.paymentMethod,
    );
  }

  Future<void> _rememberIfChanged(ExpenseEntry before, ExpenseEntry after) async {
    if (after.merchant.trim().isEmpty) return;
    if (before.merchant.trim() == after.merchant.trim()) return;
    if (_has(widget.ocrCif)) {
      await _store.saveByCif(widget.ocrCif!, after.merchant.trim());
    } else if (_has(widget.ocrHash)) {
      await _store.saveByHash(widget.ocrHash!, after.merchant.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return PopScope(
      canPop: true, // reemplaza WillPopScope
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escanear ticket'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => nav.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.file(_image!, height: 170, fit: BoxFit.cover),
                ),
              _RowEdit('Establecimiento', _merchantCtrl, () => _editField('Editar establecimiento', _merchantCtrl)),
              const SizedBox(height: 12),
              _RowEdit(
                'Importe',
                _amountCtrl,
                    () => _editField('Editar importe', _amountCtrl, input: const TextInputType.numberWithOptions(decimal: true)),
                input: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              _RowDate('Fecha', _date, _pickDate),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final before = widget.initial ??
                      ExpenseEntry(
                        id: '',
                        merchant: '',
                        description: '',
                        amount: 0.0,
                        date: DateUtils.dateOnly(DateTime.now()),
                        category: 'General',
                        paymentMethod: 'Desconocido',
                      );
                  final entry = _buildEntry();
                  await _rememberIfChanged(before, entry);
                  if (!mounted) return;
                  nav.pop<ExpenseEntry>(entry);
                },
                child: const Text('Guardar gastos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowEdit extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback onChange;
  final TextInputType? input;
  const _RowEdit(this.title, this.controller, this.onChange, {this.input});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: input,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onChange, child: const Text('Cambiar')),
          ],
        ),
      ],
    );
  }
}

class _RowDate extends StatelessWidget {
  final String title;
  final DateTime date;
  final VoidCallback onTap;
  const _RowDate(this.title, this.date, this.onTap);

  @override
  Widget build(BuildContext context) {
    final txt = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                child: Text(txt),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onTap, child: const Text('Cambiar')),
          ],
        ),
      ],
    );
  }
}
