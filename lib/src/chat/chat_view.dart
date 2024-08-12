import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tap_books/main.dart';
import 'package:tap_books/src/widgets/chat_input_box.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

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
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(),
            body: Column(
            children: [
              SignOutButton(auth: FirebaseAuth.instanceFor(app: app)),
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
                      : const Center(child: Text('Search something!'))),
              if (loading) const CircularProgressIndicator(),
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
                          role: 'model', parts: [Parts(text: value?.output)]));
                      loading = false;
                    });
                  }
                },
              ),
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
          content.role == 'model' ? Colors.blue.shade800 : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.role ?? 'role'),
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
