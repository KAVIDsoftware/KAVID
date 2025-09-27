import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ocr/image_quality.dart';
import '../widgets/ticket_frame_overlay.dart';

class TicketCameraPage extends StatefulWidget {
  const TicketCameraPage({super.key});

  @override
  State<TicketCameraPage> createState() => _TicketCameraPageState();
}

class _TicketCameraPageState extends State<TicketCameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  late Future<void> _initFuture;
  bool _isStreaming = false;
  Timer? _throttle;
  ImageQualityScore _score = const ImageQualityScore.empty();
  bool _readyToCapture = false;
  bool _busyCapture = false;
  String? _errorText;

  // ROI (coincide con overlay)
  static const Rect roi = TicketFrameOverlay.defaultRoi;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initWithPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _throttle?.cancel();
    _stopStream();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initWithPermission() async {
    // 1) Permiso en runtime
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _errorText = 'Permiso de cámara denegado.');
      return;
    }
    // 2) Inicializa cámara
    await _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final controller = _controller;
    if (controller == null) return;
    if (state == AppLifecycleState.inactive) {
      await _stopStream();
      await controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initFuture = _initWithPermission();
      if (mounted) setState(() {});
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _controller = controller;
      await controller.initialize();

      try { await controller.setExposureMode(ExposureMode.auto); } catch (_) {}
      try { await controller.setFocusMode(FocusMode.auto); } catch (_) {}

      _errorText = null;
      _startStream();
    } catch (e) {
      setState(() => _errorText = 'No se pudo abrir la cámara: $e');
    }
  }

  void _startStream() {
    if (_isStreaming || _controller == null) return;
    _isStreaming = true;
    _controller!.startImageStream((CameraImage image) {
      if (_throttle != null && _throttle!.isActive) return;
      _throttle = Timer(const Duration(milliseconds: 500), () {});
      final score = ImageQuality.estimateFromYUV(image, roi);
      final ok = score.isGood;
      if (mounted) {
        setState(() {
          _score = score;
          _readyToCapture = ok;
        });
      }
    });
  }

  Future<void> _stopStream() async {
    if (!_isStreaming || _controller == null) return;
    _isStreaming = false;
    try { await _controller!.stopImageStream(); } catch (_) {}
  }

  Future<void> _onCapture() async {
    if (_controller == null || _busyCapture) return;
    setState(() => _busyCapture = true);
    try {
      await _stopStream();
      final xfile = await _controller!.takePicture();

      // ⚠️ ROTAR POR EXIF ANTES DE RECORTAR (evita fotos negras/recortes vacíos)
      final rotated = await FlutterExifRotation.rotateImage(path: xfile.path);

      final file = await _cropToRoi(rotated);

      if (!mounted) return;
      Navigator.of(context).pop<File>(file);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'Error al capturar: $e');
      _startStream();
    } finally {
      if (mounted) setState(() => _busyCapture = false);
    }
  }

  Future<File> _cropToRoi(File rotatedFile) async {
    final bytes = await rotatedFile.readAsBytes();
    final original = img.decodeImage(bytes)!;

    final w = original.width;
    final h = original.height;

    // Si la foto es portrait muy alargada, ajusta ROI a imagen real
    final left = (roi.left * w).round();
    final top = (roi.top * h).round();
    final width = (roi.width * w).round().clamp(8, w - left);
    final height = (roi.height * h).round().clamp(8, h - top);

    final cropped = img.copyCrop(original, x: left, y: top, width: width, height: height);

    final dir = await getTemporaryDirectory();
    final outPath = '${dir.path}/kavid_ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final jpg = img.encodeJpg(cropped, quality: 92);
    final out = File(outPath)..writeAsBytesSync(jpg);
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final canShoot = _readyToCapture && !_busyCapture && (_controller?.value.isInitialized ?? false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snap) {
          if (_errorText != null) {
            return _ErrorView(text: _errorText!);
          }
          if (snap.connectionState != ConnectionState.done || _controller == null || !_controller!.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Center(child: CameraPreview(_controller!)),
              TicketFrameOverlay(score: _score), // ← overlay SIEMPRE visible
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: canShoot ? _onCapture : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: canShoot ? const Color(0xFFFF9800) : Colors.grey,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    ),
                    child: _busyCapture
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(canShoot ? 'Capturar (encuadre OK)' : 'Ajusta encuadre'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 56, color: Colors.white),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
