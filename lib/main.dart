import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/core/providers/app_provider.dart';
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
runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MyApp(settingsController: settingsController),
    ),
  );
}



