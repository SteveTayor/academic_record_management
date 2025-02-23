import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/service/firebase_services.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  await settingsController.loadSettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final authService = AuthService();
  await authService.setAuthPersistence();
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final settingsService = SettingsService();
//   final settingsController = SettingsController(settingsService);

//   try {
//     await settingsController.loadSettings();
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//     runApp(MyApp(settingsController: settingsController));
//   } catch (e) {
//     print('Error initializing app: $e');
//   }
  runApp(MyApp(settingsController: settingsController));
}



