import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ssc_sync/src/layout/upload_layout.dart';

import 'controller/explorer_controller.dart';
import 'controller/file_controller.dart';
import 'controller/settings_controller.dart';
import 'layout/main_layout.dart';
import 'layout/settings_layout.dart';

class SscSyncApp extends StatelessWidget {
  final FileController fileController;
  final SettingsController settingsController;
  final ExplorerController explorerController;

  const SscSyncApp({
    required this.fileController,
    required this.settingsController,
    required this.explorerController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSC Sync',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC2CE24),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        MyHomePage.routeName: (context) => MyHomePage(
              fileController: fileController,
              settingsController: settingsController,
            ),
        SettingsLayout.routeName: (context) => const SettingsLayout(),
        UploadLayout.routeName: (context) => UploadLayout(
              fileController: fileController,
              explorerController: explorerController,
              settingsController: settingsController,
            ),
      },
    );
  }
}
