// lib/features/vista_general/widgets/tip_del_dia_card.dart
import 'package:flutter/material.dart';

class TipDelDiaCard extends StatelessWidget {
  const TipDelDiaCard({super.key});

  @override
  Widget build(BuildContext context) {
    const String tip = ''; // sin datos

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Color(0xFFFF9800)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip.isEmpty ? 'Sin tip por ahora' : tip,
                style: const TextStyle(fontSize: 16, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
