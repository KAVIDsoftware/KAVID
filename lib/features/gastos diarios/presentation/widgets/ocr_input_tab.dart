import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/gastos_local_store.dart';
import '../../data/models/expense_entry.dart';

const kOrange = Color(0xFFFF9800);

class OcrInputTab extends StatefulWidget {
  final Future<void> Function() onSaved;
  const OcrInputTab({super.key, required this.onSaved});

  @override
  State<OcrInputTab> createState() => _OcrInputTabState();
}

class _OcrInputTabState extends State<OcrInputTab> {
  final _picker = ImagePicker();
  final _store = GastosLocalStore();

  File? _imageFile;
  bool _processing = false;

  // Campos OCR editables
  final _merchantCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime? _date;

  // Extras
  final _descriptionCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController(text: 'General');
  String _paymentMethod = 'Tarjeta';

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool camera) async {
    final XFile? x = await (camera
        ? _picker.pickImage(source: ImageSource.camera, imageQuality: 85)
        : _picker.pickImage(source: ImageSource.gallery, imageQuality: 85));
    if (x == null) return;

    setState(() {
      _imageFile = File(x.path);
      _processing = true;
      _merchantCtrl.clear();
      _amountCtrl.clear();
      _date = null;
      _descriptionCtrl.clear();
    });

    await _runOcr(_imageFile!);

    if (mounted) setState(() => _processing = false);
  }

  Future<void> _runOcr(File file) async {
    final inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final result = await textRecognizer.processImage(inputImage);
      final rawText = result.text;

      // Líneas originales y normalizadas
      final originalLines = rawText
          .split(RegExp(r'\r?\n'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<String> norm(List<String> ls) =>
          ls.map(_normalize).where((l) => l.isNotEmpty).toList();

      final lines = norm(originalLines);

      // ===== 1) IMPORTE =====
      final avoid = RegExp(r'\b(SUBTOTAL|IVA|PROPINA|AUTORIZAD|REFEREN|APROBAD)\b', caseSensitive: false);
      final kw = RegExp(r'\b(TOTAL|IMPORTE|EUR)\b|€');
      final money = RegExp(r'([€$]?\s*[0-9]+(?:[.,][0-9]{2})?)');

      double? amount;

      for (int i = lines.length - 1; i >= 0; i--) {
        final l = lines[i];
        if (!kw.hasMatch(l)) continue;
        if (avoid.hasMatch(l)) continue;

        final all = money.allMatches(l).toList();
        if (all.isEmpty) continue;

        final raw = all.last.group(1) ?? '';
        final v = _parseAmount(raw);
        if (v != null && v > 0.1) {
          amount = v;
          break;
        }
      }

      amount ??= _findLargestAmount(lines);

      // ===== 2) FECHA =====
      final dateRegex = RegExp(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b');
      DateTime dateResult = DateTime.now();
      for (final l in lines) {
        final m = dateRegex.firstMatch(l);
        if (m != null) {
          final d = m.group(1);
          final mm = m.group(2);
          final y = m.group(3);
          if (d != null && mm != null && y != null) {
            dateResult = _parseDate('$d/$mm/$y') ?? dateResult;
            break;
          }
        }
      }

      // ===== 3) COMERCIO =====
      final noise = RegExp(
        r'\b(BBVA|SANTANDER|VISA|MASTERCARD|AMEX|TPV|TICKET|FACTURA|VENTA|AUTORIZ|APROBAD|CLIENTE|COMERCIO:|REF(\.|ERENCIA)?|N\.\s*OPERAC|TERMINAL|BANCO)\b',
        caseSensitive: false,
      );

      String merchant = '';
      final limit = originalLines.length < 8 ? originalLines.length : 8;
      for (int i = 0; i < limit; i++) {
        final orig = originalLines[i].trim();
        final n = _normalize(orig);
        if (n.length < 3) continue;
        if (dateRegex.hasMatch(n)) continue;
        if (kw.hasMatch(n)) continue;
        if (noise.hasMatch(n)) continue;
        if (!RegExp(r'[A-Za-zÁÉÍÓÚÑáéíóúñ]').hasMatch(orig)) continue;

        // Limpieza segura (guarda letras, números, espacios y . , & -)
        final clean = orig.replaceAll(RegExp(r'[^A-Za-z0-9 .,&\-ÁÉÍÓÚÑáéíóúñ]'), '').trim();
        if (clean.length >= 3) {
          merchant = _toTitleCase(clean);
          break;
        }
      }

      // ===== Relleno de UI =====
      setState(() {
        if (merchant.isNotEmpty) _merchantCtrl.text = merchant;
        if (amount != null) {
          _amountCtrl.text = amount.toStringAsFixed(2).replaceAll('.', ',');
        }
        _date = dateResult;
        _descriptionCtrl.text = merchant.isNotEmpty ? 'Compra en $merchant' : 'Gasto';
      });

      if ((amount == null || merchant.isEmpty) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OCR parcial: revisa Comercio/Importe. Puedes corregir manualmente y guardar.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error OCR: $e')),
        );
      }
    } finally {
      await textRecognizer.close();
    }
  }

  // ======================
  // Helpers
  // ======================
  String _normalize(String s) {
    var t = s.toUpperCase();
    const from = 'ÁÉÍÓÚÜÑ';
    const to = 'AEIOUUN';
    for (int i = 0; i < from.length; i++) {
      t = t.replaceAll(from[i], to[i]);
    }
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  String _toTitleCase(String s) {
    final words = s.toLowerCase().split(RegExp(r'\s+'));
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      if (w.isEmpty) continue;
      words[i] = '${w[0].toUpperCase()}${w.substring(1)}';
    }
    return words.join(' ');
  }

  double? _parseAmount(String raw) {
    if (raw.isEmpty) return null;
    var s = raw.replaceAll(' ', '').replaceAll(',', '.');
    s = s.replaceAll(RegExp(r'[€\$]'), '');
    return double.tryParse(s);
  }

  double? _findLargestAmount(List<String> lines) {
    double? maxV;
    final numRegex = RegExp(r'([0-9]+(?:[.,][0-9]{2}))'); // exige 2 decimales
    for (final l in lines) {
      for (final m in numRegex.allMatches(l)) {
        final v = _parseAmount(m.group(1)!);
        if (v != null) {
          if (maxV == null || v > maxV) maxV = v;
        }
      }
    }
    return maxV;
  }

  DateTime? _parseDate(String raw) {
    try {
      final norm = raw.replaceAll('-', '/');
      final parts = norm.split('/');
      if (parts.length == 3) {
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        var y = int.parse(parts[2]);
        if (y < 100) y += 2000;
        return DateTime(y, m, d);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    final now = _date ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: now,
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona fecha del ticket',
    );
    if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day));
  }

  Future<void> _save() async {
    final parsedAmount = _parseAmount(_amountCtrl.text);
    if (parsedAmount == null || parsedAmount <= 0 || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena Importe y Fecha antes de guardar')),
      );
      return;
    }

    final entry = ExpenseEntry(
      id: const Uuid().v4(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? 'Gasto'
          : _descriptionCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty
          ? 'General'
          : _categoryCtrl.text.trim(),
      amount: parsedAmount,
      date: _date!,
      paymentMethod: _paymentMethod,
      merchant: _merchantCtrl.text.trim(),
      imagePath: _imageFile?.path,
    );

    await _store.add(entry);
    await widget.onSaved();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto guardado')),
    );

    setState(() {
      _imageFile = null;
      _merchantCtrl.clear();
      _amountCtrl.clear();
      _date = null;
      _descriptionCtrl.clear();
      _categoryCtrl.text = 'General';
      _paymentMethod = 'Tarjeta';
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botones de imagen
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _processing ? null : () => _pick(true),
                label: const Text('Cámara'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _processing ? null : () => _pick(false),
                label: const Text('Galería'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          if (_processing) const LinearProgressIndicator(),
          const SizedBox(height: 12),

          // Campos detectados (editables)
          TextField(
            controller: _merchantCtrl,
            decoration: const InputDecoration(
              labelText: 'Comercio (editable)',
              border: OutlineInputBorder(),
            ),
            enabled: !_processing,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Importe (€) (editable)',
              border: OutlineInputBorder(),
            ),
            enabled: !_processing,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha (editable)',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_date == null ? '—' : df.format(_date!)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: _processing ? null : _pickDate,
                child: const Text('Cambiar'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            enabled: !_processing,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _categoryCtrl,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(),
            ),
            enabled: !_processing,
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: _paymentMethod, // aquí vale usar value (no está deprecado en el dropdown "no form field"? en este sí; si te avisa, cambia a initialValue)
            items: const [
              DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
              DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
              DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
              DropdownMenuItem(value: 'Otro', child: Text('Otro')),
            ],
            onChanged: _processing
                ? null
                : (v) => setState(() => _paymentMethod = v ?? 'Tarjeta'),
            decoration: const InputDecoration(
              labelText: 'Método de pago',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: _processing ? null : _save,
              child: const Text('Guardar gasto'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
