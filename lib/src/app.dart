import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tap_books/src/auth/auth_gate.dart';
import 'package:tap_books/src/auth/auth_splash.dart';
import 'package:tap_books/src/chat/chat_view.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
    required this.app,
    required this.auth
  });

  initState() {
    // ignore: avoid_print
    print("initState Called");
  }


  final FirebaseApp app;
  final FirebaseAuth auth;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',          
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            fontFamily: "Poppins",
            scaffoldBackgroundColor: settingsController.themeMode == ThemeMode.dark? const Color(0x00191b23): const Color.fromARGB(255, 244, 244, 244),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)
              )
            ),
            // textTheme: const TextTheme().apply(
            //   bodyColor: Colors.white,
            //   displayColor: Colors.white
            // )
            ),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const AuthSplash(),
          onGenerateRoute: (RouteSettings routeSettings){
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) { 
                 switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case ChatView.routeName:
                    return ChatView(book: null, controller: settingsController);
                  case AuthGate.routeName:
                    return AuthGate(controller: settingsController);
                  case AuthSplash.routeName:
                  default:
                    return const AuthSplash();
                }

              }
              
            );
          }
        );
      },
    );
  }
}
