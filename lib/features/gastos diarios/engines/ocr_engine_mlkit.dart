import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Motor OCR con ML Kit. Expone recognizeText(File) -> String con el texto completo.
class OcrEngineMlkit {
  final TextRecognizer _recognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  /// Reconoce el texto de una imagen local y devuelve todo el texto concatenado.
  Future<String> recognizeText(File file) async {
    final inputImage = InputImage.fromFile(file);
    final RecognizedText result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
