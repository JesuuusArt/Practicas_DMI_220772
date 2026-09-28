/// Formato de hora tipo WhatsApp: `9:37 a.m.`, `12:05 p.m.`, `12:00 a.m.`.
///
/// La hora siempre viene en 12 horas con la hora sin cero a la izquierda
/// (`9:37` y no `09:37`) y el meridiem en minusculas y con punto.
String formatTimeOfDay(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final meridiem = time.hour < 12 ? 'a.m.' : 'p.m.';

  return '$hour12:$minute $meridiem';
}
