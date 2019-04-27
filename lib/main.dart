import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssc_sync/file_browser.dart';
import 'package:ssc_sync/file_upload.dart';
import 'package:ssc_sync/ftp.dart';
import 'package:ssc_sync/setting.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFFC2CE24),
        primaryColorDark: Color(0xFFA9B50B),
        accentColor: Color(0xFF00646C),
        disabledColor: Colors.grey,
      ),
      home: MyHomePage(title: 'SSC Sync'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FTPClient _client = FTPClient('ftp.kempengemeenten.nl');
  String localDirectoryPath;
  String remoteDirectoryPath;

  bool get filesOk => localDirectoryPath != null && remoteDirectoryPath != null;

  @override
  void initState() {
    super.initState();
    _setupClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_client.isAuthenticated
                  ? filesOk ? 'Gereed voor uploaden' : 'Bestandslocaties niet ingesteld'
                  : 'Laden...'),
              Expanded(
                child: Center(
                  child: FileUploadStatusWidget(_client, localDirectoryPath, remoteDirectoryPath,
                  enabled: _client.isAuthenticated && filesOk,
                  ),
                ),
              ),
              FlatButton(
                child: Text('Instellingen'),
                onPressed: _toSettings,
              )
            ],
          ),
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        heroTag: 'browserFab',
        onPressed: _client.isAuthenticated ? _toFileBrowser : null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),*/
    );
  }

  void _setupClient() async {
    var preferences = await SharedPreferences.getInstance();
    localDirectoryPath = preferences.getString('local_location');
    remoteDirectoryPath = preferences.getString('remote_location');
    await _client.connect();
    await _client.authenticate('Geo1', 'Ftpgeo1');
    await _client.assertConnected();

    setState(() {
      _client = _client;
    });
  }

  void _toSettings() async {
    await Navigator.push(context, new MaterialPageRoute(
      builder: (c) => SettingsPage(),
    )
    );

    //Coming back from settings, things might have changed.
    _setupClient();
  }
}
