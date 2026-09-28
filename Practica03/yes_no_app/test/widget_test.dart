import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/shared/message_time_label.dart';
void main() {
  testWidgets('Chat screen renders without layout errors', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bb farias'), findsOneWidget);
    expect(find.text('Escribe y termina con "?" para que te responda'), findsOneWidget);
    expect(find.text('Hola Bb farias!'), findsOneWidget);
    expect(find.text('Vamos al gym?'), findsOneWidget);
  });

  testWidgets('HerMessageBubble renders sin imageUrl', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HerMessageBubble(
            message: Message(
              text: 'No',
              fromWho: FromWho.hers,
              sentAt: DateTime(2026, 9, 28, 9, 36),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('hora de envio', () {
    testWidgets('MyMessageBubble muestra la hora en la esquina inferior derecha',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyMessageBubble(
              message: Message(
                text: 'Vamos al gym?',
                fromWho: FromWho.me,
                sentAt: DateTime(2026, 9, 28, 9, 36),
              ),
            ),
          ),
        ),
      );

      expect(find.text('9:36 a.m.'), findsOneWidget);
      _expectTimeIsBottomRight(tester,
          message: 'Vamos al gym?', time: '9:36 a.m.');
    });

    testWidgets('HerMessageBubble muestra la hora en la esquina inferior derecha',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HerMessageBubble(
              message: Message(
                text: 'Sí',
                fromWho: FromWho.hers,
                sentAt: DateTime(2026, 9, 28, 14, 5),
              ),
            ),
          ),
        ),
      );

      expect(find.text('2:05 p.m.'), findsOneWidget);
      _expectTimeIsBottomRight(tester, message: 'Sí', time: '2:05 p.m.');
    });

    testWidgets('las dos burbujas comparten el mismo estilo de hora',
        (tester) async {
      final sentAt = DateTime(2026, 9, 28, 9, 36);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MyMessageBubble(
                  message: Message(
                      text: 'Vamos al gym?', fromWho: FromWho.me, sentAt: sentAt),
                ),
                HerMessageBubble(
                  message: Message(
                      text: 'Sí', fromWho: FromWho.hers, sentAt: sentAt),
                ),
              ],
            ),
          ),
        ),
      );

      final styles = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(MessageTimeLabel),
            matching: find.byType(Text),
          ))
          .map((text) => text.style)
          .toList();

      expect(styles, hasLength(2));
      expect(styles.first, styles.last);
    });
  });
}

/// La hora siempre pegada a la esquina inferior derecha de la burbuja,
/// respetando su margen interior, y por debajo del texto del mensaje.
void _expectTimeIsBottomRight(
  WidgetTester tester, {
  required String message,
  required String time,
}) {
  final bubbleRect = tester.getRect(
      find.ancestor(of: find.text(time), matching: find.byKey(bubbleKey)));
  final timeRect = tester.getRect(find.text(time));
  final messageRect = tester.getRect(find.text(message));

  expect(timeRect.right, closeTo(bubbleRect.right - bubblePadding.right, 0.5));
  expect(
      timeRect.bottom, closeTo(bubbleRect.bottom - bubblePadding.bottom, 0.5));
  expect(timeRect.top, greaterThanOrEqualTo(messageRect.bottom));
  expect(timeRect.left, greaterThanOrEqualTo(bubbleRect.left));
}
