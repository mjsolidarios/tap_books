import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tap_books/main.dart';
import 'package:tap_books/src/chat/chat_view.dart';
import 'package:tap_books/src/settings/settings_controller.dart';
import 'package:tap_books/src/settings/settings_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.controller});

  final SettingsController controller;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchBooks() {
    CollectionReference books = FirebaseFirestore.instance.collection('books');

    return books.get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        print('${doc.id} => ${doc.data()}');
      }
    }).catchError((error){print("Failed to fetch books: $error");});
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    CollectionReference books = FirebaseFirestore.instance.collection('books');

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> userSnapshot) {
          return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu)),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.restorablePushNamed(
                            context, SettingsView.routeName);
                      },
                      icon: const Icon(Icons.settings))
                ],
              ),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 200,
                          child: SvgPicture.asset(
                            widget.controller.themeMode == ThemeMode.system
                                ? 'assets/images/app_brand_light.svg'
                                : 'assets/images/app_brand_dark.svg',
                            semanticsLabel: 'Tapbooks Logo',
                            height: 50,
                            width: 50,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        const Text("Early Version")
                      ],
                    )),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Signout'),
                      onTap: () {
                        auth.signOut();
                      },
                    ),
                  ],
                ),
              ),
              body: ListView(
                children: [
                  SizedBox(
                    height: 1000,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: books.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text("An error occured.");
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [CircularProgressIndicator()],
                              ),
                            );
                          }

                          return ListView(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                          "Hi ${userSnapshot.data?.displayName},"),
                                      const Text(
                                        "Quick sip of knowledge?\nTap to dive in!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ],
                                  )),
                              Container(height: 20),
                              const Row(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        "Recommend For You ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Spacer(),
                                  // TextButton(
                                  //     onPressed: () {},
                                  //     child: const Text(
                                  //       "See all",
                                  //       style: TextStyle(
                                  //           fontSize: 13,
                                  //           fontWeight: FontWeight.w400),
                                  //     ))
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 275,
                                child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      const SizedBox(width: 20),
                                      ...snapshot.data!.docs
                                          .map((e) => SizedBox(
                                              width: 170,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatView(
                                                                  book: e, controller: widget.controller,)));
                                                },
                                                child: Card(
                                                    semanticContainer: true,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.network((e.data()
                                                                as Map)["image"]
                                                            .toString()),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  (e.data() as Map)[
                                                                          "title"]
                                                                      .toString(),
                                                                  maxLines: 2,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis)),
                                                              Row(
                                                                children: [
                                                                  Opacity(
                                                                      opacity:
                                                                          0.5,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            100,
                                                                        child:
                                                                            Text(
                                                                          maxLines:
                                                                              1,
                                                                          (e.data() as Map)["author"]
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(fontSize: 12),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      )),
                                                                  const Spacer(),
                                                                  const Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 20,
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              )))
                                          .toList(),
                                    ]),
                              ),
                              Container(height: 20),
                              const Row(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        "Continue Tapping ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Spacer(),
                                  // TextButton(
                                  //     onPressed: () {},
                                  //     child: const Text(
                                  //       "See all",
                                  //       style: TextStyle(
                                  //           fontSize: 13,
                                  //           fontWeight: FontWeight.w400),
                                  //     ))
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 275,
                                child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      const SizedBox(width: 20),
                                      ...snapshot.data!.docs.reversed
                                          .map((e) => SizedBox(
                                              width: 170,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatView(
                                                                  book: e, controller: widget.controller,)));
                                                },
                                                child: Card(
                                                    semanticContainer: true,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.network((e.data()
                                                                as Map)["image"]
                                                            .toString()),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  (e.data() as Map)[
                                                                          "title"]
                                                                      .toString(),
                                                                  maxLines: 2,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis)),
                                                              Row(
                                                                children: [
                                                                  Opacity(
                                                                      opacity:
                                                                          0.5,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          maxLines:
                                                                              1,
                                                                          (e.data() as Map)["author"]
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(fontSize: 12),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      )),
                                                                  const Spacer(),
                                                                  const Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 20,
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              )))
                                          .toList()
                                    ]),
                              )
                            ],
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ));
        });
  }
}

class ChatArgs {
  final String firestoreReference;
  const ChatArgs(this.firestoreReference);
}
