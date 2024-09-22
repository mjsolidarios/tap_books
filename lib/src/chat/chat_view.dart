import 'package:card_loading/card_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:tap_books/src/widgets/chat_card.dart';
import 'package:tap_books/src/widgets/chat_message.dart';
import 'package:tap_books/src/widgets/dots_progress.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class ChatView extends StatefulWidget {
  const ChatView({super.key, this.book});

  final QueryDocumentSnapshot? book;

  static const routeName = "/chat";

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<Widget> promptList = [];
  bool isGeminiLoading = false;  

  @override
  Widget build(BuildContext context) {
    final gemini = Gemini.instance;
   
    List<Content> chats = [];
    return Scaffold(
      appBar: AppBar(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       promptList.add("Test");
      //     });
      //   },
      //   child: const Icon(
      //     Icons.add,
      //     size: 20,
      //   ),
      // ),
      body: ListView(
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
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadiusDirectional.only(
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
                SizedBox(
                  height: 180,
                  child: widget.book != null
                      ? ListView(
                          scrollDirection: Axis.horizontal,
                          children: (widget.book!.data()
                                      as Map)["book_prompts"] !=
                                  null
                              ? (((widget.book?.data() as Map)["book_prompts"])
                                      as List)
                                  .map((e) => FutureBuilder(
                                      future: (e as DocumentReference).get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              "An error occurred.");
                                        }

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container();
                                        }
                                        return ChatCard(
                                          title: (snapshot.data?.data()
                                              as Map)["title"],
                                          description: (snapshot.data?.data()
                                              as Map)["desc"],
                                          onTap: () {
                                            final searchedText = (snapshot.data
                                                ?.data() as Map)["prompt"];
                                                print("========================================");
                                                print(searchedText);

                                            chats.add(Content(
                                                role: 'user',
                                                parts: [
                                                  Parts(text: searchedText)
                                                ]));
                                            
                                            setState(() {
                                              isGeminiLoading = true;
                                              promptList.add(ChatMessage(
                                                  isUser: true,
                                                  messageContent:
                                                      (snapshot.data?.data()
                                                          as Map)["desc"]));
                                            });

                                            gemini.chat(chats).then((value) {
                                              chats.add(Content(
                                                  role: 'model',
                                                  parts: [
                                                    Parts(text: value?.output)
                                                  ]));
                                              

                                              setState(() {
                                              isGeminiLoading = false;
                                              promptList.add(ChatMessage(
                                                  isUser: false,
                                                  messageContent:
                                                      value?.output));
                                              });
                                            });
                                          },
                                        );
                                      }))
                                  .toList()
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
                ),
                ...promptList.map((e) => e),     
                isGeminiLoading?const DotsProgress():Container(),          
                const SizedBox(
                  height: 500,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
