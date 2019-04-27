import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextFieldPreference extends StatelessWidget {
  final String defaultValue;
  final String emptyText;
  final String title;
  final StringPreference preference;

  TextFieldPreference(this.preference, this.title,
      [this.emptyText = 'Niet ingesteld', this.defaultValue = '']);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(preference.value ?? 'Niet ingesteld'),
      onTap: () => _showTextFieldDialog(context),
    );
  }

  void _showTextFieldDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController(text: preference.value);
    preference.value =  await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: title,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Annuleer'),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('Save'),
                onPressed: () => Navigator.pop(context, controller.text),
              ),
            ],
          );
        }
    );
  }
}

class FilePreference extends StatelessWidget {
  final String defaultValue;
  final String emptyText;
  final String title;
  final StringPreference preference;

  FilePreference(this.preference, this.title,
      [this.emptyText = 'Niet ingesteld', this.defaultValue = '']);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(preference.value ?? 'Niet ingesteld'),
      onTap: () => _showFileDialog(context),
    );
  }

  void _showFileDialog(BuildContext context) async {
    String filePath = await FilePicker.getFilePath();
    preference.value = filePath.substring(0, filePath.lastIndexOf('/'));
  }
}

class StringPreference {
  final String key;
  final SharedPreferences _preferenceManager;

  String get value => _preferenceManager.getString(key);
  set value(String value) => _preferenceManager.setString(key, value);

  StringPreference(this._preferenceManager, this.key);

  static Future<StringPreference> load(String key) async {
    return StringPreference(await SharedPreferences.getInstance(), key);
  }
}