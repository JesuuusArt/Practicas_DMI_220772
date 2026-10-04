import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';

/// Reproduce el comportamiento real de https://yesno.wtf/api:
/// honra el parametro `?force=` (yes | no | maybe) y devuelve esa respuesta
/// con su imagen correspondiente.
class _FakeYesNoApi implements HttpClientAdapter {
  final List<Uri> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    final answer = options.uri.queryParameters['force'] ?? 'no';

    return ResponseBody.fromString(
      jsonEncode({
        'answer': answer,
        'forced': true,
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

  group('integracion con la API (parametro ?force=)', () {
    test('"maybe" SI se pide a la API y trae imagen', () async {
      final api = _FakeYesNoApi();
      final helper = GetYesNoAnswer(
        dio: _dioWith(api),
        weights: const AnswerWeights(yes: 0, no: 0, maybe: 1),
      );

      final message = await helper.getAnswer();

      expect(api.requests.length, 1, reason: 'maybe tambien consulta la API');
      expect(api.requests.single.queryParameters['force'], 'maybe');
      expect(message.text, 'Tal vez');
      expect(message.imageUrl, 'https://yesno.wtf/assets/maybe/x.gif');
    });

    test('fuerza "yes" y devuelve su imagen', () async {
      final api = _FakeYesNoApi();
      final helper = GetYesNoAnswer(
        dio: _dioWith(api),
        weights: const AnswerWeights(yes: 1, no: 0, maybe: 0),
      );

      final message = await helper.getAnswer();

      expect(api.requests.single.queryParameters['force'], 'yes');
      expect(message.text, 'Sí');
      expect(message.imageUrl, 'https://yesno.wtf/assets/yes/x.gif');
    });

    test('fuerza "no" y devuelve su imagen', () async {
      final api = _FakeYesNoApi();
      final helper = GetYesNoAnswer(
        dio: _dioWith(api),
        weights: const AnswerWeights(yes: 0, no: 1, maybe: 0),
      );

      final message = await helper.getAnswer();

      expect(api.requests.single.queryParameters['force'], 'no');
      expect(message.text, 'No');
      expect(message.imageUrl, 'https://yesno.wtf/assets/no/x.gif');
    });

    test('usa una sola llamada por respuesta (sin reintentos)', () async {
      final api = _FakeYesNoApi();
      final helper = GetYesNoAnswer(dio: _dioWith(api));

      await helper.getAnswer();

      expect(api.requests.length, 1);
    });

    test('de punta a punta la app entrega 40/40/20', () async {
      final api = _FakeYesNoApi();
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
      expect(api.requests.length, total, reason: 'nadie se queda sin gif');
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
