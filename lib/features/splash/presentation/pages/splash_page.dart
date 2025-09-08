import 'package:flutter/material.dart';
import '../../../home/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  final String userName;
  const SplashPage({super.key, this.userName = 'KAVID'});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _nameCtrl;
  late final Animation<Offset> _nameSlide;

  static const Color kOrange = Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();

    // Entra (600 ms) → Pausa (1000 ms) → Sale (600 ms) = 2200 ms
    _nameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _nameSlide = TweenSequence<Offset>([
      // 1) Entra: fuera izquierda (-2) → centro (0)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-2, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 6, // 600 ms
      ),
      // 2) Pausa: centro (0) → centro (0) (evita ConstantTween para no chocar con 'const')
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: Offset.zero),
        weight: 10, // 1000 ms
      ),
      // 3) Sale: centro (0) → fuera derecha (+2)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(2, 0),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 6, // 600 ms
      ),
    ]).animate(_nameCtrl);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _nameCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOrange,
      body: SafeArea(
        child: Center(
          // Todo centrado verticalmente; el nombre va pegado debajo de “Bienvenido”
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // “Bienvenido” fijo
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8), // ajusta 6–12 si lo quieres más/menos pegado
              // Nombre: entra izq → (pausa 1s) → sale der (fuera de pantalla)
              SlideTransition(
                position: _nameSlide,
                child: Text(
                  widget.userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
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
