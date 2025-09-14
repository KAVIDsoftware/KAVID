// lib/features/vista_general/presentation/pages/vista_general_page.dart
import 'package:flutter/material.dart';

// Widgets de Vista General
import '../widgets/estado_global_hojas_card.dart';
import '../widgets/gastos_mes_hoy.dart';
import '../widgets/saldo_actual_card.dart';
import '../widgets/prestamos_tarjetas_card.dart';
import '../widgets/evolucion_hojas_card.dart';
import '../widgets/actividad_reciente.dart';
import '../widgets/alertas_activas_card.dart';
import '../widgets/tip_del_dia_card.dart';

class VistaGeneralPage extends StatelessWidget {
  const VistaGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Buenos días Usuario',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'viernes, 12 de septiembre de 2025',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Aquí tienes tu resumen general',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1),

              // Bloques (deja cada constructor como const)
              const EstadoGlobalHojasCard(),
              const GastosMesHoyCard(),
              const SaldoActualCard(),
              const PrestamosTarjetasCard(),
              const EvolucionHojasCard(),
              const ActividadReciente(),
              const AlertasActivasCard(),
              const TipDelDiaCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
