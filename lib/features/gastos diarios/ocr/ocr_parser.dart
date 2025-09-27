// lib/features/gastos diarios/ocr/ocr_parser.dart
import 'dart:math';
import 'ocr_models.dart';
import 'ocr_rules.dart';
import 'cif_nif_detector.dart';

class _AmtCand {
  final double v;
  final int i;
  final bool sameKW;
  final bool nearKW;
  final bool hasEuro;
  final bool badCtx;
  _AmtCand(this.v, this.i, this.sameKW, this.nearKW, this.hasEuro, this.badCtx);
}

class OcrParser {
  final CifNifDetector _cifNif;
  OcrParser({CifNifDetector? detector}) : _cifNif = detector ?? CifNifDetector();

  /// Hago pública la limpieza legal para usarla también desde el servicio.
  String cleanBusinessName(String input) => _cleanLegalSuffix(_stripTrailingPunct(input));

  OcrParsedResult parse(String text) {
    final rawLines = text.split('\n');
    final lines = rawLines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final lower = lines.map((l) => normalizeForMatch(l)).toList();

    final hits = _cifNif.findAll(lines);
    final cifAnchorIdx = hits.isNotEmpty ? hits.first.lineIndex : null;
    final cifValue = hits.isNotEmpty ? hits.first.value : null;

    final amount = _extractAmount(lines);

    var merchant = _extractMerchant(lines, lower, cifAnchorIdx);
    if (merchant != null) merchant = cleanBusinessName(merchant);

    return OcrParsedResult(
      merchant: merchant,
      amount: amount,
      date: null,
      meta: {'cif': cifValue, 'cifLine': cifAnchorIdx, 'lineCount': lines.length, 'raw': text},
    );
  }

  // ---------- IMPORTE (fallback textual robusto) ----------
  static const List<String> _amountNoiseCtx = [
    'iva','iva 4','iva 10','iva 21','cuota','quota','base','base imponible',
    'imponible','subtotal','sub total','tasas','fee','propina','tax','unidad','ud','unit','cantidad'
  ];

  double? _extractAmount(List<String> lines) {
    final lower = lines.map((l) => normalizeForMatch(l)).toList();
    final re = RegExp(r'(?<!\d)(\d{1,6}(?:[.,]\d{3})*(?:[.,]\d{2}))(?!\d)');

    bool hasKW(String l) => kTotalKeywords.any((k) => l.contains(k));
    bool hasEuro(String l) => l.contains('€') || l.contains(' eur') || l.contains('euro');
    bool badCtx(String l) => _amountNoiseCtx.any((w) => l.contains(w));

    for (int i = 0; i < lines.length; i++) {
      if (!hasKW(lower[i])) continue;

      final same = re.allMatches(lines[i]).map((m) => _parseAmt(m.group(1)!)).whereType<double>().toList();
      if (same.isNotEmpty) {
        final ge1 = same.where((v) => v >= 1.0).toList();
        return (ge1.isNotEmpty ? ge1 : same).reduce(max);
      }

      final nextVals = <double>[];
      for (int d = 1; d <= 2; d++) {
        final j = i + d;
        if (j >= lines.length) break;
        if (badCtx(lower[j])) continue;
        final vals = re.allMatches(lines[j]).map((m) => _parseAmt(m.group(1)!)).whereType<double>();
        nextVals.addAll(vals);
      }
      if (nextVals.isNotEmpty) {
        final ge1 = nextVals.where((v) => v >= 1.0).toList();
        return (ge1.isNotEmpty ? ge1 : nextVals).reduce(max);
      }
    }

    final cands = <_AmtCand>[];
    for (int i = 0; i < lines.length; i++) {
      final lwr = lower[i];
      final sameKW = hasKW(lwr);
      bool nearKW = sameKW;
      if (!nearKW) {
        for (int d = -2; d <= 2; d++) {
          if (d == 0) continue;
          final j = i + d;
          if (j >= 0 && j < lower.length && hasKW(lower[j])) { nearKW = true; break; }
        }
      }
      final euro = hasEuro(lwr);
      final bad = badCtx(lwr);

      for (final m in re.allMatches(lines[i])) {
        final v = _parseAmt(m.group(1)!);
        if (v != null) cands.add(_AmtCand(v, i, sameKW, nearKW, euro, bad));
      }
    }
    if (cands.isEmpty) return null;

    final nearGood = cands.where((c) => c.nearKW && !c.badCtx && c.v >= 1.0).toList();
    if (nearGood.isNotEmpty) return nearGood.map((e) => e.v).reduce(max);

    final nearAny = cands.where((c) => c.nearKW).toList();
    if (nearAny.isNotEmpty) return nearAny.map((e) => e.v).reduce(max);

    final ge1 = cands.where((c) => c.v >= 1.0 && !c.badCtx).toList();
    if (ge1.isNotEmpty) return ge1.map((e) => e.v).reduce(max);

    return cands.map((e) => e.v).reduce(max);
  }

  double? _parseAmt(String s) {
    final hasComma = s.contains(',');
    final hasDot = s.contains('.');
    final euThousand = RegExp(r'^\d{1,3}(\.\d{3})+,\d{2}$');
    if (euThousand.hasMatch(s)) return double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
    final euSimple = RegExp(r'^\d+,\d{2}$');
    if (euSimple.hasMatch(s)) return double.tryParse(s.replaceAll(',', '.'));
    final usThousand = RegExp(r'^\d{1,3}(,\d{3})+\.\d{2}$');
    if (usThousand.hasMatch(s)) return double.tryParse(s.replaceAll(',', ''));
    final usSimple = RegExp(r'^\d+\.\d{2}$');
    if (usSimple.hasMatch(s)) return double.tryParse(s);
    if (hasComma && hasDot) {
      final lastC = s.lastIndexOf(',');
      final lastD = s.lastIndexOf('.');
      if (lastC > lastD) {
        return double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
      } else {
        return double.tryParse(s.replaceAll(',', ''));
      }
    }
    if (hasComma && !hasDot) return double.tryParse(s.replaceAll(',', '.'));
    return double.tryParse(s);
  }

  // ---------- ESTABLECIMIENTO ----------
  String? _extractMerchant(List<String> lines, List<String> lower, int? cifLine) {
    final win = OcrWeights.headerWindowLines.clamp(1, lines.length);
    final end = min(win, lines.length);

    String? best;
    double bestScore = -1;

    for (int i = 0; i < end; i++) {
      final raw = lines[i];
      final lwr = lower[i];

      final clean = raw.replaceAll(RegExp(r'[^A-Za-z0-9\s\-\&\.\,]'), '').trim();
      if (clean.isEmpty) continue;

      if (lineContainsAny(lwr, kBlacklistTPV)) continue;
      if (lineContainsAny(lwr, kBlacklistContextOnly) && _aroundTpvContext(lwr)) continue;

      double score = 0.0;
      if (kAccountingWords.any((w) => lwr.contains(w))) score += OcrWeights.wAccountingWords;

      final letters = RegExp(r'[A-Za-z]').allMatches(clean).length;
      final digits = RegExp(r'\d').allMatches(clean).length;
      final nchars = clean.replaceAll(' ', '').length;
      final digitRatio = nchars == 0 ? 1.0 : (digits / nchars);

      if (digitRatio > OcrWeights.maxDigitRatio) score += OcrWeights.wTooManyDigits;
      if (letters > digits) score += OcrWeights.wLettersOverDigits;

      if (clean.length >= OcrWeights.minLen && clean.length <= OcrWeights.maxLen) score += OcrWeights.wLengthGood;
      if (clean == clean.toUpperCase()) score += OcrWeights.wUppercase;

      if (lineStartsWithAny(lwr, kCINGenericos)) score += OcrWeights.wWhitelistPrefix;
      if (lineContainsAny(lwr, kCINGenericos)) score += 0.5;
      if (lineStartsWithAny(lwr, kCINMarcasFrecuentes)) score += OcrWeights.wWhitelistPrefix;
      if (lineContainsAny(lwr, kCINMarcasFrecuentes)) score += 0.5;
      if (lineStartsWithAny(lwr, kCINGasolineras)) score += OcrWeights.wWhitelistPrefix;
      if (lineContainsAny(lwr, kCINGasolineras)) score += 0.5;
      if (lineStartsWithAny(lwr, kCINRestaCafe)) score += OcrWeights.wWhitelistPrefix;
      if (lineContainsAny(lwr, kCINRestaCafe)) score += 0.5;
      if (lineStartsWithAny(lwr, kCINOtrosRetail)) score += OcrWeights.wWhitelistPrefix;
      if (lineContainsAny(lwr, kCINOtrosRetail)) score += 0.5;

      if (cifLine != null && (i - cifLine).abs() <= 3) score += OcrWeights.wNearCifNif;

      if (score > bestScore) {
        bestScore = score;
        best = clean;
      }
    }
    return best;
  }

  bool _aroundTpvContext(String lwr) {
    return lineContainsAny(lwr, [
      'tpv','terminal','venta autorizada','autorizada','ref','referencia',
      'operacion','operación','tarjeta','mastercard','visa','bbva','comercia','redsys'
    ]);
  }

  String _stripTrailingPunct(String s) => s.replaceAll(RegExp(r'[\s\.\,\;\:\-]+$'), '').trim();

  String _cleanLegalSuffix(String input) {
    var out = input.trim();
    // Con coma
    final withCommaSA = RegExp(r',\s*S[\.\-\s]*A\.?\s*$', caseSensitive: false);
    final withCommaSL = RegExp(r',\s*S[\.\-\s]*L\.?\s*$', caseSensitive: false);
    if (withCommaSA.hasMatch(out) || withCommaSL.hasMatch(out)) {
      return out.substring(0, out.lastIndexOf(',')).trim();
    }
    // Sin coma
    out = out.replaceAll(RegExp(r'\s*S[\.\-\s]?A[\.\-\s]?$', caseSensitive: false), '');
    out = out.replaceAll(RegExp(r'\s*S[\.\-\s]?L[\.\-\s]?$', caseSensitive: false), '');
    return out.trim();
  }
}
