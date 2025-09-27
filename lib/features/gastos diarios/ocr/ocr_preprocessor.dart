// lib/features/gastos diarios/ocr/ocr_preprocessor.dart
class OcrPreprocessor {
  const OcrPreprocessor();

  String preprocess(String input) {
    var text = input;
    text = text.replaceAll('\r', '\n');
    text = _collapseBlankLines(text);
    text = _trimLines(text);

    // Normalizar fecha 31.12.2025 -> 31/12/2025
    text = text.replaceAllMapped(
      RegExp(r'(\d{2})[\.](\d{2})[\.](\d{2,4})'),
          (m) => '${m[1]}/${m[2]}/${m[3]}',
    );
    // Nota: NO tocamos aquí coma/punto de importes para no destruir decimales.

    return text.trim();
  }

  String _collapseBlankLines(String s) =>
      s.split('\n').where((l) => l.trim().isNotEmpty).join('\n');

  String _trimLines(String s) =>
      s.split('\n').map((l) => l.trim()).join('\n');
}
