import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../ocr/ocr_service.dart';
import '../pages/ticket_camera_page.dart';

class OcrInputTab extends StatefulWidget {
  const OcrInputTab({super.key, this.onChanged});

  /// Emite cambios hacia el padre (para guardar después).
  final void Function({
  String? merchant,
  double? amount,
  DateTime? date,
  String? imagePath,
  })? onChanged;

  @override
  State<OcrInputTab> createState() => _OcrInputTabState();
}

class _OcrInputTabState extends State<OcrInputTab> {
  final ImagePicker _picker = ImagePicker();

  File? _lastImage;
  bool _processing = false;
  bool _attempted = false;

  String? merchant;
  String? amountStr;
  DateTime? date;
  String? _imagePath;

  String? rawOcrText;

  static const kOrange = Color(0xFFFF9800);
  static const kBrown = Color(0xFF7A4E18);

  void _emit() {
    widget.onChanged?.call(
      merchant: merchant,
      amount: (amountStr != null && amountStr!.isNotEmpty)
          ? double.tryParse(amountStr!.replaceAll(',', '.'))
          : null,
      date: date,
      imagePath: _imagePath,
    );
  }

  Future<void> _fromCameraWithFrame() async {
    final file = await Navigator.of(context).push<File>(
      MaterialPageRoute(builder: (_) => const TicketCameraPage()),
    );
    if (file == null) return;
    await _processImage(file);
  }

  Future<void> _fromGallery() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    await _processImage(File(xfile.path));
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _processing = true;
      _attempted = true;
      _lastImage = imageFile;
      _imagePath = imageFile.path;
      merchant = null;
      amountStr = null;
      rawOcrText = null;
    });

    try {
      final res = await OcrService().processImage(imageFile);

      final String? m = (res.merchant != null) ? res.merchant!.trim() : null;
      String? a;
      if (res.amount != null) a = res.amount!.toStringAsFixed(2);

      setState(() {
        merchant = m;
        amountStr = a;
        rawOcrText = res.rawText;
        date = DateTime.now();
      });
      _emit();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        rawOcrText = 'OCR error: $e';
        date = DateTime.now();
      });
      _emit();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error OCR: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Preview: logo ocupando TODO el recuadro hasta que haya foto =====
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _lastImage != null
                ? Image.file(_lastImage!, fit: BoxFit.cover)
                : Stack(
              fit: StackFit.expand,
              children: [
                // Fondo naranja + logo a pantalla completa, recortado al contenedor
                // Para que el logo ocupe todo, usamos BoxFit.cover también.
                Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover, // ← ocupa todo el recuadro
                ),
                // Capa de color naranja por si el icono tiene bordes transparentes
                Container(color: kOrange.withOpacity(0.15)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botones naranja/blanco
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _processing ? null : _fromCameraWithFrame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _processing ? null : _fromGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Galería'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildEditableField(
          context,
          label: 'Establecimiento',
          value: merchant ?? '',
          onEdit: (v) {
            setState(() => merchant = v.trim().isEmpty ? null : v.trim());
            _emit();
          },
        ),
        const SizedBox(height: 10),
        _buildEditableField(
          context,
          label: 'Importe',
          value: amountStr ?? '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onEdit: (v) {
            setState(() => amountStr = v.trim().isEmpty ? null : v.trim());
            _emit();
          },
        ),
        const SizedBox(height: 10),
        _buildEditableField(
          context,
          label: 'Fecha',
          value: _formatDate(date ?? DateTime.now()),
          onEdit: (_) {}, // opcional: abrir datepicker más adelante
        ),

        const SizedBox(height: 16),

        if (_attempted && (merchant == null || amountStr == null))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Texto OCR (debug):',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (rawOcrText == null || rawOcrText!.trim().isEmpty)
                      ? '— (no se recibió texto del OCR o falló el reconocimiento)'
                      : rawOcrText!,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEditableField(
      BuildContext context, {
        required String label,
        required String value,
        TextInputType? keyboardType,
        required ValueChanged<String> onEdit,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () async {
                final edited = await _showEditDialog(
                  context,
                  title: 'Editar $label',
                  initial: value == '—' ? '' : value,
                  keyboardType: keyboardType,
                );
                if (edited != null) onEdit(edited);
              },
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(color: kOrange, width: 1.5),
                foregroundColor: kBrown,
              ),
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ],
    );
  }

  Future<String?> _showEditDialog(
      BuildContext context, {
        required String title,
        String initial = '',
        TextInputType? keyboardType,
      }) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: kOrange, foregroundColor: Colors.white),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
