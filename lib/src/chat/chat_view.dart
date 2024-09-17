import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tap_books/src/widgets/chat_input_box.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, this.book});

  final QueryDocumentSnapshot? book;

  static const routeName = "/chat";

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);
  final List<Content> chats = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(),
            body: Column(
              children: [
                Text(snapshot.data.toString()),
                Text("======================================="),
                Text(widget.book != null?"with data":"without data")
              ],
            ),
          );
        });
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];

    return Card(
      elevation: 0,
      color:
          content.role == 'model' ? Colors.black45 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20,0,20,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            Markdown(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                data:
                    content.parts?.lastOrNull?.text ?? 'cannot generate data!'),
          ],
        ),
      ),
    );
  }
}
