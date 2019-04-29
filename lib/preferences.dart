import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TogglePreference extends StatelessWidget {
  final String onText;
  final String offText;
  final String title;
  final BooleanPreference preference;

  TogglePreference(this.preference, this.title,
      [this.onText = '', this.offText = '']);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: onText.isEmpty && offText.isEmpty
          ? null
          : Text(preference.value ? onText : offText),
      leading: Checkbox(
        value: preference.value,
        onChanged: (v) {
          preference.value = v;
        },
      ),
    );
  }
}

class TextFieldPreference extends StatelessWidget {
  final String emptyText;
  final bool hidden;
  final String title;
  final StringPreference preference;

  TextFieldPreference(this.preference, this.title, {this.emptyText = 'Niet ingesteld',
    this.hidden = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: hidden
          ? (preference.value == null ? Text(emptyText) : null)
          : Text(preference.value ?? emptyText),
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
                  obscureText: hidden,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Annuleer'),
                onPressed: () => Navigator.pop(context, preference.value),
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
  final String emptyText;
  final String title;
  final StringPreference preference;

  FilePreference(this.preference, this.title, [this.emptyText = 'Niet ingesteld']);

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

class BooleanPreference {
  final bool defaultValue;
  final String key;
  final SharedPreferences _preferenceManager;

  bool get value => _preferenceManager.getBool(key) ?? defaultValue;
  set value(bool value) => _preferenceManager.setBool(key, value);

  BooleanPreference(this._preferenceManager, this.key, this.defaultValue);

  static Future<BooleanPreference> load(String key, bool defaultValue) async {
    return BooleanPreference(await SharedPreferences.getInstance(), key, defaultValue);
  }
}

class StringPreference {
  final String defaultValue;
  final String key;
  final SharedPreferences _preferenceManager;

  String get value => _preferenceManager.getString(key) ?? defaultValue;
  set value(String value) => _preferenceManager.setString(key, value);

  StringPreference(this._preferenceManager, this.key, {this.defaultValue});

  static Future<StringPreference> load(String key) async {
    return StringPreference(await SharedPreferences.getInstance(), key);
  }
}