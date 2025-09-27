import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Color corporativo KAVID (naranja)
const kOrange = Color(0xFFFF9800);

/// Widget de entrada OCR:
/// - Preview: logo a recuadro completo si no hay imagen; imagen con cover si existe.
/// - Botones: Cámara / Galería.
/// - Campos: Establecimiento / Importe / Fecha con botón "Cambiar".
/// - NO incluye botón "Guardar" (lo gestiona la página) para evitar duplicados.
class OcrInputTab extends StatefulWidget {
  // Estado entrante (opcional)
  final File? imageFile;
  final String merchant;
  final String amount;
  final DateTime? date;

  // Hooks opcionales del padre (si no se pasan, el widget usa comportamiento por defecto)
  final ValueChanged<File?>? onImageChanged;
  final ValueChanged<String>? onMerchantChanged;
  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<DateTime>? onDateChanged;

  const OcrInputTab({
    super.key,
    this.imageFile,
    this.merchant = '',
    this.amount = '',
    this.date,
    this.onImageChanged,
    this.onMerchantChanged,
    this.onAmountChanged,
    this.onDateChanged,
  });

  @override
  State<OcrInputTab> createState() => _OcrInputTabState();
}

class _OcrInputTabState extends State<OcrInputTab> {
  final _picker = ImagePicker();

  File? _imageFile;
  String _merchant = '';
  String _amount = '';
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.imageFile;
    _merchant = widget.merchant;
    _amount = widget.amount;
    _date = widget.date;
  }

  Future<void> _pickFrom(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null) return;
    setState(() {
      _imageFile = File(xfile.path);
      _date = DateTime.now(); // Fecha del gasto = día del escaneo
    });
    widget.onImageChanged?.call(_imageFile);
    if (_date != null) widget.onDateChanged?.call(_date!);
  }

  Future<void> _changeMerchant() async {
    final controller = TextEditingController(text: _merchant);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar establecimiento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre del establecimiento'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() => _merchant = result);
    widget.onMerchantChanged?.call(_merchant);
  }

  Future<void> _changeAmount() async {
    final controller = TextEditingController(text: _amount.replaceAll('€', '').trim());
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar importe'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Ej: 7.44'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == null) return;
    final normalized = result.replaceAll(',', '.');
    setState(() => _amount = normalized);
    widget.onAmountChanged?.call(_amount);
  }

  Future<void> _changeDate() async {
    final now = DateTime.now();
    final initial = _date ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      helpText: 'Selecciona fecha del gasto',
    );
    if (picked == null) return;
    setState(() => _date = picked);
    widget.onDateChanged?.call(_date!);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date != null ? _formatDate(_date!) : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // PREVISUALIZACIÓN (NO TOCAR EL LOGO)
        Container(
          height: 250,
          width: double.infinity,
          color: kOrange,
          child: _imageFile == null
              ? Image.asset('assets/icons/app_icon.png', fit: BoxFit.cover)
              : Image.file(_imageFile!, fit: BoxFit.cover),
        ),

        const SizedBox(height: 16),

        // BOTONES CÁMARA / GALERÍA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pillButton(
              icon: Icons.photo_camera,
              label: 'Cámara',
              onPressed: () => _pickFrom(ImageSource.camera),
            ),
            _pillButton(
              icon: Icons.photo_library,
              label: 'Galería',
              onPressed: () => _pickFrom(ImageSource.gallery),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // TARJETA DE CAMPOS
        _FieldsCard(
          merchant: _merchant,
          amount: _amount,
          dateText: dateText,
          onChangeMerchant: _changeMerchant,
          onChangeAmount: _changeAmount,
          onChangeDate: _changeDate,
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
    // Si prefieres intl, lo formateamos desde la página.
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: kOrange,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

class _FieldsCard extends StatelessWidget {
  final String merchant;
  final String amount;
  final String dateText;
  final VoidCallback onChangeMerchant;
  final VoidCallback onChangeAmount;
  final VoidCallback onChangeDate;

  const _FieldsCard({
    required this.merchant,
    required this.amount,
    required this.dateText,
    required this.onChangeMerchant,
    required this.onChangeAmount,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kOrange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldBlock(title: 'Establecimiento', value: merchant.isEmpty ? '—' : merchant, onChange: onChangeMerchant),
          const Divider(color: kOrange, height: 24),
          _FieldBlock(title: 'Importe', value: amount.isEmpty ? '—' : amount, onChange: onChangeAmount),
          const Divider(color: kOrange, height: 24),
          _FieldBlock(title: 'Fecha', value: dateText.isEmpty ? '—' : dateText, onChange: onChangeDate),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onChange;

  const _FieldBlock({required this.title, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: kOrange, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: kOrange, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: onChange,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: kOrange,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Cambiar'),
        ),
      ]),
    ]);
  }
}
