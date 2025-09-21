import 'package:flutter/material.dart';
import '../pages/gastos_diarios_page.dart';

/// Llama a esta función desde cualquier sitio para abrir GastosDiariosPage.
void navigateToGastosDiarios(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const GastosDiariosPage()),
  );
}

/// Si usas vuestro widget personalizado KavidMenuCard, puedes usar este
/// helper ya conectado. Cambia el import del icono/nombre si vuestro
/// KavidMenuCard tiene firma distinta.
class GastosDiariosMenuCard extends StatelessWidget {
  final Widget Function({
  required String title,
  required IconData icon,
  required VoidCallback onTap,
  }) builder;

  const GastosDiariosMenuCard({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(
      title: 'Gastos diarios',
      icon: Icons.receipt_long,
      onTap: () => navigateToGastosDiarios(context),
    );
  }
}
