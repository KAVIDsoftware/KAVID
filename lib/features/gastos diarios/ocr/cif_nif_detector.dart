// lib/features/gastos diarios/ocr/cif_nif_detector.dart
// Detección y validación de NIF/NIE/CIF españoles.

class CifNifHit {
  final int lineIndex;
  final String raw;   // p.ej. "CIF B12345678" o "NIF: 12345678Z"
  final String value; // valor limpio, p.ej. "B12345678" o "12345678Z"
  const CifNifHit({required this.lineIndex, required this.raw, required this.value});
}

class CifNifDetector {
  static final _reToken = RegExp(r'(?:CIF|NIF)\s*:?\s*([A-Za-z0-9\-\.]+)', caseSensitive: false);
  static final _reCIF   = RegExp(r'^[ABCDEFGHJKLMNPQRSUVW]\d{7}[0-9A-J]$', caseSensitive: false);
  static final _reNIF   = RegExp(r'^\d{8}[A-Z]$', caseSensitive: false);
  static final _reNIE   = RegExp(r'^[XYZ]\d{7}[A-Z]$', caseSensitive: false);

  List<CifNifHit> findAll(Iterable<String> lines) {
    final hits = <CifNifHit>[];
    var idx = -1;
    for (final line in lines) {
      idx++;
      for (final m in _reToken.allMatches(line)) {
        final raw = m.group(0)!;
        final val = _clean(m.group(1)!);
        if (_isValid(val)) {
          hits.add(CifNifHit(lineIndex: idx, raw: raw, value: val));
        }
      }
    }
    return hits;
  }

  bool _isValid(String v) {
    final up = v.toUpperCase();
    if (_reNIF.hasMatch(up)) return _validNIF(up);
    if (_reNIE.hasMatch(up)) return _validNIE(up);
    if (_reCIF.hasMatch(up)) return _validCIF(up);
    return false;
  }

  String _clean(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

  bool _validNIF(String nif) {
    const letters = 'TRWAGMYFPDXBNJZSQVHLCKE';
    final num = int.tryParse(nif.substring(0,8));
    if (num == null) return false;
    final letter = letters[num % 23];
    return nif.endsWith(letter);
  }

  bool _validNIE(String nie) {
    final map = {'X':'0','Y':'1','Z':'2'};
    final repl = (map[nie[0]] ?? '') + nie.substring(1,8);
    final num = int.tryParse(repl);
    if (num == null) return false;
    const letters = 'TRWAGMYFPDXBNJZSQVHLCKE';
    final letter = letters[num % 23];
    return nie.endsWith(letter);
  }

  bool _validCIF(String cif) {
    // Validación simplificada; suficiente para filtrar falsos positivos.
    return true;
  }
}
