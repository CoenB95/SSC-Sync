import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pref/pref.dart';

class SettingsLayout extends StatelessWidget {
  static const routeName = '/settings';

  // String localDirectory;
  // SharedPreferences preferences;
  // TextEditingController remoteFileEditController = TextEditingController();

  const SettingsLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settings),
      ),
      body: PrefPage(
        children: [
          PrefText(
            pref: 'ftp_username',
            label: strings.ftpUsername,
          ),
          PrefText(
            pref: 'ftp_password',
            label: strings.ftpPassword,
            obscureText: true,
          ),
          const Divider(),
          PrefLabel(
            title: Text('Source dir'),
            subtitle: Text(
                PrefService.of(context).get<String>('local_location') ??
                    '<not set>'),
            onTap: () => _chooseDirectory(context, pref: 'local_location'),
          ),
          PrefLabel(
            title: Text('Target dir'),
            subtitle: Text(
                PrefService.of(context).get<String>('remote_location') ??
                    '<not set>'),
            onTap: () => _chooseDirectory(context, pref: 'remote_location'),
          )
          // Divider(),
          // FilePreference(
          //     StringPreference(preferences, 'local_location'), 'Van'),
          // TextFieldPreference(
          //     StringPreference(preferences, 'remote_location'),
          //     'Naar'),
          // TogglePreference(
          //     BooleanPreference(
          //         preferences, 'should_delete_files', true),
          //     'Bestanden verwijderen na uploaden'),
        ],
      ),
    );
  }

  void _chooseDirectory(BuildContext context, {required String pref}) async {
    final preferences = PrefService.of(context);
    var directoryPath = await FilePicker.platform.getDirectoryPath();
    preferences.set(pref, directoryPath);
  }
}
