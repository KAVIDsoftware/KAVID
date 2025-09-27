import 'package:flutter/material.dart';
import '../../data/expense_repository.dart';
import '../widgets/ocr_input_tab.dart';
import 'tickets_summary_page.dart';

class GastosDiariosPage extends StatefulWidget {
  const GastosDiariosPage({super.key});

  @override
  State<GastosDiariosPage> createState() => _GastosDiariosPageState();
}

class _GastosDiariosPageState extends State<GastosDiariosPage> {
  final repo = ExpenseRepository();

  // Estado OCR
  String? _merchant;
  double? _amount;
  DateTime? _date;
  String? _imagePath;

  void _onOcrChanged({
    String? merchant,
    double? amount,
    DateTime? date,
    String? imagePath,
  }) {
    setState(() {
      _merchant = merchant ?? _merchant;
      _amount = amount ?? _amount;
      _date = date ?? _date;
      _imagePath = imagePath ?? _imagePath;
    });
  }

  Future<void> _save() async {
    if (_merchant == null || _merchant!.trim().isEmpty) {
      _toast('Falta establecimiento');
      return;
    }
    if (_amount == null) {
      _toast('Falta importe');
      return;
    }

    final exp = repo.build(
      merchant: _merchant!.trim(),
      amount: _amount!,
      date: _date ?? DateTime.now(),
      imagePath: _imagePath,
    );

    await repo.save(exp);

    if (!mounted) return;

    // ✅ Navegar directamente a la pantalla resumen de tickets
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TicketsSummaryPage()),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear ticket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: OcrInputTab(
                  onChanged: _onOcrChanged,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? bottom : 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE9D6),
                    foregroundColor: const Color(0xFF7A4E18),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Guardar gastos'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
