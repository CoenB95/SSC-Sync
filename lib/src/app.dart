import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'controller/file_controller.dart';
import 'controller/settings_controller.dart';
import 'layout/main_layout.dart';

class SscSyncApp extends StatelessWidget {
  final FileController fileController;
  final SettingsController settingsController;

  SscSyncApp({
    required this.fileController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSC Sync',
      theme: ThemeData(
        primaryColor: Color(0xFFC2CE24),
        primaryColorDark: Color(0xFFA9B50B),
        disabledColor: Colors.grey,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // home: MyHomePage(title: 'SSC Sync'),
      home: MyHomePage(
        fileController: fileController,
        settingsController: settingsController,
      ),
    );
  }
}
