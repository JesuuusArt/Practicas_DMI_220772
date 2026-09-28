enum FromWho { me, hers }

class Message {
  final String text;
  final String? imageUrl;
  final FromWho fromWho;

  /// Momento en que se creo el mensaje, en hora local del dispositivo.
  final DateTime sentAt;

  const Message({
    required this.text, 
    this.imageUrl, 
    required this.fromWho,
    required this.sentAt
  });

  Message copyWith({DateTime? sentAt}) => Message(
        text: text,
        imageUrl: imageUrl,
        fromWho: fromWho,
        sentAt: sentAt ?? this.sentAt,
      );
}
