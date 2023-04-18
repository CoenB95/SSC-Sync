import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

abstract class FileRepository {
  Future<bool> deleteFile({
    required String filePath,
  });

  Future<List<String>> listFiles({
    required String directoryPath,
  });

  Future uploadFile({
    required String sourceFilePath,
    required String targetDirectoryPath,
    void Function(double value)? onProgressUpdate,
  });
}

class FtpFileRepository implements FileRepository {
  final FTPConnect connection;
  final Logger logger;

  FtpFileRepository({
    required this.connection,
    required this.logger,
  });

  @override
  Future<bool> deleteFile({
    required String filePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> listFiles({required String directoryPath}) {
    throw UnimplementedError();
  }

  @override
  Future uploadFile({
    required String sourceFilePath,
    required String targetDirectoryPath,
    void Function(double value)? onProgressUpdate,
  }) async {
    var sourceFile = File(sourceFilePath);
    var sourceFileName = path.basename(sourceFile.path);

    if (!await sourceFile.exists()) {
      logger.e('File uploading aborted: Source file not found');
      return false;
    }

    if (!await connection.changeDirectory(targetDirectoryPath)) {
      logger.e('File uploading failed: Could not change to target directory');
      return false;
    }

    logger.d('File uploading started (Path=$sourceFileName)');

    if (!await connection.uploadFile(
      sourceFile,
      onProgress: (progressInPercent, totalReceived, fileSize) =>
          onProgressUpdate?.call(progressInPercent),
    )) {
      logger.e('File uploading failed');
      return false;
    }

    logger.d('File uploaded successfully');
    return true;
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
  Future<List<String>> listFiles({required String directoryPath}) {
    var listing = Directory(directoryPath).list();
    return listing.map((e) => e.path).toList();
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
