import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controller/file_controller.dart';
import '../controller/settings_controller.dart';
import 'settings_layout.dart';
import 'upload_layout.dart';

class MyHomePage extends StatelessWidget {
  static const routeName = '/';

  final FileController fileController;
  final SettingsController settingsController;

  const MyHomePage({
    required this.fileController,
    required this.settingsController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.appTitle),
        actions: [
          IconButton(
            onPressed: () => _settings(context),
            icon: const Icon(Icons.settings),
            tooltip: localization.settings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 400,
            child: FittedBox(
              child: FloatingActionButton.extended(
                label: Text(localization.start),
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _upload(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _settings(BuildContext context) async {
    Navigator.restorablePushNamed(context, SettingsLayout.routeName);
  }

  void _upload(BuildContext context) async {
    var sourceDirectoryPath = settingsController.localDirectoryPath;
    fileController.stageFiles(sourceDirectoryPath: sourceDirectoryPath);
    Navigator.restorablePushNamed(context, UploadLayout.routeName);
  }
}
