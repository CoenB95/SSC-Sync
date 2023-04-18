import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controller/file_controller.dart';
import '../controller/settings_controller.dart';
import '../view/upload_view.dart';

class MyHomePage extends StatelessWidget {
  final FileController fileController;
  final SettingsController settingsController;

  const MyHomePage({
    required this.fileController,
    required this.settingsController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('<status>'),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: FileUploadView(
                      fileController: fileController,
                      settingsController: settingsController,
                    ),
                  ),
                ),
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.settings),
                onPressed: _toSettings,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toSettings() async {
    // await Navigator.push(
    //     context,
    //     new MaterialPageRoute(
    //       builder: (c) => SettingsPage(),
    //     ));

    // //Coming back from settings, things might have changed.
    // _setupClient();
  }
}
