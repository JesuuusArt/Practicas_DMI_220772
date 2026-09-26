import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';

/// Reproduce el comportamiento real de https://yesno.wtf/api:
/// NO conoce el parametro `?force=` y solo responde `yes` o `no` al azar.
class _FakeYesNoApi implements HttpClientAdapter {
  _FakeYesNoApi({this.answers = const ['no', 'yes']});

  final List<String> answers;
  final List<Uri> requests = [];
  int _calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    final answer = answers[_calls++ % answers.length];

    return ResponseBody.fromString(
      jsonEncode({
        'answer': answer,
        'forced': false,
        'image': 'https://yesno.wtf/assets/$answer/x.gif',
      }),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }
}

Dio _dioWith(HttpClientAdapter adapter) => Dio()..httpClientAdapter = adapter;

void main() {
  group('sorteo local de porcentajes', () {
    test('respeta los limites cuando solo hay una opcion con peso', () {
      final onlyYes =
          GetYesNoAnswer(weights: const AnswerWeights(yes: 1, no: 0, maybe: 0));
      final onlyNo =
          GetYesNoAnswer(weights: const AnswerWeights(yes: 0, no: 1, maybe: 0));
      final onlyMaybe =
          GetYesNoAnswer(weights: const AnswerWeights(yes: 0, no: 0, maybe: 1));

      for (var i = 0; i < 50; i++) {
        expect(onlyYes.pickAnswer(), 'yes');
        expect(onlyNo.pickAnswer(), 'no');
        expect(onlyMaybe.pickAnswer(), 'maybe');
      }
    });

    test('los porcentajes por defecto son 40/40/20', () {
      const weights = AnswerWeights();

      expect(weights.yes, 40);
      expect(weights.no, 40);
      expect(weights.maybe, 20);
      expect(weights.total, 100);
    });

    test('la distribucion del sorteo se acerca a 40/40/20', () {
      final helper = GetYesNoAnswer();
      final counts = {'yes': 0, 'no': 0, 'maybe': 0};

      const total = 20000;
      for (var i = 0; i < total; i++) {
        final key = helper.pickAnswer();
        counts[key] = counts[key]! + 1;
      }

      expect(counts['yes']! / total, closeTo(0.40, 0.02));
      expect(counts['no']! / total, closeTo(0.40, 0.02));
      expect(counts['maybe']! / total, closeTo(0.20, 0.02));
    });
  });

  group('consumo de la API', () {
    test('"maybe" se responde en local y no consulta la API', () async {
      final api = _FakeYesNoApi();
      final helper = GetYesNoAnswer(
        dio: _dioWith(api),
        weights: const AnswerWeights(yes: 0, no: 0, maybe: 1),
      );

      final message = await helper.getAnswer();

      expect(api.requests, isEmpty, reason: 'la API no sabe responder "maybe"');
      expect(message.text, 'Tal vez');
      expect(message.imageUrl, isNull);
    });

    test('insiste hasta que la API entregue la respuesta sorteada', () async {
      // La API devuelve siempre "no" al principio: hay que reintentar.
      final api = _FakeYesNoApi(answers: const ['no', 'no', 'no', 'yes']);
      final helper = GetYesNoAnswer(
        dio: _dioWith(api),
        weights: const AnswerWeights(yes: 1, no: 0, maybe: 0),
        maxAttempts: 5,
      );

      final message = await helper.getAnswer();

      expect(api.requests.length, 4, reason: 'tuvo que pedirla 4 veces');
      expect(message.text, 'Sí');
      expect(message.imageUrl, 'https://yesno.wtf/assets/yes/x.gif');
    });

    test('se rinde tras maxAttempts y devuelve la ultima respuesta', () async {
      // La API nunca entrega "yes" cuando se le pide.
      final api = _FakeYesNoApi(answers: const ['no']);
      final helper = GetYesNoAnswer(
        dio: _dioWith(api),
        weights: const AnswerWeights(yes: 1, no: 0, maybe: 0),
        maxAttempts: 3,
      );

      final message = await helper.getAnswer();

      expect(api.requests.length, 3);
      expect(message.text, 'No', reason: 'no hay una cuarta oportunidad');
    });

    test('de punta a punta la app entrega 40/40/20', () async {
      final api = _FakeYesNoApi(answers: const ['no', 'yes']);
      final helper = GetYesNoAnswer(dio: _dioWith(api));

      final counts = {'Sí': 0, 'No': 0, 'Tal vez': 0};
      const total = 2000;

      for (var i = 0; i < total; i++) {
        final message = await helper.getAnswer();
        counts[message.text] = counts[message.text]! + 1;
      }

      expect(counts['Sí']! / total, closeTo(0.40, 0.03));
      expect(counts['No']! / total, closeTo(0.40, 0.03));
      expect(counts['Tal vez']! / total, closeTo(0.20, 0.03));
    });
  });

  group('errores', () {
    test('convierte un error de red en YesNoException', () {
      final dio = Dio()..httpClientAdapter = _ThrowingAdapter();
      final helper = GetYesNoAnswer(dio: dio);

      expect(
        helper.getAnswer(),
        throwsA(isA<YesNoException>()),
      );
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'sin red',
    );
  }
}
