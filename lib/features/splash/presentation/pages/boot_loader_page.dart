import 'package:flutter/material.dart';
import 'splash_page.dart';

/// Pantalla inicial ligera:
/// - Fondo naranja (#FF9800)
/// - Logotipo K A [✓] I D (el ✓ dentro de círculo blanco)
/// - Debajo: 3 bolitas blancas que se encienden 1→2→3 en bucle
/// - Dura ~2.6s y navega a SplashPage (Bienvenido + nombre)
class BootLoaderPage extends StatefulWidget {
  const BootLoaderPage({super.key});

  @override
  State<BootLoaderPage> createState() => _BootLoaderPageState();
}

class _BootLoaderPageState extends State<BootLoaderPage>
    with TickerProviderStateMixin {
  static const orange = Color(0xFFFF9800);
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    // Animación de las bolitas (ciclo de 900 ms)
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Tras ~2.6 s pasamos a SplashPage (la tuya de “Bienvenido” + nombre)
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      _dotsCtrl.stop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SplashPage()),
      );
    });
  }

  @override
  void dispose() {
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orange, // MISMO NARANJA QUE EL TEMA DE ARRANQUE
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _KavidWordmark(size: 112), // logo grande
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _dotsCtrl,
                builder: (context, _) {
                  // Pasos: 1, 2, 3 bolitas encendidas (ciclo)
                  final step = ((_dotsCtrl.value * 3).floor() % 3) + 1;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final on = i < step;
                      return Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
                        decoration: BoxDecoration(
                          color: on
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logotipo en código: “K A [círculo blanco con check naranja] I D”
class _KavidWordmark extends StatelessWidget {
  const _KavidWordmark({super.key, this.size = 112});

  final double size; // altura aproximada del conjunto
  static const orange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      fontSize: size * 0.42, // proporción equilibrada
      letterSpacing: 2,
      height: 1.0,
    );

    final circleSize = size * 0.56; // diámetro del círculo del check

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('KA', style: textStyle),
        SizedBox(width: size * 0.10),
        SizedBox(
          width: circleSize,
          height: circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                Icons.check_rounded,
                color: orange,
                size: circleSize * 0.65,
              ),
            ],
          ),
        ),
        SizedBox(width: size * 0.10),
        Text('ID', style: textStyle),
      ],
    );
  }
}
