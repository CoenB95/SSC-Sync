import 'package:flutter/material.dart';
import 'package:ssc_sync/src/repository/file_repository.dart';

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

  bool get loading => _loading;
  double get progress => _progress;
  String? get status => _status;

  bool _loading = false;
  double _progress = 0;
  String? _status;

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

  final Map<String, FileProgress> _fileStates = {};

  FileProgress? state(String sourceFilePath) => _fileStates[sourceFilePath];

  Iterable<String> get trackedFiles => _fileStates.keys;

  Future<bool> uploadFiles({
    required String? sourceDirectoryPath,
    required String? targetDirectoryPath,
  }) async {
    _loading = true;
    _fileStates.clear();
    notifyListeners();

    if (sourceDirectoryPath == null) {
      _loading = false;
      _status = 'No source directory';
      notifyListeners();
      return false;
    }

    var listing =
        await sourceRepository.listFiles(directoryPath: sourceDirectoryPath);

    if (listing.isEmpty) {
      _status = 'Niets gevonden om te uploaden';
      _progress = 1;
      _loading = false;
      notifyListeners();
      return true;
    }

    if (targetDirectoryPath == null) {
      _loading = false;
      _status = 'No target directory';
      notifyListeners();
      return false;
    }

    _fileStates
        .addEntries(listing.map((e) => MapEntry(e, FileProgress.ongoing())));
    notifyListeners();

    var results = await Future.wait(listing.map((sourceFilePath) => _uploadFile(
          sourceFilePath: sourceFilePath,
          targetDirectoryPath: targetDirectoryPath,
        )));

    _loading = false;
    notifyListeners();
    return results.every((success) => success);
  }

  Future<bool> _uploadFile({
    required String sourceFilePath,
    required String targetDirectoryPath,
  }) async {
    _fileStates[sourceFilePath] = FileProgress.ongoing(null);
    notifyListeners();

    var uploadSucceeded = await targetRepository.uploadFile(
      sourceFilePath: sourceFilePath,
      targetDirectoryPath: targetDirectoryPath,
      onProgressUpdate: (progress) {
        _fileStates[sourceFilePath] = FileProgress.ongoing(progress);
        notifyListeners();
      },
    );

    if (!uploadSucceeded) {
      _fileStates[sourceFilePath] = FileProgress.error('upload.failed');
      notifyListeners();
      return false;
    }

    if (!shouldDeleteFilesAfterUpload) {
      _fileStates[sourceFilePath] = FileProgress.success();
      notifyListeners();
      return true;
    }

    var deletionSucceeded = await sourceRepository.deleteFile(
      filePath: sourceFilePath,
    );

    if (!deletionSucceeded) {
      _fileStates[sourceFilePath] =
          FileProgress.error('upload.deletion.failed');
      notifyListeners();
      return false;
    }

    _fileStates[sourceFilePath] = FileProgress.success();
    notifyListeners();
    return true;
  }
}
