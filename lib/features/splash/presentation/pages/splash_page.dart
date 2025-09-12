import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kavid/features/home/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _nameCtrl;
  late Animation<Offset> _nameSlide;
  String _userName = '';

  static const _totalDuration = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    _nameCtrl = AnimationController(vsync: this, duration: _totalDuration);
    _initNameAndAnim();
  }

  Future<void> _initNameAndAnim() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getString('user_name') ?? '').trim();

    if (!mounted) return;
    setState(() => _userName = saved);

    _nameSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-2, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 6, // 600 ms
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: Offset.zero),
        weight: 10, // 1000 ms
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(2, 0))
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 6, // 600 ms
      ),
    ]).animate(_nameCtrl);

    await _nameCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kSplashOrange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: kSplashOrange,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 8),
              SlideTransition(
                position: _nameSlide,
                child: Text(
                  _userName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
