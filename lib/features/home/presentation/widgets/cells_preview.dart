import 'package:flutter/material.dart';

/// Rejilla de celdas de prueba para marcar espacio de trabajo (no funcional aún).
class CellsPreview extends StatelessWidget {
  final int columns;
  final int rows;

  const CellsPreview({
    super.key,
    this.columns = 6,
    this.rows = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const aspect = 1.6; // rectangular tipo móvil

    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: aspect,
        ),
        itemCount: columns * rows,
        itemBuilder: (context, index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                width: 0.8,
                color: theme.dividerColor.withOpacity(0.6),
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
