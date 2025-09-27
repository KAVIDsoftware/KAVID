// lib/features/gastos diarios/data/local/ocr_corrections_store.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda correcciones del usuario para re-aplicarlas.
/// Ejemplos de claves:
///  - "ocr_fix_cif_VALOR"  => nombre establecimiento
///  - "ocr_fix_hash_N"     => nombre establecimiento
class OcrCorrectionsStore {
  static const _prefixCif = 'ocr_fix_cif_';
  static const _prefixHash = 'ocr_fix_hash_';

  const OcrCorrectionsStore();

  Future<void> saveByCif(String cifValue, String merchant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixCif$cifValue', merchant);
  }

  Future<String?> getByCif(String cifValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefixCif$cifValue');
  }

  Future<void> saveByHash(String hashKey, String merchant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixHash$hashKey', merchant);
  }

  Future<String?> getByHash(String hashKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefixHash$hashKey');
  }

  /// Hash sencillo (no criptográfico) del texto OCR preprocesado
  String quickHash(String text) {
    const int fnvPrime = 16777619;
    int hash = 2166136261;
    for (var i = 0; i < text.length; i++) {
      hash ^= text.codeUnitAt(i);
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}
