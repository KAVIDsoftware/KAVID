// lib/features/vista_general/widgets/saldo_actual_card.dart
import 'package:flutter/material.dart';

class SaldoActualCard extends StatelessWidget {
  const SaldoActualCard({super.key});

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
                Icon(Icons.account_balance, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('Saldo actual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('Ingresos: 0,00 €', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Gastos: 0,00 €', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Saldo: 0,00 €',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
