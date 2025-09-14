// lib/features/vista_general/widgets/estado_global_hojas_card.dart
import 'package:flutter/material.dart';

class EstadoGlobalHojasCard extends StatelessWidget {
  const EstadoGlobalHojasCard({super.key});

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
                Icon(Icons.folder_copy, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('Estado de hojas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('Totales: 0 hojas', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Positivas: 0', style: TextStyle(fontSize: 16, color: Colors.green)),
            SizedBox(height: 4),
            Text('Negativas: 0', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
            SizedBox(height: 4),
            Text('Balance: 0',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFF9800))),
          ],
        ),
      ),
    );
  }
}
