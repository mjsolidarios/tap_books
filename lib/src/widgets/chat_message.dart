import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage(
      {super.key, this.messageContent = "", required this.isUser});

  final String? messageContent;
  final bool isUser;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    const Widget IconBox = Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0), child: Icon(Icons.message));
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: widget.isUser
              ? const BoxDecoration(
                  color: Color.fromARGB(221, 20, 20, 20),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)))
              : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.isUser
                  ? [
                      Expanded(
                        child: Text(
                          widget.messageContent ?? "",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Transform.flip(
                        flipX: true,
                        child: IconBox,
                      ),
                    ]
                  : [
                      IconBox,
                      Expanded(
                        child: MarkdownBody(data: widget.messageContent ?? ""),
                      ),
                    ],
            ),
          ),
        ));
  }
}
