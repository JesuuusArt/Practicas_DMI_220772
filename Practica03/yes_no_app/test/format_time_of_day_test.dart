import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/config/helpers/format_time_of_day.dart';

void main() {
  group('formatTimeOfDay', () {
    test('usa el formato de WhatsApp: 9:37 a.m.', () {
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 9, 37)), '9:37 a.m.');
    });

    test('rellena con cero los minutos', () {
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 9, 5)), '9:05 a.m.');
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 14, 3)), '2:03 p.m.');
    });

    test('no pone cero a la izquierda de la hora', () {
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 1, 0)), '1:00 a.m.');
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 11, 59)), '11:59 a.m.');
    });

    test('usa 12 en lugar de 0 en medianoche y mediodia', () {
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 0, 0)), '12:00 a.m.');
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 12, 0)), '12:00 p.m.');
    });

    test('cambia a p.m. a partir de las 12:00', () {
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 11, 59)), '11:59 a.m.');
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 12, 1)), '12:01 p.m.');
      expect(formatTimeOfDay(DateTime(2026, 9, 28, 23, 45)), '11:45 p.m.');
    });
  });
}
