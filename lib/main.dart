import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());

  await dotenv.load(
      fileName:
          ".env"); // mergeWith optional, you can include Platform.environment for Mobile/Desktop app

  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!, enableDebugging: true);

  await settingsController.loadSettings();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  runApp(MyApp(settingsController: settingsController, app: app, auth: auth,));
}
