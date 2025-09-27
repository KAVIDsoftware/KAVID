import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Store y páginas
import '../../data/gastos_local_store.dart';
import '../pages/tickets_summary_page.dart';
import '../widgets/ocr_input_tab.dart';

// OCR: ML Kit + parser
import '../../engines/ocr_engine_mlkit.dart';
import '../../ocr/ocr_service.dart';

// Preprocesado EXIF (muy importante para que ML Kit lea bien)
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

const kOrange = Color(0xFFFF9800);

class GastosDiariosPage extends StatefulWidget {
  const GastosDiariosPage({super.key});

  @override
  State<GastosDiariosPage> createState() => _GastosDiariosPageState();
}

class _GastosDiariosPageState extends State<GastosDiariosPage> {
  final _ocrEngine = OcrEngineMlkit();
  final _ocrService = OcrService();

  File? _imageFile;
  String _merchant = '';
  String _amount = '';
  DateTime? _date;

  bool _isOcrRunning = false;

  Future<void> _onImageChanged(File? rawFile) async {
    setState(() {
      _imageFile = rawFile;
      _date = DateTime.now();
    });
    if (rawFile == null) return;

    // 1) Preprocesado EXIF (gira/normaliza la imagen)
    File preprocessed = rawFile;
    try {
      final rotated = await FlutterExifRotation.rotateImage(path: rawFile.path);
      preprocessed = rotated;
      setState(() => _imageFile = preprocessed);
    } catch (_) {
      // seguimos con la original si falla
    }

    // 2) OCR + parseo → autorrelleno campos
    setState(() => _isOcrRunning = true);
    try {
      final recognizedText = await _ocrEngine.recognizeText(preprocessed);

      // Logs útiles en consola para verificar OCR
      // (Puedes verlos en `flutter run`):
      // print('OCR len: ${recognizedText.length}');
      // print(recognizedText.substring(0, recognizedText.length.clamp(0, 200)));

      final parsed = _ocrService.parseTicketText(recognizedText);

      setState(() {
        _merchant = (parsed['comercio'] as String?)?.trim() ?? _merchant;
        final parsedAmount = (parsed['importe'] as double?) ?? 0.0;
        if (parsedAmount > 0) {
          _amount = parsedAmount.toStringAsFixed(2);
        }
        _date = (parsed['fecha'] as DateTime?) ?? _date ?? DateTime.now();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo leer el ticket. Puedes editar los campos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOcrRunning = false);
    }
  }

  Future<void> _save() async {
    if (_amount.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un importe válido')),
      );
      return;
    }

    final id = const Uuid().v4();
    final amountDouble = double.tryParse(_amount.replaceAll(',', '.')) ?? 0.0;
    final when = _date ?? DateTime.now();

    final ticket = Ticket(
      id: id,
      merchant: _merchant.isEmpty ? '—' : _merchant,
      amount: amountDouble,
      date: DateTime(when.year, when.month, when.day), // normaliza sin hora
      imagePath: _imageFile?.path,
    );

    await GastosLocalStore.instance.add(ticket);

    if (!mounted) return;

    // Navegamos a Tickets y al volver limpiamos la pantalla
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TicketsSummaryPage()),
    );

    if (!mounted) return;
    setState(() {
      _imageFile = null;
      _merchant = '';
      _amount = '';
      _date = null;
      _isOcrRunning = false;
    });
  }

  @override
  void dispose() {
    _ocrEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BODY con scroll; botón naranja, centrado, ANCHO y con margen generoso
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear ticket'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OcrInputTab(
                imageFile: _imageFile,
                merchant: _merchant,
                amount: _amount,
                date: _date,
                onImageChanged: _onImageChanged,
                onMerchantChanged: (v) => setState(() => _merchant = v),
                onAmountChanged: (v) => setState(() => _amount = v),
                onDateChanged: (d) => setState(() => _date = d),
              ),

              if (_isOcrRunning)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator(color: kOrange)),
                ),

              const SizedBox(height: 32),

              // Botón GUARDAR GASTOS – NARANJA, ancho completo, centrado y con margen
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 18), // más alto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Guardar gastos',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24), // margen inferior extra (no pegado)
            ],
          ),
        ),
      ),
    );
  }
}
