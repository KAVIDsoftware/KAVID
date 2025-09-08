import 'package:flutter/material.dart';
import 'features/splash/presentation/pages/boot_loader_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KAVID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF9800)),
        useMaterial3: true,
      ),
      home: const BootLoaderPage(), // ← arranque directo aquí
    );
  }
}
