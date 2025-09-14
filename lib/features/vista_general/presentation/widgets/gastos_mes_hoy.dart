// lib/features/vista_general/widgets/gastos_mes_hoy.dart
import 'package:flutter/material.dart';

class GastosMesHoyCard extends StatelessWidget {
  const GastosMesHoyCard({super.key});

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
                Icon(Icons.account_balance_wallet, color: Color(0xFFFF9800)),
                SizedBox(width: 8),
                Text('Gastos del mes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('Total: 0,00 €', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('0% respecto al mes anterior', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
