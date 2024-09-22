import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:tap_books/src/settings/settings_controller.dart';
import 'package:tap_books/src/widgets/chat_card.dart';
import 'package:tap_books/src/widgets/chat_message.dart';
import 'package:tap_books/src/widgets/dots_progress.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class ChatView extends StatefulWidget {
  const ChatView({super.key, this.book, required this.controller});

  final QueryDocumentSnapshot? book;

  final SettingsController controller;

  static const routeName = "/chat";

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<Widget> promptList = [];
  bool isGeminiLoading = false;
  final ScrollController _scrollController = new ScrollController();
  
  Color getThemeColor() {
    switch (widget.controller.themeMode) {
      case ThemeMode.light:
        return Colors.white;
      default:
      return Colors.black;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final gemini = Gemini.instance;
    List<Content> chats = [];
    Widget ConceptList = SizedBox(
      height: 180,
      child: widget.book != null
          ? ListView(
              scrollDirection: Axis.horizontal,
              children: (widget.book!.data() as Map)["book_prompts"] != null
                  ? [
                    const SizedBox(width: 20),
                    ...(((widget.book?.data() as Map)["book_prompts"]) as List)
                      .map((e) => FutureBuilder(
                          future: (e as DocumentReference).get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text("An error occurred.");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            }
                            return ChatCard(
                              title: (snapshot.data?.data() as Map)["title"],
                              description:
                                  (snapshot.data?.data() as Map)["desc"],
                              onTap: () {
                                final searchedText =
                                    (snapshot.data?.data() as Map)["prompt"];

                                chats.add(Content(
                                    role: 'user',
                                    parts: [Parts(text: searchedText)]));

                                setState(() {
                                  isGeminiLoading = true;
                                  promptList.add(ChatMessage(
                                      isUser: true,
                                      messageContent: (snapshot.data?.data()
                                          as Map)["desc"]));
                                });

                                gemini.chat(chats).then((value) {
                                  chats.add(Content(
                                      role: 'model',
                                      parts: [Parts(text: value?.output)]));

                                  setState(() {
                                    isGeminiLoading = false;
                                    promptList.add(ChatMessage(
                                        isUser: false,
                                        messageContent: value?.output));
                                  });   

                                  //print((promptList.last as ChatMessage).messageContent.toString());                              

                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    curve: Curves.easeOut,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                });
                              },
                              isActive: promptList.isNotEmpty && promptList.last.runtimeType == ChatMessage?(promptList.last as ChatMessage).messageContent == (snapshot.data?.data() as Map)["desc"]:false,
                            );
                          }))
                      .toList()
                  ]
                  : [
                      const Padding(
                          padding: EdgeInsets.all(20),
                          child: Expanded(
                              child: Text(
                                  textAlign: TextAlign.center,
                                  "This book doesn't have a content yet :(")))
                    ],
            )
          : const DotsProgress(),
    );
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: const Icon(
          Icons.arrow_drop_up,
          size: 20,
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              (widget.book?.data() as Map)["title"],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration:  BoxDecoration(
              color: getThemeColor(),
              borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(30), topEnd: Radius.circular(30)),
            ),
            child: Column(
              children: [
                (widget.book!.data() as Map)["book_prompts"] != null
                    ? StreamBuilder(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("An error occurred.");
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: SizedBox(
                                  height: 180,
                                ),
                              ),
                            );
                          }
                          return ChatMessage(
                              isUser: false,
                              messageContent:
                                  "Hi ${snapshot.data?.displayName}! What are some key concepts from '${(widget.book?.data() as Map)["title"]}' you want to discuss?");
                        },
                      )
                    : Container(),
                ConceptList,
                ...promptList.map((e) => e),
                isGeminiLoading ? const DotsProgress() : Container(),
                promptList.length > 1
                    ? Container()
                    : const SizedBox(height: 500),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      promptList.add(ConceptList);
                    });

                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: const Text("Browse for more concepts"),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
