import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Puntuación de calidad de la imagen dentro de una ROI (0..1 coords).
class ImageQualityScore {
  final double contrast;  // desviación típica de luminancia (0..100 aprox)
  final double sharpness; // densidad de bordes (0..100 aprox)
  final double fit;       // % de bordes en banda interior (0..1)

  const ImageQualityScore(this.contrast, this.sharpness, this.fit);
  const ImageQualityScore.empty() : contrast = 0, sharpness = 0, fit = 0;

  /// Umbrales pragmáticos para tickets (ajústalos si quieres afinar).
  bool get isGood => contrast >= 12 && sharpness >= 14 && fit >= 0.22;
}

/// Utilidades para estimar calidad desde frames YUV (plano Y).
class ImageQuality {
  /// Estima calidad usando solo el plano Y (luma) del frame y la ROI (0..1 coords).
  static ImageQualityScore estimateFromYUV(CameraImage image, Rect roi) {
    if (image.planes.isEmpty) return const ImageQualityScore.empty();

    final yPlane = image.planes.first;
    final bytes = yPlane.bytes;
    final rowStride = yPlane.bytesPerRow;
    final width = image.width;
    final height = image.height;

    // ROI en píxeles (sobre la imagen completa)
    final left = (roi.left * width).clamp(0.0, (width - 1).toDouble()).toInt();
    final top = (roi.top * height).clamp(0.0, (height - 1).toDouble()).toInt();
    final w = (roi.width * width).clamp(8.0, (width - left).toDouble()).toInt();
    final h = (roi.height * height).clamp(8.0, (height - top).toDouble()).toInt();

    // Submuestreo ligero para mantener rendimiento
    const step = 4;
    double sum = 0, sum2 = 0;
    int n = 0;

    // Contraste = desviación estándar de Y en ROI
    for (int y = top; y < top + h; y += step) {
      final row = y * rowStride;
      for (int x = left; x < left + w; x += step) {
        final v = bytes[row + x];
        sum += v;
        sum2 += v * v;
        n++;
      }
    }
    if (n == 0) return const ImageQualityScore.empty();
    final mean = sum / n;
    final variance = math.max(0.0, (sum2 / n) - (mean * mean));
    final contrast = math.sqrt(variance); // 0..~80

    // Sharpness (Sobel aproximado horizontal + vertical)
    int edges = 0, samples = 0;
    for (int y = top + step; y < top + h - step; y += step) {
      final row = y * rowStride;
      final rowUp = (y - step) * rowStride;
      final rowDn = (y + step) * rowStride;
      for (int x = left + step; x < left + w - step; x += step) {
        final gx = bytes[row + x + step] - bytes[row + x - step];
        final gy = bytes[rowDn + x] - bytes[rowUp + x];
        final mag = (gx.abs() + gy.abs());
        if (mag > 30) edges++;
        samples++;
      }
    }
    final sharp = samples > 0 ? (edges * 100.0 / samples) : 0.0;

    // Encaje: densidad de bordes en una banda interior de la ROI
    final innerLeft = left + (w * 0.08).toInt();
    final innerTop = top + (h * 0.08).toInt();
    final innerW = (w * 0.84).toInt();
    final innerH = (h * 0.84).toInt();

    int innerEdges = 0, innerSamples = 0;
    for (int y = innerTop + step; y < innerTop + innerH - step; y += step) {
      final row = y * rowStride;
      for (int x = innerLeft + step; x < innerLeft + innerW - step; x += step) {
        final gx = bytes[row + x + step] - bytes[row + x - step];
        final gy = bytes[(y + step) * rowStride + x] - bytes[(y - step) * rowStride + x];
        final mag = (gx.abs() + gy.abs());
        if (mag > 30) innerEdges++;
        innerSamples++;
      }
    }
    final fit = (edges > 0 && innerSamples > 0) ? (innerEdges / edges) : 0.0;

    // Normalizaciones (usar límites double para evitar errores de tipos)
    final double contrastN = contrast.clamp(0.0, 100.0);
    final double sharpN = sharp.clamp(0.0, 100.0);
    final double fitN = fit.isNaN ? 0.0 : fit.clamp(0.0, 1.0);

    return ImageQualityScore(contrastN, sharpN, fitN);
  }
}
