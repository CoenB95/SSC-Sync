import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ssc_sync/src/controller/settings_controller.dart';

import '../controller/file_controller.dart';
import 'progress_view.dart';

// class FileUploadStatusWidget extends StatefulWidget {
//   final FileController fileController;
//   final String localDirectoryPath;
//   final String remoteDirectoryPath;
//   final bool removeLocalFiles;
//   final bool enabled;

//   FileUploadStatusWidget(this.fileController, this.localDirectoryPath, this.remoteDirectoryPath,
//       {this.removeLocalFiles = true, this.enabled = false});

//   @override
//   State<StatefulWidget> createState() => FileUploadState();
// }

class FileUploadView extends AnimatedWidget {
  final FileController fileController;
  final SettingsController settingsController;
  // int filesUploaded = 0;
  // int totalFileCount = 0;
  // double curFileProgress = 0;
  // bool loading = false;
  // String status = '';

  // bool get _active => widget.enabled && !loading;

  FileUploadView({
    required this.fileController,
    required this.settingsController,
    Key? key,
  }) : super(
          listenable: Listenable.merge([fileController, settingsController]),
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AnimatedCircularProgressIndicator(
                  progress: _calcProgress(),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: FloatingActionButton(
                  child: Icon(Icons.cloud_upload),
                  backgroundColor: (fileController.loading
                      ? Theme.of(context).disabledColor
                      : Theme.of(context).accentColor),
                  onPressed: fileController.loading ? null : _upload,
                ),
              ),
            ),
          ],
        ),
        // Text(fileController.status ?? '<unknown>'),
      ],
    );
  }

  double _calcProgress() {
    if (fileController.trackedFiles.isEmpty) {
      return 0;
    }

    var progresses = fileController.trackedFiles
        .map((e) => fileController.state(e)?.progress ?? 0);
    var totalProgress = progresses.reduce((a, b) => a + b) / progresses.length;
    return totalProgress;
  }

  void _upload() {
    fileController.uploadFiles(
        targetDirectoryPath: settingsController.remoteDirectoryPath);
  }
}
