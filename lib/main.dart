import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KavidApp());
}

class KavidApp extends StatelessWidget {
  const KavidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'KAVID',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
