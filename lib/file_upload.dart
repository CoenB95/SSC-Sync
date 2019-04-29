import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ssc_sync/animated_progress.dart';
import 'package:ssc_sync/ftp.dart';

class FileUploadStatusWidget extends StatefulWidget {
  final FTPClient client;
  final String localDirectoryPath;
  final String remoteDirectoryPath;
  final bool removeLocalFiles;
  final bool enabled;

  FileUploadStatusWidget(this.client, this.localDirectoryPath, this.remoteDirectoryPath,
      {this.removeLocalFiles = true, this.enabled});

  @override
  State<StatefulWidget> createState() => FileUploadState();
}

class FileUploadState extends State<FileUploadStatusWidget> with SingleTickerProviderStateMixin {
  int filesUploaded = 0;
  int totalFileCount = 0;
  double curFileProgress = 0;
  bool loading = false;
  String status = '';

  bool get _active => widget.enabled && !loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AnimatedCircularProgressIndicator(
                  progress: _calcProgress(),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: FloatingActionButton(
                  child: Icon(Icons.cloud_upload),
                  backgroundColor: (!_active
                      ? Theme.of(context).disabledColor
                      : Theme.of(context).accentColor),
                  onPressed: !_active ? null : () => _upload(),
                ),
              ),
            ),
          ],
        ),
        Text(status),
      ],
    );
  }

  double _calcProgress() {
    if (!widget.enabled)
      return 0;

    if (!loading)
      return 0;

    return (filesUploaded + curFileProgress) / totalFileCount;
  }

  Future<bool> _upload() async {
    bool err = false;
    var listing = Directory(widget.localDirectoryPath).listSync();
    setState(() {
      loading = true;
      filesUploaded = 0;
      totalFileCount = listing.length;
    });
    if (listing.isEmpty) {
      setState(() {
        status = 'Niets gevonden om te uploaden';
        filesUploaded = 1;
        totalFileCount = 1;
      });
      await Future.delayed(Duration(seconds: 3));
    } else {
      for (var e in listing) {
        setState(() {
          status = '$filesUploaded/$totalFileCount (${(curFileProgress * 100).toStringAsFixed(0)}%)';
        });
        await widget.client.uploadFile(e.path, widget.remoteDirectoryPath,
            removeAfterSuccess: widget.removeLocalFiles,
            onProgressUpdate: (v) {
              setState(() {
                curFileProgress = v;
                status = '$filesUploaded/$totalFileCount (${(curFileProgress * 100).toStringAsFixed(0)}%)';
              });
            }).then((t) {
          setState(() {
            curFileProgress = 0;
            filesUploaded++;
          });
        }).catchError((error) async {
          setState(() {
            err = true;
            status = 'Probleem bij uploaden: $error';
            print('Error uploading file: $error');
          });
          await Future.delayed(Duration(seconds: 2));
        });
      }
    }
    setState(() {
      status = err
          ? (totalFileCount == 1
          ? 'Het bestand kon niet geüpload worden'
          : '${totalFileCount - filesUploaded} van de $totalFileCount bestanden zijn niet geüpload')
          : 'Klaar; $filesUploaded bestand${filesUploaded == 1 ? ' is' : 'en zijn'} geüpload';
    });
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      status = '';
      loading = false;
    });
    return !err && filesUploaded == totalFileCount;
  }
}