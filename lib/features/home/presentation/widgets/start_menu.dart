import 'package:flutter/material.dart';

class StartMenu extends StatelessWidget {
  final VoidCallback onNewBook;
  final VoidCallback onOverview;
  final VoidCallback onOpenSheets;
  final VoidCallback onSettings;

  const StartMenu({
    super.key,
    required this.onNewBook,
    required this.onOverview,
    required this.onOpenSheets,
    required this.onSettings,
  });

  static const Color orange = Color(0xFFFF9800); // mismo que el splash
  static const double tileSize = 120;           // tamaño medio acordado
  static const double gap = 16;
  static const double radius = 18;

  Widget _squareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 2),
                const Icon(Icons.circle, size: 0), // fuerza raster para ripple uniforme
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bloque 2x2 centrado verticalmente
    final double blockHeight = tileSize * 2 + gap;
    final double blockWidth = tileSize * 2 + gap;

    return Container(
      color: orange,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: SizedBox(
        height: blockHeight,
        width: blockWidth,
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: [
            // Orden acordado:
            // [ Nuevo libro ] [ Vista general ]
            // [ Entrar a hojas ] [ Ajustes ]
            _squareButton(icon: Icons.add_box,       label: 'Nuevo libro',     onTap: onNewBook),
            _squareButton(icon: Icons.battery_full,  label: 'Vista general',   onTap: onOverview),
            _squareButton(icon: Icons.grid_on,       label: 'Entrar a hojas',  onTap: onOpenSheets),
            _squareButton(icon: Icons.settings,      label: 'Ajustes',         onTap: onSettings),
          ],
        ),
      ),
    );
  }
}
