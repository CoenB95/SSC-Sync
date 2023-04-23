import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controller/explorer_controller.dart';
import '../controller/file_controller.dart';
import '../controller/settings_controller.dart';
import '../view/files_view.dart';

class UploadLayout extends AnimatedWidget {
  static const routeName = '/upload';

  final FileController fileController;
  final ExplorerController explorerController;
  final SettingsController settingsController;

  const UploadLayout({
    required this.fileController,
    required this.explorerController,
    required this.settingsController,
    GlobalKey<ScaffoldState>? key,
  }) : super(key: key, listenable: fileController);

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(localization.appTitle),
      ),
      body: FilesView(
        key: key,
        fileController: fileController,
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(localization.retry),
        icon: const Icon(Icons.cloud_upload),
        onPressed: fileController.loading ? null : () => _upload(context),
      ),
    );
  }

  void _upload(BuildContext context) async {
    var targetDirectoryPath = settingsController.remoteDirectoryPath;
    var success = await fileController.uploadFiles(
        targetDirectoryPath: targetDirectoryPath);

    if (!success && context.mounted) {
      var localization = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(localization.listingFailed(
            fileController.failureReason?.localized(context) ??
                'Unknown reason')),
      ));
    }
  }

  // void _listFtp() async {
  //   var repo = fileController.targetRepository;
  //   explorerController.repository = repo;
  //   explorerController.list('/');
  // }
}
