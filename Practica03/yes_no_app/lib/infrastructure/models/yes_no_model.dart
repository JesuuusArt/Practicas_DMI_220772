import 'package:yes_no_app/domain/entities/message.dart';

class YesNoModel {
  YesNoModel({
    required this.answer,
    required this.forced,
    required this.image,
  });

  final String answer;
  final bool forced;
  final String image;

  /// Lanza [FormatException] si el mapa no cumple el contrato de la API.
  factory YesNoModel.fromJsonMap(Map<String, dynamic> json) {
    final answer = json['answer'];
    final forced = json['forced'];
    final image = json['image'];

    if (answer is! String || answer.trim().isEmpty) {
      throw const FormatException('El campo "answer" debe ser un texto no vacío.');
    }

    return YesNoModel(
      answer: answer.trim().toLowerCase(),
      forced: forced is bool ? forced : false,
      image: image is String ? image.trim() : '',
    );
  }

  Map<String, dynamic> toJson() => {
        "answer": answer,
        "forced": forced,
        "image": image,
      };

  /// Traduce la respuesta de la API al texto que ve el usuario.
  String get displayText => switch (answer) {
        'yes' => 'Sí',
        'no' => 'No',
        _ => 'Tal vez',
      };

  /// [sentAt] permite fijar la hora en los tests; por defecto es el
  /// momento en que se crea el mensaje.
  Message toMessageEntity({DateTime? sentAt}) => Message(
        text: displayText,
        fromWho: FromWho.hers,
        imageUrl: image.isEmpty ? null : image,
        sentAt: sentAt ?? DateTime.now(),
      );
}
