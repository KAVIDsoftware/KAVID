import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Widget de calendario para KAVID (fix overflow y compatibilidad con withValues).
class KavidCalendar extends StatefulWidget {
  const KavidCalendar({
    super.key,
    this.onDaySelected,
    this.initialFocusedDay,
    this.headerTitle,
  });

  final void Function(DateTime selectedDay)? onDaySelected;
  final DateTime? initialFocusedDay;
  final String? headerTitle;

  @override
  State<KavidCalendar> createState() => _KavidCalendarState();
}

class _KavidCalendarState extends State<KavidCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    const kOrange = Color(0xFFFF9800);
    // Usamos .withValues(alpha: ...) como recomienda Flutter
    final divider = const Color(0xFF000000).withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.headerTitle != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.headerTitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Divider(height: 1, color: divider),
          const SizedBox(height: 8),
        ],

        // === TABLE CALENDAR ===
        TableCalendar<Object?>(
          locale: 'es_ES',
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,

          // Selección
          selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected?.call(selectedDay);
          },

          // Gestos y formato (mantenemos swipe; ocultamos chip de formato para evitar overflow)
          availableGestures: AvailableGestures.all,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },

          startingDayOfWeek: StartingDayOfWeek.monday,

          // ===== FIX OVERFLOW en el encabezado =====
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false, // ocultamos "2 weeks" para que no desborde
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            leftChevronVisible: true,
            rightChevronVisible: true,
          ),

          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            weekendStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          calendarStyle: CalendarStyle(
            // Hoy
            todayDecoration: BoxDecoration(
              color: kOrange.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),

            // Seleccionado
            selectedDecoration: const BoxDecoration(
              color: kOrange,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),

            // Días fuera del mes
            outsideDaysVisible: true,
            outsideTextStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.30),
            ),

            // Días por defecto
            defaultTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            weekendTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
