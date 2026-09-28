import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    GetYesNoAnswer? getYesNoAnswer,
    DateTime Function()? now,
  })  : getYesNoAnswer = getYesNoAnswer ?? GetYesNoAnswer(),
        _now = now ?? DateTime.now;

  final chatScrollController = ScrollController();
  final GetYesNoAnswer getYesNoAnswer;

  /// Reloj inyectable para poder fijar la hora de envio en los tests.
  final DateTime Function() _now;

  /// Las respuestas se encadenan para que nunca se intercalen entre si.
  Future<void> _replyQueue = Future<void>.value();

  final List<Message> messageList = [
    Message(text: 'Hola Bb farias!', fromWho: FromWho.me, sentAt: DateTime.now()),
    Message(text: 'Vamos al gym?', fromWho: FromWho.me, sentAt: DateTime.now()),
  ];

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    messageList.add(Message(
      text: trimmed,
      fromWho: FromWho.me,
      sentAt: _now(),
    ));
    notifyListeners();
    await moveScrollToBottom();

    if (trimmed.endsWith('?')) {
      unawaited(herReply());
    }
  }

  Future<void> herReply() {
    _replyQueue = _replyQueue.then((_) => _fetchAndAppendReply());
    return _replyQueue;
  }

  Future<void> _fetchAndAppendReply() async {
    Message reply;
    try {
      reply = await getYesNoAnswer.getAnswer();
    } on YesNoException catch (e) {
      reply = Message(text: e.message, fromWho: FromWho.hers, sentAt: _now());
    }

    /// La hora la estampa el provider para que todos los mensajes del chat,
    /// propios y de la API, vengan del mismo reloj.
    messageList.add(reply.copyWith(sentAt: _now()));
    notifyListeners();
    await moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!chatScrollController.hasClients) return;

    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  @override
  void dispose() {
    chatScrollController.dispose();
    super.dispose();
  }
}
