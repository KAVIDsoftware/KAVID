import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../home/presentation/pages/home_page.dart';

/// Secuencia exacta solicitada:
/// 1) "KAVID®" grande: APARECE L->R, pausa, DESAPARECE R->L.
/// 2) Muestra "Bienvenido" fijo.
/// 3) Nombre (dinámico; por defecto 'KAVID'): APARECE L->R, pausa, DESAPARECE R->L.
/// 4) Navega a Home.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.userName = 'KAVID'}); // <-- nombre dinámico
  final String userName;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // 1) Marca KAVID®
  late final AnimationController _brandCtrl;

  // 3) Nombre bajo "Bienvenido"
  late final AnimationController _nameCtrl;
  late final Animation<double> _nameProgress;

  // Mostrar "Bienvenido" al terminar la marca
  bool _showWelcome = false;

  static const _bg = Color(0xFFF57C00); // Naranja suave

  @override
  void initState() {
    super.initState();

    // Controlador de la marca (KAVID®)
    _brandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),        // aparece L->R
      reverseDuration: const Duration(milliseconds: 750), // desaparece R->L
    );

    // Controlador del nombre (bajo "Bienvenido")
    _nameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),        // aparece L->R
      reverseDuration: const Duration(milliseconds: 750), // desaparece R->L
    );
    _nameProgress = CurvedAnimation(
      parent: _nameCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Orquestación EXACTA
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        // 1) Marca
        await _brandCtrl.forward();                         // L -> R
        await Future.delayed(const Duration(milliseconds: 450));
        await _brandCtrl.reverse();                         // R -> L

        // 2) "Bienvenido" fijo
        if (!mounted) return;
        setState(() => _showWelcome = true);
        await Future.delayed(const Duration(milliseconds: 200));

        // 3) Nombre dinámico: aparece L->R, pausa, desaparece R->L
        await _nameCtrl.forward();                          // L -> R
        await Future.delayed(const Duration(milliseconds: 600));
        await _nameCtrl.reverse();                          // R -> L
      } finally {
        if (!mounted) return;
        // 4) Entrar a Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Tamaños responsivos para móvil
    final brandSize   = (w * 0.20).clamp(42.0, 68.0); // KAVID® superior
    final rSize       = (brandSize * 0.28).clamp(12.0, 20.0);
    final welcomeSize = (w * 0.075).clamp(20.0, 28.0); // "Bienvenido"
    final nameSize    = (w * 0.11).clamp(34.0, 48.0);  // Nombre bajo

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) KAVID® (reveal L->R y hide R->L)
                _BrandReveal(
                  controller: _brandCtrl,
                  text: 'KAVID',
                  brandSize: brandSize,
                  rSize: rSize,
                ),

                const SizedBox(height: 22),

                // 2) "Bienvenido" fijo tras terminar la marca
                AnimatedOpacity(
                  opacity: _showWelcome ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  child: Text(
                    'Bienvenido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: welcomeSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3) Nombre bajo "Bienvenido": aparece L->R, pausa, desaparece R->L
                if (_showWelcome)
                  _NameReveal(
                    controller: _nameCtrl,
                    progress: _nameProgress,
                    text: widget.userName, // <-- ahora usa el nombre dinámico
                    style: TextStyle(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto “KAVID®” que se revela de IZQUIERDA->DERECHA y se oculta de DERECHA->IZQUIERDA.
/// NOTA: anclamos SIEMPRE el recorte a la izquierda. En reverse (t baja) se oculta desde la derecha.
class _BrandReveal extends StatelessWidget {
  const _BrandReveal({
    required this.controller,
    required this.text,
    required this.brandSize,
    required this.rSize,
  });

  final AnimationController controller;
  final String text;
  final double brandSize;
  final double rSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value.clamp(0.0, 1.0); // 0..1

        return ClipPath(
          clipper: _LeftAnchoredRevealClipper(progress: t),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: text,
                  style: TextStyle(
                    fontSize: brandSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                    child: Text(
                      '®',
                      style: TextStyle(
                        fontSize: rSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Nombre centrado que se REVELA de IZQUIERDA->DERECHA y se OCULTA de DERECHA->IZQUIERDA
/// usando el mismo truco: recorte SIEMPRE anclado a la izquierda.
class _NameReveal extends StatelessWidget {
  const _NameReveal({
    required this.controller,
    required this.progress,
    required this.text,
    required this.style,
  });

  final AnimationController controller;
  final Animation<double> progress;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        final t = progress.value.clamp(0.0, 1.0);

        return Center(
          child: ClipPath(
            clipper: _LeftAnchoredRevealClipper(progress: t),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        );
      },
    );
  }
}

/// Clipper anclado a la IZQUIERDA:
/// - forward (t sube 0->1): aparece L->R.
/// - reverse (t baja 1->0): se oculta R->L (porque el ancho visible se contrae hacia la izquierda).
class _LeftAnchoredRevealClipper extends CustomClipper<Path> {
  _LeftAnchoredRevealClipper({required this.progress});
  final double progress; // 0..1

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final visW = w * progress; // siempre medimos desde la IZQUIERDA
    final Rect rect = Rect.fromLTWH(0, 0, visW, h);
    return Path()..addRect(rect);
  }

  @override
  bool shouldReclip(covariant _LeftAnchoredRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}
