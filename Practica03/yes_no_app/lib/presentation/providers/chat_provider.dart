import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({GetYesNoAnswer? getYesNoAnswer})
      : getYesNoAnswer = getYesNoAnswer ?? GetYesNoAnswer();

  final chatScrollController = ScrollController();
  final GetYesNoAnswer getYesNoAnswer;

  /// Las respuestas se encadenan para que nunca se intercalen entre si.
  Future<void> _replyQueue = Future<void>.value();

  final List<Message> messageList = [
    Message(text: 'Hola Bb farias!', fromWho: FromWho.me),
    Message(text: 'Vamos al gym?', fromWho: FromWho.me),
  ];

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    messageList.add(Message(text: trimmed, fromWho: FromWho.me));
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
      reply = Message(text: e.message, fromWho: FromWho.hers);
    }

    messageList.add(reply);
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
