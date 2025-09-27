// lib/features/gastos diarios/ocr/ocr_models.dart

class OcrParsedResult {
  final String? merchant;
  final double? amount;
  final DateTime? date;
  final Map<String, dynamic> meta;

  const OcrParsedResult({
    this.merchant,
    this.amount,
    this.date,
    this.meta = const {},
  });

  /// Compat con código existente en gastos_diarios_page.dart
  double get amountValue => amount ?? 0.0;

  bool get isComplete =>
      (merchant != null && merchant!.trim().isNotEmpty) && amount != null;

  OcrParsedResult copyWith({
    String? merchant,
    double? amount,
    DateTime? date,
    Map<String, dynamic>? meta,
  }) {
    return OcrParsedResult(
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      meta: meta ?? this.meta,
    );
  }
}
