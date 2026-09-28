import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

/// El controller y el focus viven en el State y no en [build]: antes se
/// creaban en cada rebuild (cada mensaje nuevo) y eso borraba lo que el
/// usuario estaba escribiendo y le quitaba el foco a mitad de frase.
class _MessageFieldBoxState extends State<MessageFieldBox> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final textValue = _textController.value.text;
    _textController.clear();
    widget.onValue(textValue);
  }

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = UnderlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(40));

    final inputDecoration = InputDecoration(
      hintText: 'Escribe y termina con "?" para que te responda',
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      filled: true,
      suffixIcon: IconButton(
        icon: const Icon(Icons.send_outlined),
        onPressed: _send,
      ),
    );

    return TextFormField(
      onTapOutside: (event) => _focusNode.unfocus(),
      focusNode: _focusNode,
      controller: _textController,
      decoration: inputDecoration,
      onFieldSubmitted: (value) {
        _focusNode.requestFocus();
        _send();
      },
    );
  }
}
