import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ssc_sync/src/repository/file_repository.dart';

import 'explorer_controller.dart';

class FileProgress {
  final String? errorMessage;
  final double? progress;

  final bool _done;

  FileProgress.error([this.errorMessage = ''])
      : _done = true,
        progress = null;
  FileProgress.ongoing([this.progress = 0])
      : _done = false,
        errorMessage = null;
  FileProgress.staged()
      : _done = false,
        errorMessage = null,
        progress = null;
  FileProgress.success()
      : _done = true,
        errorMessage = null,
        progress = null;

  bool get isBusy => progress != null;
  bool get isDone => _done && !isError;
  bool get isError => errorMessage != null;
}

class FileController with ChangeNotifier {
  final FileRepository sourceRepository;
  final FileRepository targetRepository;
  bool shouldDeleteFilesAfterUpload;

  FailureReason? get failureReason => _failureReason;
  bool get loading => _loading;
  double get progress =>
      _fileStates.values.fold(
          0.0, (iv, e) => iv + (e.isDone || e.isError ? 1.0 : e.progress!)) /
      _fileStates.length;

  FailureReason? _failureReason;
  bool _loading = false;

  FileController({
    required this.sourceRepository,
    required this.targetRepository,
    this.shouldDeleteFilesAfterUpload = false,
  });

  // FTPClient _client = FTPClient('ftp.kempengemeenten.nl');
  // String error;
  // String localDirectoryPath;
  // String remoteDirectoryPath;
  // bool shouldDeleteFiles;

  // bool get filesOk => localDirectoryPath != null && remoteDirectoryPath != null;

  // void _setupClient() async {
  //   _client.logOut();
  //   setState(() {
  //     error = null;
  //   });
  //   // var preferences = await SharedPreferences.getInstance();
  //   localDirectoryPath = await settingsRepository.localDirectoryPath();
  //   remoteDirectoryPath = await settingsRepository.remoteDirectoryPath();
  //   shouldDeleteFiles = await settingsRepository.shouldDeleteFiles() ?? true;
  //   var username = await settingsRepository.username();
  //   var password = await settingsRepository.password();
  //   _client.assertConnected(username, password).then((v) {
  //     setState(() {
  //       _client = _client;
  //     });
  //   }, onError: (err) {
  //     setState(() {
  //       error = err;
  //     });
  //   });
  // }

  final Map<FileEntry, FileProgress> _fileStates = {};

  FileProgress? state(FileEntry sourceFile) => _fileStates[sourceFile];

  List<FileEntry> get trackedFiles => _fileStates.keys.toList();

  Future<bool> stageFiles({
    required String? sourceDirectoryPath,
  }) async {
    _failureReason = null;
    _loading = true;
    _fileStates.clear();
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (sourceDirectoryPath == null) {
      _loading = false;
      _failureReason = FailureReason.sourceNotFound;
      notifyListeners();
      return false;
    }

    var listing =
        await sourceRepository.listFiles(directoryPath: sourceDirectoryPath);
    _fileStates
        .addEntries(listing.map((e) => MapEntry(e, FileProgress.staged())));
    _loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> uploadFiles({
    required String? targetDirectoryPath,
  }) async {
    _loading = true;
    _failureReason = null;
    notifyListeners();

    if (targetDirectoryPath == null) {
      _loading = false;
      _failureReason = FailureReason.targetNotFound;
      notifyListeners();
      return false;
    }

    var futures = _fileStates.entries.map((entry) => _uploadFile(
          sourceFile: entry.key,
          targetDirectoryPath: targetDirectoryPath,
        ));
    var results = await Future.wait(futures);

    _loading = false;
    notifyListeners();
    return results.every((success) => success);
  }

  Future<bool> _uploadFile({
    required FileEntry sourceFile,
    required String targetDirectoryPath,
  }) async {
    _fileStates[sourceFile] = FileProgress.ongoing();
    notifyListeners();

    await Future.delayed(Duration(milliseconds: Random().nextInt(6000)));

    var uploadSucceeded = await targetRepository.uploadFile(
      sourceFilePath: sourceFile.path,
      targetDirectoryPath: targetDirectoryPath,
      onProgressUpdate: (progress) {
        _fileStates[sourceFile] = FileProgress.ongoing(progress);
        notifyListeners();
      },
    );

    if (!uploadSucceeded) {
      _fileStates[sourceFile] = FileProgress.error('upload.failed');
      notifyListeners();
      return false;
    }

    if (!shouldDeleteFilesAfterUpload) {
      _fileStates[sourceFile] = FileProgress.success();
      notifyListeners();
      return true;
    }

    var deletionSucceeded = await sourceRepository.deleteFile(
      filePath: sourceFile.path,
    );

    if (!deletionSucceeded) {
      _fileStates[sourceFile] = FileProgress.error('upload.deletion.failed');
      notifyListeners();
      return false;
    }

    _fileStates[sourceFile] = FileProgress.success();
    notifyListeners();
    return true;
  }
}
