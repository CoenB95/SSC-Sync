import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:logger/logger.dart';
import 'package:ssc_sync/src/controller/settings_controller.dart';
import 'package:ssc_sync/src/repository/file_repository.dart';
import 'package:ssc_sync/src/repository/settings_repository.dart';

import 'src/app.dart';
import 'src/controller/file_controller.dart';

void main() {
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
    connection: FTPConnect('ftp.kempengemeenten.nl'),
    logger: logger,
  );

  final fileController = FileController(
    sourceRepository: sourceRepository,
    targetRepository: targetRepository,
  );

  final settingsController = SettingsController(
    repository: settingsRepository,
  );

  runApp(SscSyncApp(
    fileController: fileController,
    settingsController: settingsController,
  ));
}
