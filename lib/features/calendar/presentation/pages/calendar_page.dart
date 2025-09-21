import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/kavid_calendar.dart';

/// Página de Calendario de KAVID
/// - Constructor const para permitir `const CalendarPage()` desde Home.
/// - Mantiene integración con el widget `KavidCalendar`.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Formato de fecha en español (ya inicializado en main.dart)
    final hoy = DateFormat.yMMMMEEEEd('es_ES').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado simple con la fecha de hoy
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFFF9800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hoy,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calendario KAVID (con overflow del header resuelto)
              const Expanded(
                child: SingleChildScrollView(
                  child: KavidCalendar(
                    headerTitle: null, // mantenemos el header propio del TableCalendar
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
