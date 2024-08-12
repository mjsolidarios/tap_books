import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tap_books/main.dart';
import 'package:tap_books/src/widgets/chat_input_box.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.book});

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
              body: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      (widget.book?.data() as Map)["title"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        (widget.book?.data() as Map)["author"],
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(20), child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 5, 0), child: Icon(Icons.message)),
                     Flexible(child:  Text(
                  "Hi ${snapshot.data?.displayName}! What are some key concepts from '${(widget.book?.data() as Map)["title"]}' you want to discuss?"),)
                    ],
                  )),
                  Expanded(
                      child: chats.isNotEmpty
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: SingleChildScrollView(
                                reverse: true,
                                child: ListView.builder(
                                  itemBuilder: chatItem,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: chats.length,
                                  reverse: false,
                                ),
                              ),
                            )
                          : const Center(child: Text(""))),
                  if (loading) Container(width: 200, child: Text("..."),),
                  ChatInputBox(
                    controller: controller,
                    onSend: () {
                      if (controller.text.isNotEmpty) {
                        final searchedText = controller.text;
                        chats.add(Content(
                            role: 'user', parts: [Parts(text: searchedText)]));
                        controller.clear();
                        loading = true;

                        gemini.chat(chats).then((value) {
                          chats.add(Content(
                              role: 'model',
                              parts: [Parts(text: value?.output)]));
                          loading = false;
                        });
                      }
                    },
                  ),
                ],
              ));
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
