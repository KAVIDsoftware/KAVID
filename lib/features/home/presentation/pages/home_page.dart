import 'package:flutter/material.dart';
import '../widgets/start_menu.dart';
import '../widgets/cells_preview.dart';
import '../widgets/kavid_appbar.dart';
import 'general_overview_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color orange = Color(0xFFFF9800);

  void _openArchivador(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Archivador (próximamente)')),
    );
  }

  void _openOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GeneralOverviewPage()),
    );
  }

  void _openSheets(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _SheetsPage()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _SettingsPage()),
    );
  }

  void _openCalendario(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calendario (próximamente)')),
    );
  }

  void _openUsuario(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario (próximamente)')),
    );
  }

  void _openCoach(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coach (próximamente)')),
    );
  }

  void _openRecordatorios(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorios (próximamente)')),
    );
  }

  void _openGastos(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gastos diarios (próximamente)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orange,
      body: SafeArea(
        child: StartMenu(
          onArchivador:   () => _openArchivador(context), // antes onNewBook
          onVistaGeneral: () => _openOverview(context),    // antes onOverview
          onEntrarHojas:  () => _openSheets(context),      // antes onOpenSheets
          onAjustes:      () => _openSettings(context),    // antes onSettings
          onCalendario:   () => _openCalendario(context),
          onUsuario:      () => _openUsuario(context),
          onCoach:        () => _openCoach(context),
          onRecordatorios:() => _openRecordatorios(context),
          onGastosDiarios:() => _openGastos(context),
        ),
      ),
    );
  }
}

// --------- Páginas internas simples ---------

class _SheetsPage extends StatelessWidget {
  const _SheetsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KavidAppBar(),
      body: const CellsPreview(columns: 7, rows: 18),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KavidAppBar(),
      body: Center(child: Text('Ajustes (en construcción)')),
    );
  }
}
