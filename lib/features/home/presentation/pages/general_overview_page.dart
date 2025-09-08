import 'package:flutter/material.dart';

class GeneralOverviewPage extends StatelessWidget {
  const GeneralOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800); // mismo que el splash
    final percent = 0.68; // placeholder

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: orange,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            // Batería
            Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(percent * 100).round()}% restante',
                      style: const TextStyle(
                        color: Colors.orange, // contraste dentro del relleno blanco
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Pulsa atrás para volver',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
