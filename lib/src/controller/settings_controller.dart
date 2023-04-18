import 'package:flutter/widgets.dart';

import '../repository/settings_repository.dart';

class SettingsController with ChangeNotifier {
  final SettingsRepository repository;

  String? _localDirectoryPath;
  String? _remoteDirectoryPath;
  late bool _shouldDeleteFiles;
  String? _username;
  String? _password;

  SettingsController({
    required this.repository,
  });

  String? get localDirectoryPath => _localDirectoryPath;
  String? get remoteDirectoryPath => _remoteDirectoryPath;
  bool get shouldDeleteFiles => _shouldDeleteFiles;
  String? get username => _username;
  String? get password => _password;

  Future load() async {
    _localDirectoryPath = await repository.getString('local_location');
    _remoteDirectoryPath = await repository.getString('remote_location');
    _shouldDeleteFiles =
        await repository.getBool('should_delete_files') ?? false;
    _username = await repository.getString('ftp_username');
    _password = await repository.getString('ftp_password');
    notifyListeners();
  }
}
