// lib/features/vista_general/widgets/evolucion_hojas_card.dart
import 'package:flutter/material.dart';

class EvolucionHojasCard extends StatelessWidget {
  const EvolucionHojasCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_flat, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('Evolución de hojas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('Hojas nuevas este mes: 0', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Mes anterior: 0', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Sin variación (0%)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
