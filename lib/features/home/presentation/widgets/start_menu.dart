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

  static const Color orange = Color(0xFFFF9800);
  static const double radius = 18;

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem('Nuevo libro', Icons.note_add_rounded, onNewBook),
      _MenuItem('Vista general', Icons.dashboard_rounded, onOverview),
      _MenuItem('Entrar a hojas', Icons.grid_on_rounded, onOpenSheets),
      _MenuItem('Ajustes', Icons.settings_rounded, onSettings),
      _MenuItem('Calendario', Icons.calendar_month_rounded,
              () => _toast(context, 'Calendario (próximamente)')),
      _MenuItem('Usuario', Icons.person_rounded,
              () => _toast(context, 'Usuario (próximamente)')),
      _MenuItem('Coach', Icons.psychology_rounded,
              () => _toast(context, 'Coach (próximamente)')),
      _MenuItem('Recordatorios', Icons.notifications_active_rounded,
              () => _toast(context, 'Recordatorios (próximamente)')),
      _MenuItem('Gastos diarios', Icons.receipt_long_rounded,
              () => _toast(context, 'Gastos diarios (próximamente)')),
    ];

    return Container(
      color: orange,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 3 * 110 + 2 * 16, // ancho de 3 botones + separación
          child: GridView.count(
            shrinkWrap: true, // <-- esto centra verticalmente
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: items.map((item) {
              return _SquareButton(
                label: item.label,
                icon: item.icon,
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StartMenu.radius),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(StartMenu.radius),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              const Icon(Icons.circle, size: 0),
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _MenuItem(this.label, this.icon, this.onTap);
}
