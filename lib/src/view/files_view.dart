import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controller/file_controller.dart';
import '../repository/file_repository.dart';

class FilesView extends AnimatedWidget {
  final FileController fileController;
  // final Function(FailureReason reason)? onError;

  const FilesView({
    required this.fileController,
    Key? key,
    // this.onError,
  }) : super(key: key, listenable: fileController);

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context)!;

    if (fileController.trackedFiles.isEmpty) {
      if (fileController.loading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (fileController.failureReason != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localization.listingFailed(
                fileController.failureReason!.localized(context))),
          ],
        );
      }
    }

    return Column(
      children: [
        if (fileController.loading)
          LinearProgressIndicator(
            value: fileController.progress,
          ),
        if (fileController.trackedFiles.isEmpty)
          const Center(
            child: Text('nothing'),
          ),
        if (fileController.trackedFiles.isNotEmpty)
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              restorationId: 'filesView',
              itemCount: fileController.trackedFiles.length,
              itemBuilder: (BuildContext context, int index) {
                final file = fileController.trackedFiles[index];
                return _FileView(
                  entry: file,
                  progress: fileController.state(file)!,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FileView extends StatelessWidget {
  final FileEntry entry;
  final FileProgress progress;

  _FileView({
    required this.entry,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.name),
      leading: progress.isBusy
          ? const CircularProgressIndicator()
          : const Icon(Icons.image),
      subtitle: Text(progress.isError
          ? 'Error: ${progress.errorMessage}'
          : progress.isDone
              ? 'Klaar'
              : progress.isBusy
                  ? 'Uploading (${(progress.progress! * 100).toStringAsFixed(1)}%)'
                  : 'Staged'),
    );
  }
}
