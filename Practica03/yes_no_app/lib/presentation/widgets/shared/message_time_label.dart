import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/format_time_of_day.dart';

/// Identifica la burbuja para poder medirla en los tests.
const bubbleKey = Key('messageBubble');

/// Margen interior de las burbujas. La hora se apoya en la esquina inferior
/// derecha respetando este margen, igual que en WhatsApp.
const bubblePadding = EdgeInsets.fromLTRB(20, 10, 12, 8);

/// La hora de envio que va en la esquina inferior derecha de la burbuja.
/// Se comparte entre los dos tipos de mensaje para que el estilo sea
/// siempre el mismo.
class MessageTimeLabel extends StatelessWidget {
  const MessageTimeLabel({super.key, required this.sentAt});

  final DateTime sentAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTimeOfDay(sentAt),
      style: TextStyle(
        fontSize: 11,
        height: 1,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
