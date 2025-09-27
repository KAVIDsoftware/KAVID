import 'dart:io';
import 'package:image/image.dart' as img;

class OcrService {
  /// Simula una función de OCR que analiza un texto de ticket y devuelve un mapa con:
  /// - nombre del comercio
  /// - importe
  /// - fecha

  Map<String, dynamic> parseTicketText(String ocrText) {
    final lines = ocrText.split('\n');
    String? comercio;
    double? importe;
    DateTime? fecha;

    // Palabras clave para buscar importe
    final keywords = {'total', 'importe', 'pagar', 'pago'};

    for (var line in lines) {
      final lower = line.toLowerCase();

      // Detectar nombre de comercio (primeras líneas no vacías y no numéricas)
      if (comercio == null && lower.isNotEmpty && !RegExp(r'\d').hasMatch(lower)) {
        comercio = line.trim();
      }

      // Detectar importe por palabra clave
      if (keywords.any((k) => lower.contains(k))) {
        final match = RegExp(r'(\d{1,3}(?:[.,]\d{2}))').firstMatch(lower);
        if (match != null) {
          importe = double.tryParse(match.group(1)!.replaceAll(',', '.'));
        }
      }

      // Detectar fecha
      final dateMatch = RegExp(r'(\d{2}/\d{2}/\d{4})').firstMatch(lower);
      if (dateMatch != null) {
        try {
          fecha = DateTime.parse(
            dateMatch.group(1)!.split('/').reversed.join('-'),
          );
        } catch (_) {}
      }
    }

    return {
      'comercio': comercio ?? 'Comercio desconocido',
      'importe': importe ?? 0.0,
      'fecha': fecha ?? DateTime.now(),
    };
  }

  /// Simula un preprocesamiento de imagen (ejemplo: rotación)
  Future<File> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return imageFile;

    final rotated = img.copyRotate(image, angle: 0); // Aquí podrías rotar si hiciera falta
    final processed = img.encodeJpg(rotated);
    final newPath = imageFile.path.replaceFirst('.jpg', '_processed.jpg');
    final newFile = File(newPath)..writeAsBytesSync(processed);
    return newFile;
  }
}
