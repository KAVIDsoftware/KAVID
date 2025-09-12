import 'package:flutter/material.dart';

/// Grid 2 columnas para tarjetas de menú.
/// Se usa dentro de un SingleChildScrollView, por eso va con
/// [shrinkWrap: true] y [NeverScrollableScrollPhysics].
class KavidMenuGrid extends StatelessWidget {
  final List<Widget> children;

  const KavidMenuGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );
  }
}
