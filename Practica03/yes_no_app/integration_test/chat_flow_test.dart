import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:yes_no_app/config/helpers/format_time_of_day.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/screens/chat/chat_screen.dart';

/// Corre en un dispositivo o emulador real: usa la app de verdad, la API de
/// yesno.wtf de verdad y toca el boton de enviar de verdad.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const mensajes = <String>[
    'Comostu dia?', // 1
    'Buenos dias', // 2 sin ?, no debe responder
    'Vamos al gym?', // 3
    'TePuerto?', // 4
    'ok', // 5 sin ?
    'Comesmasenoche?', // 6
    'Quieressalir?', // 7
    'Estasahi?', // 8
    'zZz', // 9 sin ?
    'Studyudamos?', // 10
  ];

  testWidgets('manda 10 mensajes a la API real', (tester) async {
    final provider = await _arrancarApp(tester);
    final antes = DateTime.now();

    debugPrint('HORA DISPOSITIVO: ${antes.toIso8601String()}');
    debugPrint('HORA QUE SE MUESTRA: ${formatTimeOfDay(antes)}');

    for (final mensaje in mensajes) {
      await _enviar(tester, mensaje);
    }

    await _esperarA(
      tester,
      () => provider.messageList.length >= 2 + 10 + 7,
      const Duration(seconds: 90),
    );
    final despues = DateTime.now();

    _transcripcion(provider);
    debugPrint('HORA FINAL DISPOSITIVO: ${despues.toIso8601String()}');

    final chat = provider.messageList;
    final mios = chat.where((m) => m.fromWho == FromWho.me).toList();
    final deElla = chat.where((m) => m.fromWho == FromWho.hers).toList();

    // 1. Los 10 mensajes se environmentsaron, mas los 2 de ejemplo.
    expect(chat.length, 2 + 10 + 7);
    expect(mios.length, 2 + 10);
    for (final mensaje in mensajes) {
      expect(mios.map((m) => m.text), contains(mensaje),
          reason: 'falta "$mensaje"');
    }

    // 2. Respondio exactamente una vez a cada pregunta y a nada mas.
    //    No se comprueba "que mensaje va despues de cual" porque la API
    //    tarda mas que el intervalo con que se envian: una respuesta
    //    pendiente puede caer despues de un mensaje sin interrogacion.
    //    Lo que si es invariante es el conteo y el contenido.
    expect(deElla, hasLength(7));
    for (final respuesta in deElla) {
      expect(['Sí', 'No', 'Tal vez'], contains(respuesta.text),
          reason: 'ella solo contesta Sí, No o Tal vez');
      expect(respuesta.imageUrl, isNotNull,
          reason: 'toda respuesta trae su gif');
    }
    final preguntas = <String>{
      for (final m in mios)
        if (m.text.endsWith('?')) m.text,
    };
    expect(preguntas, hasLength(7));
    expect(mios.where((m) => !m.text.endsWith('?')).map((m) => m.text),
        containsAll(['Buenos dias', 'ok', 'zZz']));

    // 3. Cada mensaje lleva hora y cae dentro de la ventana de la prueba,
    //    o sea: es el reloj real, no un valor fijo ni congelado.
    final patron = RegExp(r'^\d{1,2}:\d{2} (a\.m\.|p\.m\.)$');
    for (final message in chat) {
      expect(message.sentAt.isAfter(antes.subtract(const Duration(seconds: 5))),
          isTrue,
          reason: '"${message.text}" tiene una hora vieja');
      expect(message.sentAt.isBefore(despues.add(const Duration(seconds: 5))),
          isTrue,
          reason: '"${message.text}" tiene una hora futura');
      expect(patron.hasMatch(formatTimeOfDay(message.sentAt)), isTrue);
    }

    // 4. Todas las horas coinciden con la hora actual del dispositivo, que a
    //    su vez coincide con la de la laptop.
    final horaEsperada = formatTimeOfDay(antes);
    final horaEsperadaFinal = formatTimeOfDay(despues);
    for (final message in chat) {
      final mostrada = formatTimeOfDay(message.sentAt);
      expect([horaEsperada, horaEsperadaFinal], contains(mostrada),
          reason: '"${message.text}" muestra $mostrada y el reloj ya no dice eso');
    }

    // 5. La hora se ve dibujada al pie de la burbuja, en formato WhatsApp.
    final etiquetas = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data?.trim())
        .whereType<String>()
        .where(patron.hasMatch)
        .toList();
    expect(etiquetas, isNotEmpty,
        reason: 'las burbujas visibles muestran su hora');
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('la hora avanza con el reloj del dispositivo', (tester) async {
    final provider = await _arrancarApp(tester);

    await _enviar(tester, 'Primera?');
    await _esperarA(tester, () => provider.messageList.length >= 4,
        const Duration(seconds: 60));

    final primera = provider.messageList.last.sentAt;
    debugPrint('PRIMERA HORA: ${formatTimeOfDay(primera)}');

    // Se espera a que el reloj cambie de minuto. Ojo: en un test de
    // integracion tester.pump() no consume tiempo real, asi que un loop de
    // pump seria un busy-loop que quema CPU. Aqui se duerme de verdad.
    final limite = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(limite) &&
        formatTimeOfDay(DateTime.now()) == formatTimeOfDay(primera)) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    await _enviar(tester, 'Segunda?');
    await _esperarA(tester, () => provider.messageList.length >= 6,
        const Duration(seconds: 60));

    final segunda = provider.messageList.last.sentAt;
    debugPrint('SEGUNDA HORA: ${formatTimeOfDay(segunda)}');

    expect(segunda.isAfter(primera), isTrue,
        reason: 'la hora del segundo mensaje debe ser posterior');
    expect(formatTimeOfDay(segunda), isNot(formatTimeOfDay(primera)),
        reason: 'las dos burbujas no pueden mostrar la misma hora');
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<ChatProvider> _arrancarApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  return Provider.of<ChatProvider>(
    tester.element(find.byType(ChatScreen)),
    listen: false,
  );
}

Future<void> _enviar(WidgetTester tester, String mensaje) async {
  await tester.enterText(find.byType(TextFormField), mensaje);
  await tester.pump();
  await tester.tap(find.byIcon(Icons.send_outlined));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _esperarA(
  WidgetTester tester,
  bool Function() condition,
  Duration timeout,
) async {
  final limite = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pump(const Duration(milliseconds: 500));
}
void _transcripcion(ChatProvider provider) {
  debugPrint('--- TRANSCRIPCION ---');
  for (final message in provider.messageList) {
    final quien = message.fromWho == FromWho.me ? 'me  ' : 'ella';
    final gif = message.imageUrl == null ? '    ' : '[gif]';
    debugPrint('  $quien  ${formatTimeOfDay(message.sentAt)}  '
        '$gif  ${message.text}');
  }
  debugPrint('--- FIN ---');
}
