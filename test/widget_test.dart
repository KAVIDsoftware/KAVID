import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importa tu app real (asegúrate del nombre del paquete).
import 'package:kavid/main.dart';

void main() {
  testWidgets('KAVID arranca con MaterialApp', (WidgetTester tester) async {
    // Arranca tu aplicación raíz
    await tester.pumpWidget(const KavidApp());

    // Verifica que se crea el MaterialApp (smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
