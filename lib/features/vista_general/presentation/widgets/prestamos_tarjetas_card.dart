// lib/features/vista_general/widgets/prestamos_tarjetas_card.dart
import 'package:flutter/material.dart';

class PrestamosTarjetasCard extends StatelessWidget {
  const PrestamosTarjetasCard({super.key});

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
                Icon(Icons.credit_card, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text(
                  'Préstamos y tarjetas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Préstamos: 0,00 €', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Tarjetas: 0,00 €', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Total deuda: 0,00 €',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
