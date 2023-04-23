import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:ftpconnect/src/dto/ftp_entry.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

enum FileEntryType {
  file,
  dir;
}

class FileEntry {
  final String path;
  final FileEntryType? type;

  FileEntry(this.path, this.type);

  String get name => basename(path);
}

abstract class FileRepository {
  Future<bool> deleteFile({
    required String filePath,
  });

  Future<List<FileEntry>> listFiles({
    required String directoryPath,
  });

  Future uploadFile({
    required String sourceFilePath,
    required String targetDirectoryPath,
    void Function(double value)? onProgressUpdate,
  });
}

class FtpFileRepository implements FileRepository {
  final Logger logger;

  FtpFileRepository({
    required this.logger,
  });

  bool get isLoggedIn => _client != null;

  FTPConnect? _client;

  @override
  Future<bool> deleteFile({
    required String filePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<FileEntry>> listFiles({required String directoryPath}) async {
    var client = _client;

    try {
      if (client == null) {
        logger.w('Listing files failed: Login not set');
        return [];
      }

      if (!await client.connect()) {
        logger.e('Listing files failed: Could not connect to FTP server');
        return [];
      }

      logger.d('Listing files started (Path=$directoryPath)');
      var rawFiles = await client.listDirectoryContent();

      if (!await client.disconnect()) {
        logger.w('Failed to disconnect after listing files');
      }

      logger.d('Listing files succeeded (Count=${rawFiles.length})');
      var files = rawFiles.map((e) {
        FileEntryType? type;

        switch (e.type) {
          case FTPEntryType.FILE:
            type = FileEntryType.file;
            break;
          case FTPEntryType.DIR:
            type = FileEntryType.dir;
            break;
          default:
            break;
        }

        return FileEntry(
          join(directoryPath, e.name),
          type,
        );
      }).toList();
      return files;
    } catch (err) {
      logger.e('Listing files failed', err);
      return [];
    }
  }

  Future<bool> login({
    required String host,
    required String username,
    required String password,
  }) async {
    try {
      var client = FTPConnect(host, user: username, pass: password);
      logger.d('Login to $host..');

      if (!await client.connect()) {
        logger.e('Login failed: Could not connect to FTP server');
        return false;
      }

      if (!await client.disconnect()) {
        logger.w('Failed to disconnect after login');
      }

      _client = client;
      logger.i('Login succeeded');
      return true;
    } catch (err) {
      logger.e('Login failed', err);
      return false;
    }
  }

  void logout() {
    _client = null;
  }

  @override
  Future<bool> uploadFile({
    required String sourceFilePath,
    required String targetDirectoryPath,
    void Function(double value)? onProgressUpdate,
  }) async {
    var sourceFile = File(sourceFilePath);
    var sourceFileName = basename(sourceFile.path);

    if (!await sourceFile.exists()) {
      logger.e('File uploading aborted: Source file not found');
      return false;
    }

    var client = _client;

    try {
      if (client == null) {
        logger.e('File uploading failed: Login not set');
        return false;
      }

      if (!await client.connect()) {
        logger.e('File uploading failed: Could not connect to FTP server');
        return false;
      }

      if (!await client.changeDirectory(targetDirectoryPath)) {
        logger.e('File uploading failed: Could not change to target directory');
        return false;
      }

      logger.d('File uploading started (Path=$sourceFileName)');

      if (!await client.uploadFile(
        sourceFile,
        onProgress: (progressInPercent, totalReceived, fileSize) =>
            onProgressUpdate?.call(progressInPercent),
      )) {
        logger.e('File uploading failed');
        return false;
      }

      if (!await client.disconnect()) {
        logger.w('Failed to disconnect after uploading file');
      }

      logger.d('File uploaded successfully');
      return true;
    } catch (err) {
      logger.e('Listing files failed', err);
      return false;
    }
  }
}

class LocalFileRepository implements FileRepository {
  final Logger logger;

  LocalFileRepository({
    required this.logger,
  });

  @override
  Future<bool> deleteFile({
    required String filePath,
  }) async {
    var file = File(filePath);

    if (!await file.exists()) {
      logger.e('File deletion aborted: Not found');
      return false;
    }

    try {
      await file.delete();
    } catch (err) {
      logger.e('File deletion failed', err);
      return false;
    }

    logger.d('File deleted successfully');
    return true;
  }

  @override
  Future<List<FileEntry>> listFiles({required String directoryPath}) async {
    var listing = Directory(directoryPath).list();
    return listing.map((e) {
      FileEntryType? type;

      switch (e.statSync().type) {
        case FileSystemEntityType.directory:
          type = FileEntryType.dir;
          break;
        case FileSystemEntityType.file:
          type = FileEntryType.file;
          break;
        default:
          break;
      }

      return FileEntry(
        e.path,
        type,
      );
    }).toList();
  }

  @override
  Future uploadFile({
    required String sourceFilePath,
    required String targetDirectoryPath,
    void Function(double value)? onProgressUpdate,
  }) {
    throw UnimplementedError();
  }
}
