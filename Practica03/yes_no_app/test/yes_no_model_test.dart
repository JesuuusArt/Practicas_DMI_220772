import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

void main() {
  group('YesNoModel.fromJsonMap', () {
    test('mapea una respuesta valida de la API', () {
      final model = YesNoModel.fromJsonMap({
        'answer': 'yes',
        'forced': true,
        'image': 'https://yesno.wtf/assets/yes/1.gif',
      });

      expect(model.answer, 'yes');
      expect(model.forced, isTrue);
      expect(model.image, 'https://yesno.wtf/assets/yes/1.gif');
    });

    test('normaliza el answer a minusculas', () {
      final model = YesNoModel.fromJsonMap({'answer': ' YES ', 'image': ''});

      expect(model.answer, 'yes');
    });

    test('lanza FormatException si answer no es un texto', () {
      expect(
        () => YesNoModel.fromJsonMap({'answer': 42, 'image': ''}),
        throwsFormatException,
      );
    });

    test('lanza FormatException si answer viene vacio o ausente', () {
      expect(
        () => YesNoModel.fromJsonMap({'answer': '   '}),
        throwsFormatException,
      );
      expect(
        () => YesNoModel.fromJsonMap({'image': 'https://x.com/a.gif'}),
        throwsFormatException,
      );
    });

    test('usa false si forced no es un booleano', () {
      final model = YesNoModel.fromJsonMap({'answer': 'no', 'forced': 'si'});

      expect(model.forced, isFalse);
    });
  });

  group('YesNoModel.toMessageEntity', () {
    test('traduce yes a "Sí" con acento y usa FromWho.hers', () {
      final message = YesNoModel.fromJsonMap({
        'answer': 'yes',
        'image': 'https://yesno.wtf/assets/yes/1.gif',
      }).toMessageEntity();

      expect(message.text, 'Sí');
      expect(message.fromWho, FromWho.hers);
      expect(message.imageUrl, 'https://yesno.wtf/assets/yes/1.gif');
    });

    test('traduce no a "No"', () {
      final message =
          YesNoModel.fromJsonMap({'answer': 'no', 'image': ''}).toMessageEntity();

      expect(message.text, 'No');
    });

    test('traduce maybe a "Tal vez"', () {
      final message = YesNoModel.fromJsonMap({
        'answer': 'maybe',
        'image': 'https://yesno.wtf/assets/maybe/0.gif',
      }).toMessageEntity();

      expect(message.text, 'Tal vez');
      expect(message.imageUrl, 'https://yesno.wtf/assets/maybe/0.gif');
    });

    test('cualquier respuesta desconocida cae en "Tal vez"', () {
      final message =
          YesNoModel.fromJsonMap({'answer': 'quiza', 'image': ''}).toMessageEntity();

      expect(message.text, 'Tal vez');
    });

    test('devuelve imageUrl null cuando la API no manda imagen', () {
      final message = YesNoModel.fromJsonMap({
        'answer': 'no',
        'image': null,
      }).toMessageEntity();

      expect(message.imageUrl, isNull);
    });
  });
}
