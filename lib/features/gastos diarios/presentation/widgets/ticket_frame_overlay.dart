import 'package:flutter/material.dart';
import '../../ocr/image_quality.dart';

/// Overlay del visor con una ventana central (ROI) y borde con semáforo.
/// Sin textos ni métricas. Solo cambia el color del marco:
/// - Blanco: estado neutro (aún ajustando).
/// - Verde: encuadre OK (calidad suficiente).
/// - Rojo: fuera de encuadre (fit muy bajo).
class TicketFrameOverlay extends StatelessWidget {
  const TicketFrameOverlay({
    super.key,
    required this.score,
  });

  final ImageQualityScore score;

  // ROI por defecto: centrada (80% x 55%)
  static const Rect defaultRoi = Rect.fromLTWH(0.10, 0.18, 0.80, 0.55);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final roiPx = Rect.fromLTWH(
      defaultRoi.left * size.width,
      defaultRoi.top * size.height,
      defaultRoi.width * size.width,
      defaultRoi.height * size.height,
    );

    final Color borderColor = _borderColor(score);

    return IgnorePointer(
      child: Stack(
        children: [
          // Máscara con "agujero" en la ROI
          CustomPaint(size: Size.infinite, painter: _MaskPainter(roiPx)),
          // Borde de la ROI
          Positioned.fromRect(
            rect: roiPx,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _borderColor(ImageQualityScore s) {
    // Reglas:
    // - Verde si es "bueno" (umbral de ImageQualityScore).
    // - Rojo si el fit es muy bajo (casi nada del ticket está dentro).
    // - Blanco en el resto (ajustando/normal).
    if (s.isGood) return Colors.greenAccent;
    if (s.fit < 0.10) return Colors.redAccent;
    return Colors.white;
  }
}

class _MaskPainter extends CustomPainter {
  _MaskPainter(this.roi);
  final Rect roi;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final r = RRect.fromRectAndRadius(roi, const Radius.circular(8));

    final bgPath = Path()..addRect(Offset.zero & size);
    final roiPath = Path()..addRRect(r);

    final diff = Path.combine(PathOperation.difference, bgPath, roiPath);
    canvas.drawPath(diff, paint);
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) => oldDelegate.roi != roi;
}
