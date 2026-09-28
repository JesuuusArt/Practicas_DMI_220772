import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

class _FakeGetYesNoAnswer extends GetYesNoAnswer {
  _FakeGetYesNoAnswer(this._build);

  final Message Function() _build;

  @override
  Future<Message> getAnswer() async => _build();
}

/// Reloj fijo: 28/09/2026 09:36, la hora que ve el usuario en su laptop.
final _clock = DateTime(2026, 9, 28, 9, 36);

ChatProvider _providerWith(Message Function() build) => ChatProvider(
      getYesNoAnswer: _FakeGetYesNoAnswer(build),
      now: () => _clock,
    );

Future<void> _waitFor(ChatProvider provider, int length) async {
  for (var i = 0; i < 100; i++) {
    if (provider.messageList.length >= length) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  test('ignora mensajes vacios o con solo espacios', () async {
    final provider = _providerWith(
      () => Message(text: 'No', fromWho: FromWho.hers, sentAt: _clock),
    );

    await provider.sendMessage('');
    await provider.sendMessage('   ');

    expect(provider.messageList.length, 2);
  });

  test('no pide respuesta si el mensaje no termina en "?"', () async {
    var called = false;
    final provider = _providerWith(() {
      called = true;
      return Message(text: 'No', fromWho: FromWho.hers, sentAt: _clock);
    });

    await provider.sendMessage('Hola amor');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(called, isFalse);
    expect(provider.messageList.length, 3);
  });

  test('agrega la respuesta cuando la pregunta termina en "?"', () async {
    final provider = _providerWith(
      () => Message(text: 'Sí', fromWho: FromWho.hers, sentAt: _clock),
    );

    await provider.sendMessage('Como estas?');
    await _waitFor(provider, 4);

    expect(provider.messageList[2].text, 'Como estas?');
    expect(provider.messageList[2].fromWho, FromWho.me);
    expect(provider.messageList[3].text, 'Sí');
    expect(provider.messageList[3].fromWho, FromWho.hers);
  });

  test('muestra el error en el chat si la API falla', () async {
    final provider = _providerWith(
      () => throw const YesNoException('No hay conexion a internet.'),
    );

    await provider.sendMessage('Estas ahi?');
    await _waitFor(provider, 4);

    expect(provider.messageList.last.fromWho, FromWho.hers);
    expect(provider.messageList.last.text, 'No hay conexion a internet.');
    expect(provider.messageList.last.imageUrl, isNull);
  });

  test('las respuestas no se intercalan entre si', () async {
    final provider = _providerWith(
      () => Message(text: 'No', fromWho: FromWho.hers, sentAt: _clock),
    );

    await provider.sendMessage('Primera?');
    await provider.sendMessage('Segunda?');
    await _waitFor(provider, 6);

    expect(provider.messageList.length, 6);
    expect(provider.messageList[2].text, 'Primera?');
    expect(provider.messageList[3].text, 'Segunda?');
    expect(provider.messageList[4].fromWho, FromWho.hers);
    expect(provider.messageList[5].fromWho, FromWho.hers);
  });

  group('hora de envio', () {
    test('el mensaje que mando el usuario queda con la hora actual', () async {
      final provider = _providerWith(
        () => Message(text: 'No', fromWho: FromWho.hers, sentAt: _clock),
      );

      await provider.sendMessage('Vamos al gym?');

      expect(provider.messageList.last.sentAt, _clock);
    });

    test('la respuesta de la API tambien queda con la hora actual',
        () async {
      final provider = _providerWith(
        () => Message(
          text: 'Sí',
          fromWho: FromWho.hers,
          sentAt: DateTime(1990),
        ),
      );

      await provider.sendMessage('Vamos al gym?');
      await _waitFor(provider, 4);

      expect(provider.messageList.last.sentAt, _clock);
    });

    test('tambien estampa la hora cuando la API falla', () async {
      final provider = _providerWith(
        () => throw const YesNoException('No hay conexion a internet.'),
      );

      await provider.sendMessage('Estas ahi?');
      await _waitFor(provider, 4);

      expect(provider.messageList.last.sentAt, _clock);
    });

    test('los mensajes de ejemplo ya traen hora', () {
      final provider = _providerWith(
        () => Message(text: 'No', fromWho: FromWho.hers, sentAt: _clock),
      );

      expect(provider.messageList, hasLength(2));
      expect(provider.messageList.first.sentAt, isA<DateTime>());
      expect(provider.messageList.last.sentAt, isA<DateTime>());
    });
  });
}
