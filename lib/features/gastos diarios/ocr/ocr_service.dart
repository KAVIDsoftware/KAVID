import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrParsedResult {
  final String? merchant;
  final double? amount;
  final String rawText;
  final String? imagePath; // opcional: por si quieres pasarlo aguas arriba

  OcrParsedResult({
    required this.merchant,
    required this.amount,
    required this.rawText,
    this.imagePath,
  });
}

class OcrService {
  Future<OcrParsedResult> processImage(File file) async {
    if (!await file.exists()) {
      throw ArgumentError('Archivo no existe: ${file.path}');
    }
    final length = await file.length();
    if (length < 1024) {
      throw ArgumentError('Archivo demasiado pequeño para OCR ($length bytes).');
    }
    try {
      final decoded = img.decodeImage(await file.readAsBytes());
      if (decoded == null || decoded.width == 0 || decoded.height == 0) {
        throw ArgumentError('La imagen no se puede decodificar.');
      }
    } catch (e) {
      throw ArgumentError('No se pudo leer la imagen: $e');
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognized = await recognizer.processImage(InputImage.fromFilePath(file.path));
    await recognizer.close();

    final rawText = recognized.text;
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchant = _extractMerchantSmart(lines);
    final amount = _extractAmount(lines);

    return OcrParsedResult(
      merchant: merchant,
      amount: amount,
      rawText: rawText,
      imagePath: file.path,
    );
  }

  // ---------- EXTRACCIÓN COMERCIO MEJORADA ----------
  String? _extractMerchantSmart(List<String> lines) {
    if (lines.isEmpty) return null;

    // Palabras y líneas que NO queremos como comercio
    final hardBlock = <String>{
      'COPIA', 'CLIENTE', 'COPIA CLIENTE', 'COPIA PARA EL CLIENTE',
      'VENTA', 'AUTORIZADA', 'AUTORIZACION', 'AUTORIZACIÓN', 'APROBADA',
      'TOTAL', 'TOTAL EUR', 'EUR', 'EURO', 'IVA', 'IMPUESTO',
      'COMERCIO', 'TPV', 'TERMINAL', 'REFERENCIA', 'FECHA', 'HORA',
      'NUM', 'NÚM', 'SESIÓN', 'SESION', 'BANCO', 'BANK', 'SABADELL',
      'VISA', 'MASTERCARD', 'DEBIT', 'CREDIT', 'AID', 'AUTOR',
      'FACTURA', 'FACTURA SIMPLIFICADA', 'TICKET', 'COPIA DE CLIENTE',
    };

    // Palabras positivas que ayudan a identificar comercio
    final positiveHints = <String>{
      'BAR', 'CAFETERIA', 'CAFETERÍA', 'MERCADONA', 'DIA', 'LIDL', 'CARREFOUR',
      'ALCAMPO', 'REPSOL', 'CEPSA', 'SHELL', 'FARMACIA', 'ESTANC', 'EXPENDEDURIA',
      'GRANJA', 'PANADERIA', 'PANADERÍA', 'CAFÉ', 'CAFETERIA', 'SUPERMERCADO',
    };

    // Limpieza básica
    String clean(String s) {
      // Mantén letras/números/espacios y algunos signos.
      final t = s.replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚÜÑ0-9áéíóúüñ .,-]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      return t;
    }

    // Scoring por línea
    double scoreLine(String line, int index) {
      final up = line.toUpperCase();

      // Bloqueos duros
      for (final b in hardBlock) {
        if (up == b || up.startsWith('$b ') || up.contains(' $b ')) return -1000;
      }
      if (RegExp(r'\b(TOTAL|VENTA|AUTORI[ZS]ADA|EUR)\b', caseSensitive: false).hasMatch(up)) {
        return -500;
      }

      // Penaliza si casi todo son números
      final numRatio = RegExp(r'[0-9]').allMatches(up).length / (up.length.clamp(1, 999));
      if (numRatio > 0.6) return -50;

      // Longitud razonable
      if (up.length < 4) return -20;
      if (up.length > 40) return -10;

      double s = 0;

      // Bonus si contiene “, S.L.” o “, S.A.”
      if (RegExp(r'(S\.L\.|S\.A\.|S\.L|S\.A)', caseSensitive: false).hasMatch(up)) s += 40;

      // Bonus por hints positivos
      for (final h in positiveHints) {
        if (up.contains(h)) s += 20;
      }

      // Más peso a las primeras 6 líneas
      s += (6 - index).clamp(0, 6) * 5;

      // Bonus por tener 2–4 palabras
      final words = up.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.length >= 2 && words.length <= 5) s += 15;

      // Si todo en mayúsculas y sin símbolos raros, un pequeño bonus
      if (up == up.toUpperCase()) s += 5;

      // Quita ruido típico de cabeceras “COMERCIO”, “TPV”
      if (up.startsWith('COMERCIO') || up.startsWith('TPV')) s -= 80;

      return s;
    }

    String? best;
    double bestScore = -10000;

    for (var i = 0; i < lines.length; i++) {
      final l = clean(lines[i]);
      if (l.isEmpty) continue;
      final sc = scoreLine(l, i);
      if (sc > bestScore) {
        bestScore = sc;
        best = l;
      }
    }

    return best;
  }

  // ---------- EXTRACCIÓN IMPORTE ----------
  double? _extractAmount(List<String> lines) {
    if (lines.isEmpty) return null;

    double? fromTotal;
    final all = <double>[];

    for (final l in lines) {
      final t = l.replaceAll('O', '0'); // O->0
      if (RegExp(r'\bTOTAL\b', caseSensitive: false).hasMatch(t)) {
        final m = RegExp(r'(\d{1,4}[.,]\d{2})').firstMatch(t);
        if (m != null) fromTotal = _toDouble(m.group(1)!);
      }
      for (final m in RegExp(r'(\d{1,4}[.,]\d{2})').allMatches(t)) {
        final v = _toDouble(m.group(1)!);
        if (v != null) all.add(v);
      }
    }

    if (fromTotal != null) return fromTotal;
    if (all.isNotEmpty) {
      all.sort();
      return all.last;
    }
    return null;
  }

  double? _toDouble(String s) {
    try {
      return double.parse(s.replaceAll(',', '.'));
    } catch (_) {
      return null;
    }
  }
}
