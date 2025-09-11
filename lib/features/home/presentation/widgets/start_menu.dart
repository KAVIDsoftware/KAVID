import 'package:flutter/material.dart';

/// ===============================================
/// Start Menu KAVID (1 tarjeta XL + grid 2×4)
/// Archivo único y autocontenido.
/// ===============================================

class StartMenu extends StatelessWidget {
  const StartMenu({
    super.key,
    this.onArchivador,
    this.onVistaGeneral,
    this.onEntrarHojas,
    this.onAjustes,
    this.onCalendario,
    this.onUsuario,
    this.onCoach,
    this.onRecordatorios,
    this.onGastosDiarios,
  });

  // Callbacks opcionales: si vienen null, se muestra SnackBar "próximamente"
  final VoidCallback? onArchivador;
  final VoidCallback? onVistaGeneral;
  final VoidCallback? onEntrarHojas;
  final VoidCallback? onAjustes;
  final VoidCallback? onCalendario;
  final VoidCallback? onUsuario;
  final VoidCallback? onCoach;
  final VoidCallback? onRecordatorios;
  final VoidCallback? onGastosDiarios;

  // ====== Tokens (colores/espacios) ======
  static const Color _orange = Color(0xFFFF9800);
  static const Color _surface = Color(0xFFF6F6F6);
  static const Color _iconAvatar = Color(0xFFFFF3E5);
  static const double _radius = 16.0;
  static const double _pad = 16.0;
  static const double _gutter = 16.0;

  void _toast(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label (próximamente)'),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: _orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  VoidCallback _wrap(BuildContext c, VoidCallback? cb, String label) {
    return () => (cb != null) ? cb() : _toast(c, label);
  }

  @override
  Widget build(BuildContext context) {
    const double maxContentWidth = 640;

    return Scaffold(
      backgroundColor: _surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double contentWidth =
          width > maxContentWidth ? maxContentWidth : width;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_pad),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta XL: Archivador
                    _KavidMenuCard(
                      title: 'Archivador',
                      icon: Icons.folder_rounded,
                      onTap: _wrap(context, onArchivador, 'Archivador'),
                      large: true,
                    ),
                    const SizedBox(height: _gutter),

                    // Grid 2×4
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: _gutter,
                      mainAxisSpacing: _gutter,
                      children: [
                        // Fila 1
                        _KavidMenuCard(
                          title: 'Vista general',
                          icon: Icons.dashboard_rounded,
                          onTap:
                          _wrap(context, onVistaGeneral, 'Vista general'),
                        ),
                        _KavidMenuCard(
                          title: 'Entrar a hojas',
                          icon: Icons.grid_on_rounded,
                          onTap:
                          _wrap(context, onEntrarHojas, 'Entrar a hojas'),
                        ),

                        // Fila 2
                        _KavidMenuCard(
                          title: 'Gastos diarios',
                          icon: Icons.receipt_long_rounded,
                          onTap: _wrap(
                              context, onGastosDiarios, 'Gastos diarios'),
                        ),
                        _KavidMenuCard(
                          title: 'Calendario',
                          icon: Icons.calendar_month_rounded,
                          onTap:
                          _wrap(context, onCalendario, 'Calendario'),
                        ),

                        // Fila 3
                        _KavidMenuCard(
                          title: 'Recordatorios',
                          icon: Icons.notifications_active_rounded,
                          onTap: _wrap(
                              context, onRecordatorios, 'Recordatorios'),
                        ),
                        _KavidMenuCard(
                          title: 'Usuario',
                          icon: Icons.person_rounded,
                          onTap: _wrap(context, onUsuario, 'Usuario'),
                        ),

                        // Fila 4
                        _KavidMenuCard(
                          title: 'Coach',
                          icon: Icons.psychology_rounded,
                          onTap: _wrap(context, onCoach, 'Coach'),
                        ),
                        _KavidMenuCard(
                          title: 'Ajustes',
                          icon: Icons.settings_rounded,
                          onTap: _wrap(context, onAjustes, 'Ajustes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tarjeta reutilizable de acceso rápido.
/// - Variante `large` para la tarjeta Archivador.
class _KavidMenuCard extends StatelessWidget {
  const _KavidMenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.large = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool large;

  static const Color _orange = Color(0xFFFF9800);
  static const Color _iconAvatar = Color(0xFFFFF3E5);
  static const double _radius = 16.0;
  static const double _pad = 16.0;

  @override
  Widget build(BuildContext context) {
    final double height = large ? 140 : 116;
    final double avatar = large ? 56 : 48;
    final double iconSize = large ? 32 : 26;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.all(_pad),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(_radius)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000), // 10% negro
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar + icono
              Container(
                width: avatar,
                height: avatar,
                decoration: const BoxDecoration(
                  color: _iconAvatar,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: _orange),
              ),
              const SizedBox(height: 10),
              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
