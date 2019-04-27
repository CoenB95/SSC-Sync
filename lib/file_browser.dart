import 'package:flutter/material.dart';
import 'package:ssc_sync/ftp.dart';

class FileBrowserPage extends StatelessWidget {
  final FTPClient _client;
  final FTPFile _file;

  FileBrowserPage(this._client, [this._file]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kies'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('FTP Status: '),
          Expanded(
            child: FTPBrowserWidget(_client, _file),
          ),
        ],
      ),
    );
  }
}

class FTPBrowserWidget extends StatelessWidget {
  final FTPClient _client;
  final FTPFile _desiredLocation;

  FTPBrowserWidget(this._client, [this._desiredLocation]);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FTPFile>>(
      future: _client.listFiles(_desiredLocation),
      builder: (c, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (c, i) =>
                  ListTile(
                    title: Text(snapshot.data[i].name),
                    subtitle: Text(snapshot.data[i].typeString),
                    onTap: snapshot.data[i].isDirectory ?
                        () => _selectDirectory(context, snapshot.data[i]) : null,
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
    );
  }

  void _selectDirectory(BuildContext context, FTPFile file) {
    Navigator.push(context, new MaterialPageRoute(
      builder: (c) => FileBrowserPage(_client, file),
    )
    );
  }
}