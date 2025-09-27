import 'dart:io';
import 'package:flutter/material.dart';

class OcrDebugPage extends StatelessWidget {
  final String rawText;
  final String preprocessedText;
  final File? screenshotFile;
  final String? hint;

  const OcrDebugPage({
    super.key,
    required this.rawText,
    required this.preprocessedText,
    this.screenshotFile,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug OCR')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            if (hint != null) Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(hint!, style: Theme.of(context).textTheme.bodyMedium),
            ),
            if (screenshotFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Image.file(screenshotFile!, height: 160, fit: BoxFit.cover),
              ),
            const Text('Texto OCR (preprocesado):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(preprocessedText),
            ),
            const SizedBox(height: 16),
            const Text('Texto OCR (bruto):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(rawText),
            ),
          ],
        ),
      ),
    );
  }
}
