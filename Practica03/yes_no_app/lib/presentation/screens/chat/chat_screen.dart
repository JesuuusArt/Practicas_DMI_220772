import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/shared/message_field_box.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Hola soy un chat'),
        centerTitle: true,
      ),
      body: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return index % 2 == 0
                      ? const MyMessageBubble()
                      : const HerMessageBubble();
                },
              ),
            ),

            // Caja de texto de mensajes
            const MessageFieldBox(),
          ],
        ),
      ),
    );
  }
}