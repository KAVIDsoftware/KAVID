// lib/features/vista_general/widgets/actividad_reciente.dart
import 'package:flutter/material.dart';

class ActividadReciente extends StatelessWidget {
  const ActividadReciente({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> actividades = []; // sin datos

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('Actividad reciente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (actividades.isEmpty)
              const Text('Sin actividad', style: TextStyle(fontSize: 15, color: Colors.black54))
            else
              for (final a in actividades)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $a', style: const TextStyle(fontSize: 15)),
                ),
          ],
        ),
      ),
    );
  }
}
