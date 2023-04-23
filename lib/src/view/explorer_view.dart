import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controller/explorer_controller.dart';
import '../repository/file_repository.dart';

class ExplorerView extends AnimatedWidget {
  final ExplorerController explorerController;
  final Function(FileEntry pack)? onPackTapped;

  const ExplorerView({
    required this.explorerController,
    Key? key,
    this.onPackTapped,
  }) : super(key: key, listenable: explorerController);

  @override
  Widget build(BuildContext context) {
    if (explorerController.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (explorerController.failureReason != null) {
      var localization = AppLocalizations.of(context)!;
      var reason = {
            FailureReason.loginFailed: localization.failureReasonLoginFailed,
          }[explorerController.failureReason] ??
          '';

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(localization.listingFailed(reason)),
          TextButton(
            onPressed: () =>
                explorerController.list(explorerController.currentPath),
            child: Text(localization.retry),
          ),
        ],
      );
    }

    if (explorerController.files.isEmpty) {
      return Center(
        child: Text('nothing'),
      );
    }

    return Center(
      child: ListView.builder(
        shrinkWrap: true,
        restorationId: 'explorerView',
        itemCount: explorerController.files.length,
        itemBuilder: (BuildContext context, int index) {
          final file = explorerController.files[index];
          return _FileView(
            entry: file,
          );
        },
      ),
    );
  }
}

class _FileView extends StatelessWidget {
  final FileEntry entry;

  const _FileView({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.name),
    );
  }
}
