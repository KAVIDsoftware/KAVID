import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/gastos_local_store.dart'; // opcional: load/remove si ya lo usas
import '../../data/models/expense_entry.dart';
import 'expense_edit_page.dart';

const kOrange = Color(0xFFFF9800);
const _prefsKey = 'gastos_all_v1'; // lista persistida

/// Filtros activos: Hoy / Semana / Mes (sin "Todo")
enum RangeFilter { today, week, month }

class GastosDiariosPage extends StatefulWidget {
  const GastosDiariosPage({super.key});

  @override
  State<GastosDiariosPage> createState() => _GastosDiariosPageState();
}

class _GastosDiariosPageState extends State<GastosDiariosPage> {
  final _store = GastosLocalStore(); // compatibilidad con tu store

  List<ExpenseEntry> _all = [];
  RangeFilter _filter = RangeFilter.today;

  XFile? _lastImage;

  // ------------ Persistencia lista ------------
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _all
        .map((e) => {
      'id': e.id,
      'merchant': e.merchant,
      'description': e.description,
      'amount': e.amount,
      'date': e.date.toIso8601String(),
      'category': e.category,
      'paymentMethod': e.paymentMethod,
    })
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<List<ExpenseEntry>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((m) {
        final map = Map<String, dynamic>.from(m as Map);
        return ExpenseEntry(
          id: map['id'] as String,
          merchant: (map['merchant'] ?? '') as String,
          description: (map['description'] ?? '') as String,
          amount: (map['amount'] as num).toDouble(),
          date: DateTime.parse(map['date'] as String),
          category: (map['category'] ?? 'General') as String,
          paymentMethod: (map['paymentMethod'] ?? 'Desconocido') as String,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    // 1) Cargar desde SharedPreferences
    var data = await _loadFromPrefs();

    // 2) Si está vacío, intentar tu store (por compatibilidad)
    if (data.isEmpty) {
      try {
        data = await _store.loadAll();
      } catch (_) {
        data = [];
      }
    }

    setState(() {
      _all = data..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // Contador actual de tickets (sube/baja con la lista)
  int get _ticketCount => _all.length;

  Future<void> _openCamera() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      if (img == null) return;
      if (!mounted) return;

      final draft = ExpenseEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        merchant: '',
        description: '',
        amount: 0.0,
        date: DateTime.now(), // por defecto hoy
        category: 'General',
        paymentMethod: 'Desconocido',
      );

      final result = await Navigator.of(context).push<ExpenseEntry>(
        MaterialPageRoute(
          builder: (_) => ExpenseEditPage(initial: draft, imagePath: img.path),
        ),
      );

      if (!mounted) return;

      if (result != null) {
        _applyLocalChange(result); // añade/actualiza en la lista
        await _saveToPrefs();      // persiste
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto guardado')),
        );
      }

      setState(() => _lastImage = img);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la cámara: $e')),
      );
    }
  }

  Future<void> _editEntry(ExpenseEntry entry) async {
    if (!mounted) return;
    final edited = await Navigator.of(context).push<ExpenseEntry>(
      MaterialPageRoute(
        builder: (_) => ExpenseEditPage(initial: entry, imagePath: null),
      ),
    );
    if (!mounted) return;
    if (edited != null) {
      _applyLocalChange(edited);
      await _saveToPrefs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto actualizado')),
      );
    }
  }

  void _applyLocalChange(ExpenseEntry e) {
    final idx = _all.indexWhere((x) => x.id == e.id);
    if (idx >= 0) {
      _all[idx] = e;
    } else {
      _all.insert(0, e);
    }
    _all.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _filter = RangeFilter.today; // tras guardar/editar, volvemos a Hoy
    });
  }

  bool _inToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _inWeek(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: now.weekday - 1)); // lunes
    final end = start.add(const Duration(days: 7));
    return !d.isBefore(start) && d.isBefore(end);
  }

  bool _inMonth(DateTime d) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return !d.isBefore(start) && d.isBefore(end);
  }

  List<ExpenseEntry> get _filtered {
    switch (_filter) {
      case RangeFilter.today:
        return _all.where((e) => _inToday(e.date)).toList();
      case RangeFilter.week:
        return _all.where((e) => _inWeek(e.date)).toList();
      case RangeFilter.month:
        return _all.where((e) => _inMonth(e.date)).toList();
    }
  }

  double get _totalFiltered => _filtered.fold(0.0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Gastos diarios'),
      ),
      body: Column(
        children: [
          // ======= Cabecera secundaria centrada: icono cámara + "Ticket" =======
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openCamera,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 22, color: kOrange),
                    Text(
                      'Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kOrange,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ======= Filtros + total del rango + CONTADOR =======
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12),
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(RangeFilter.today, 'Hoy'),
                          _chip(RangeFilter.week, 'Semana'),
                          _chip(RangeFilter.month, 'Mes'),
                        ],
                      ),
                    ),
                    _ticketCounterPill(_ticketCount), // 👈 contador actual
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total del rango',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      money.format(_totalFiltered),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ======= Listado =======
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No hay gastos en este rango.'))
                : ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = _filtered[i];
                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar gasto'),
                        content: const Text(
                            '¿Seguro que deseas eliminar este gasto?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ) ??
                        false;
                  },
                  onDismissed: (_) async {
                    _all.removeWhere((x) => x.id == e.id);
                    await _saveToPrefs(); // 👈 contador baja al persistir nueva lista
                    try {
                      await _store.removeById(e.id);
                    } catch (_) {}
                    setState(() {}); // refresca chips, total y contador
                  },
                  child: ListTile(
                    onLongPress: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar gasto'),
                          content: const Text(
                              '¿Seguro que deseas eliminar este gasto?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ) ??
                          false;
                      if (ok) {
                        _all.removeWhere((x) => x.id == e.id);
                        await _saveToPrefs(); // 👈 contador baja
                        try {
                          await _store.removeById(e.id);
                        } catch (_) {}
                        setState(() {});
                      }
                    },
                    leading:
                    const Icon(Icons.store_mall_directory_outlined),
                    title: Text(
                      e.merchant.isNotEmpty ? e.merchant : e.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${df.format(e.date)} · ${e.category} · ${e.paymentMethod}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Importe + editar + borrar
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          money.format(e.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon:
                          const Icon(Icons.edit, color: Colors.black87),
                          tooltip: 'Editar',
                          onPressed: () => _editEntry(e),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          tooltip: 'Eliminar',
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar gasto'),
                                content: const Text(
                                    '¿Seguro que deseas eliminar este gasto?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            ) ??
                                false;
                            if (ok) {
                              _all.removeWhere((x) => x.id == e.id);
                              await _saveToPrefs(); // 👈 contador baja
                              try {
                                await _store.removeById(e.id);
                              } catch (_) {}
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_lastImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Última foto: ${_lastImage!.name}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(RangeFilter f, String label) {
    final selected = _filter == f;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = f),
      selectedColor: const Color(0x26FF9800), // kOrange 15% alpha
      side: BorderSide(color: selected ? kOrange : Colors.black12),
      labelStyle: TextStyle(
        color: selected ? kOrange : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // Pill de contador de tickets (icono + número)
  Widget _ticketCounterPill(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: kOrange),
        color: const Color(0x0FFF9800), // naranja muy suave
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 18, color: kOrange),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: kOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
