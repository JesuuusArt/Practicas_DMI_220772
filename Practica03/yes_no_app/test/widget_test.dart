import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_bubble.dart';

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
      const MaterialApp(
        home: Scaffold(
          body: HerMessageBubble(
            message: Message(text: 'No', fromWho: FromWho.hers),
          ),
        ),
      ),
    );

    expect(find.text('No'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
