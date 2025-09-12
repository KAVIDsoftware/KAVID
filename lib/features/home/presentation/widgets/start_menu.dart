import 'package:flutter/material.dart';
import 'package:kavid/features/home/presentation/widgets/kavid_menu_card.dart';
import 'package:kavid/features/home/presentation/widgets/kavid_menu_grid.dart';

class StartMenu extends StatelessWidget {
  const StartMenu({
    super.key,
    required this.onArchivador,
    required this.onVistaGeneral,
    required this.onEntrarHojas,
    required this.onAjustes,
    required this.onCalendario,
    required this.onUsuario,
    required this.onCoach,
    required this.onRecordatorios,
    required this.onGastosDiarios,
  });

  final VoidCallback onArchivador;
  final VoidCallback onVistaGeneral;
  final VoidCallback onEntrarHojas;
  final VoidCallback onAjustes;
  final VoidCallback onCalendario;
  final VoidCallback onUsuario;
  final VoidCallback onCoach;
  final VoidCallback onRecordatorios;
  final VoidCallback onGastosDiarios;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Tarjeta XL (Archivador)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: onArchivador,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFFFF9800),
                          child: Icon(Icons.folder, color: Colors.white, size: 28),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Archivador',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Grid de accesos
          KavidMenuGrid(
            children: [
              KavidMenuCard(icon: Icons.dashboard,      label: 'Vista general',  onTap: onVistaGeneral),
              KavidMenuCard(icon: Icons.login,          label: 'Entrar a hojas', onTap: onEntrarHojas),
              KavidMenuCard(icon: Icons.receipt_long,   label: 'Gastos diarios', onTap: onGastosDiarios),
              KavidMenuCard(icon: Icons.calendar_month, label: 'Calendario',     onTap: onCalendario),
              KavidMenuCard(icon: Icons.alarm,          label: 'Recordatorios',  onTap: onRecordatorios),
              KavidMenuCard(icon: Icons.person,         label: 'Usuario',        onTap: onUsuario),
              KavidMenuCard(icon: Icons.school,         label: 'Coach',          onTap: onCoach),
              KavidMenuCard(icon: Icons.settings,       label: 'Ajustes',        onTap: onAjustes),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
