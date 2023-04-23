import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pref/pref.dart';
import 'package:ssc_sync/src/controller/settings_controller.dart';
import 'package:ssc_sync/src/repository/file_repository.dart';
import 'package:ssc_sync/src/repository/settings_repository.dart';

import 'src/app.dart';
import 'src/controller/explorer_controller.dart';
import 'src/controller/file_controller.dart';

void main() async {
  final logger = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(printTime: true),
    level: Level.verbose,
  );

  final settingsRepository = PreferencesSettingsRepository();

  final sourceRepository = LocalFileRepository(
    logger: logger,
  );

  final targetRepository = FtpFileRepository(
    logger: logger,
  );

  final fileController = FileController(
    sourceRepository: sourceRepository,
    targetRepository: targetRepository,
  );

  final settingsController = SettingsController(
    repository: settingsRepository,
  );

  final explorerController = ExplorerController(
    settingsController: settingsController,
  );

  var preferences = await PrefServiceShared.init();
  preferences.addListener(() => settingsController.load());
  await settingsController.load();

  runApp(PrefService(
    service: preferences,
    child: SscSyncApp(
      fileController: fileController,
      settingsController: settingsController,
      explorerController: explorerController,
    ),
  ));
}
