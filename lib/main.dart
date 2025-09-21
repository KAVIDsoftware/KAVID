import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// === IMPORTS EXISTENTES DE TU APP ===
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';

// 🔶 IMPORTA LA PÁGINA DE GASTOS (RUTA RELATIVA, SOPORTA CARPETA CON ESPACIO)
import 'features/gastos diarios/presentation/pages/gastos_diarios_page.dart';

/// KAVID - App principal
/// - Arreglo de LocaleDataException para calendario (intl/es_ES)
/// - Mantiene SplashPage -> HomePage tal cual
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Necesario para table_calendar/intl en español
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  runApp(const KavidApp());
}

class KavidApp extends StatelessWidget {
  const KavidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAVID',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const SplashPage(),
        '/home': (_) => const HomePage(),

        // 🔶 NUEVA RUTA CON NOMBRE PARA GASTOS DIARIOS
        '/gastos-diarios': (_) => const GastosDiariosPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFF9800), // Naranja KAVID
      ),
    );
  }
}
