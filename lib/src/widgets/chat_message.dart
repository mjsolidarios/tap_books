import 'package:flutter/material.dart';
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
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.isUser
            ? [
                Expanded(
                  child:Text(widget.messageContent ?? "", textAlign: TextAlign.right,),
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
    );
  }
}
