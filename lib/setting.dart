import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssc_sync/preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State {
  String localDirectory;
  SharedPreferences preferences;
  TextEditingController remoteFileEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instellingen'),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: _restoreSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: ListView(
                  children: <Widget>[
                    FilePreference(StringPreference(preferences, 'local_location'), 'Van'),
                    TextFieldPreference(StringPreference(preferences, 'remote_location'), 'Naar'),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.error}"),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<String> _editLocalDirectory() async {
    String filePath = await FilePicker.getFilePath();
    localDirectory = filePath.substring(0, filePath.lastIndexOf('/'));
    _saveSettings();
  }

  Future<String> _editRemoteDirectory(BuildContext context) async {
  }

  Future<String> _showStringPreferenceDialog(String key, String hint) async {
    TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return Column(
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: hint,
              ),
              onSubmitted: (s) => Navigator.pop(context, s),
            ),
          ],
        );
      }
    );
  }


  Future<SharedPreferences> _restoreSettings() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      localDirectory = preferences.getString('local_location');
      remoteFileEditController.text = preferences.getString('remote_location');
    });
    return preferences;
  }

  void _saveSettings() async {
    await preferences.setString('local_location', localDirectory);
    await preferences.setString('remote_location', remoteFileEditController.text);
    print('saved');
  }
}