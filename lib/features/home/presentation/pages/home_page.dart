import 'package:flutter/material.dart';

/// Primera pantalla vacía del proyecto KAVID.
/// Estructura mínima: AppBar + body centrado.
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
