import 'package:flutter/material.dart';

void main() {
  runApp(const KavidApp());
}

/// App principal de KAVID.
/// - Desactiva la cinta "debug".
/// - Define título y tema.
/// - Abre la HomePage.
class KavidApp extends StatelessWidget {
  const KavidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAVID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,                // UI moderna
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

/// Primera pantalla vacía del proyecto.
/// Estructura mínima: AppBar + body centrado con un texto.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio KAVID'),
      ),
      body: const Center(
        child: Text(
          'Pantalla base lista',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
