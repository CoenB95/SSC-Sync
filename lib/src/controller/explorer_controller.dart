import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../repository/file_repository.dart';
import 'settings_controller.dart';

enum FailureReason {
  loginFailed,
  sourceNotFound,
  targetNotFound;

  String localized(BuildContext context) {
    var localization = AppLocalizations.of(context)!;
    var reason = {
          loginFailed: localization.failureReasonLoginFailed,
          sourceNotFound: 'Source not found',
          targetNotFound: 'Target not found'
        }[this] ??
        'Unknown reason';
    return reason;
  }
}

class ExplorerController with ChangeNotifier {
  final SettingsController settingsController;

  ExplorerController({
    required this.settingsController,
  }) {
    settingsController.addListener(() {
      var fileRepository = _fileRepository;

      if (fileRepository is FtpFileRepository) {
        fileRepository.logout();
      }
    });
  }

  FailureReason? get failureReason => _failureReason;
  List<FileEntry> get files => _files;
  String get currentPath => _path;
  bool get loading => _loading;

  FailureReason? _failureReason;
  FileRepository? _fileRepository;
  List<FileEntry> _files = [];
  bool _loading = false;
  String _path = '/';

  list(String path) async {
    var fileRepository = _fileRepository;

    if (fileRepository == null) {
      return;
    }

    _loading = true;
    _files = [];
    _path = path;
    notifyListeners();

    if (fileRepository is FtpFileRepository) {
      if (!fileRepository.isLoggedIn) {
        var loginSuccess = await fileRepository.login(
          host: 'ftp.kempengemeenten.nl',
          username: settingsController.username ?? '',
          password: settingsController.password ?? '',
        );

        if (!loginSuccess) {
          _failureReason = FailureReason.loginFailed;
          _loading = false;
          notifyListeners();
          return;
        }
      }
    }

    _files = await fileRepository.listFiles(directoryPath: path);
    _loading = false;
    notifyListeners();
  }

  set repository(FileRepository fileRepository) =>
      _fileRepository = fileRepository;
}
