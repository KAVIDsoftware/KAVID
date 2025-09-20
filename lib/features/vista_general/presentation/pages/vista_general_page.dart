import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === Tarjetas (Tema 5A) ===
import '../widgets/estado_global_hojas_card.dart';
import '../widgets/gastos_mes_hoy.dart';
import '../widgets/saldo_actual_card.dart';
import '../widgets/prestamos_tarjetas_card.dart';
import '../widgets/evolucion_hojas_card.dart';
import '../widgets/actividad_reciente.dart'; // <- define ActividadReciente
import '../widgets/alertas_activas_card.dart';
import '../widgets/tip_del_dia_card.dart';

/// Vista general (Dashboard informativo)
/// - Saludo con nombre guardado (SharedPreferences, clave 'user_name').
/// - Fecha real del sistema en español.
/// - Tarjetas informativas (Tema 5A).
class VistaGeneralPage extends StatefulWidget {
  const VistaGeneralPage({super.key});

  @override
  State<VistaGeneralPage> createState() => _VistaGeneralPageState();
}

class _VistaGeneralPageState extends State<VistaGeneralPage> {
  String _userName = 'Usuario';
  late String _todayStr;

  @override
  void initState() {
    super.initState();
    // Fecha real (es_ES ya inicializado en main.dart)
    _todayStr = DateFormat.yMMMMEEEEd('es_ES').format(DateTime.now());
    _loadUserName();
  }

  /// Carga el nombre desde SharedPreferences (clave: 'user_name').
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('user_name');
    if (!mounted) return;
    setState(() {
      _userName = (saved == null || saved.trim().isEmpty) ? 'Usuario' : saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headline = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
    );
    final sub = theme.textTheme.titleMedium?.copyWith(
      color: Colors.black54,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista general'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ===== Encabezado con saludo + fecha real =====
            Text('Buenos días $_userName', style: headline),
            const SizedBox(height: 8),
            Text(_todayStr, style: sub),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Aquí tienes tu resumen general',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // ===== Tarjetas informativas (Tema 5A) =====
            EstadoGlobalHojasCard(),
            const SizedBox(height: 12),
            GastosMesHoyCard(),
            const SizedBox(height: 12),
            SaldoActualCard(),
            const SizedBox(height: 12),
            PrestamosTarjetasCard(),
            const SizedBox(height: 12),
            EvolucionHojasCard(),
            const SizedBox(height: 12),

            // 🔧 Aquí estaba el fallo: la clase correcta es ActividadReciente (no ...Card)
            ActividadReciente(),
            const SizedBox(height: 12),

            AlertasActivasCard(),
            const SizedBox(height: 12),
            TipDelDiaCard(),
          ],
        ),
      ),
    );
  }
}
