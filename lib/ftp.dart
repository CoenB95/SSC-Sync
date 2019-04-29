import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';

class FTPClient {
  String _hostname;
  String _password;
  String _username;
  FTPSession _conversationChannel;
  bool _authenticated = false;
  bool _connected = false;

  bool get isAuthenticated => _username != null;
  bool get isConnected => _connected;

  FTPClient(this._hostname);

  Future _authenticate([String username, String password]) async {
    username = username ?? _username;
    password = password ?? _password;

    if (_authenticated && _username != null && _username == username) {
      print('Authenticated');
    }

    _authenticated = false;
    _username = null;
    _password = null;

    print('Authenticating...');
    _conversationChannel.send('USER $username');
    await _conversationChannel.expect([331]);
    _conversationChannel.send('PASS $password');
    await _conversationChannel.expect([230]);
    _authenticated = true;
    _username = username;
    _password = password;
  }

  Future _connect() async {
    if (_connected) {
      print('Connected');
    }

    print('Connecting...');
    _conversationChannel = await FTPSession.connect(_hostname, 21);
    await _conversationChannel.expect([220]);
    return _connected = true;
  }

  Future assertConnected([String username, String password]) async {
    if (_conversationChannel?.disconnected ?? false) {
      _authenticated = false;
      _connected = false;
    }

    await _connect();
    await _authenticate(username ?? _username, password ?? _password);
  }

  Future _cwd(String remoteDirectoryPath) async {
    _conversationChannel.send('CWD $remoteDirectoryPath');
    await _conversationChannel.expect([250]); //Success
  }

  void logOut() {
    _authenticated = false;
  }

  Future uploadFile(String localFilePath, String remoteDirectoryPath,
      {void onProgressUpdate(double value), bool removeAfterSuccess = true}) async {
    await assertConnected();
    await _cwd(remoteDirectoryPath);
    var dataChannel = await _startPassiveSession();

    File localFile = File(localFilePath);
    String localFileName = localFilePath.substring(localFilePath.lastIndexOf('/') + 1, localFilePath.length);
    print("Start file '$localFileName' sending");
    _conversationChannel.send('STOR $localFileName');
    await _conversationChannel.expect([150]); //Started
    await dataChannel.sendFile(localFile, onProgressUpdate: onProgressUpdate);
    await dataChannel.close();
    await _conversationChannel.expect([226]); //Finished

    if (removeAfterSuccess) {
      await localFile.delete();
    }
  }

  Future<List<FTPFile>> listFiles([FTPFile location]) async {
    location = location ?? FTPFile('dir', DateTime.now(), '/');
    await assertConnected();
    await _cwd(location.path);
    var dataChannel = await _startPassiveSession();

    print('Start list retreival');
    _conversationChannel.send('MLSD');
    await _conversationChannel.expect([150]); //Started
    await _conversationChannel.expect([226]); //Finished
    var rawListing = await dataChannel.nextData();
    return rawListing.split(RegExp(r'\r\n')).map((s) {
      if (s.isEmpty)
        return null;

      String type = RegExp(r'(type=([\w]*);)').firstMatch(s)?.group(2);
      String dateStr = RegExp(r'(modify=([\w]*);)').firstMatch(s)?.group(2);
      String name = s.substring(s.lastIndexOf(RegExp(';')) + 2);
      return FTPFile(type, DateTime.now() /*parse(dateStr)*/,
          '${location?.path ?? ''}/$name');
    }).where((f) => f != null).toList();
  }

  Future<FTPSession> _startPassiveSession() async {
    print('Entering passive mode...\n');
    _conversationChannel.send('PASV');
    var r = await _conversationChannel.expect([227]);
    String rawAddress = RegExp(r'([\d,]*(?=\)))').firstMatch(r.message)[0];
    List<String> spl = rawAddress.split(RegExp(','));
    var address = InternetAddress(spl.getRange(0, 4).join('.'));
    var port = (int.tryParse(spl[4]) ?? 0) * 256 + (int.tryParse(spl[5]) ?? 0);
    print('Passive mode entered.\n');
    print('- ip:\t$address\n- port:\t$port');
    return await FTPSession.connect(address, port);
  }
}

class FTPFile {
  final String path;
  final DateTime modifyDate;
  final String _type;

  bool get isDirectory => _type == 'dir';
  bool get isFile => _type == 'file';
  String get name => path.substring(path.lastIndexOf('/') + 1, path.length);
  String get typeString => isDirectory ? 'directory' : isFile ? 'file' : 'unknown';

  FTPFile(this._type, this.modifyDate, this.path);
}

enum FTPFileType {
  dir,
  file,
  unknown
}

class FTPResponse {
  final int code;
  final String message;

  FTPResponse(this.code, this.message);
}

class FTPSession {
  bool disconnected = false;
  StreamQueue<String> _inputStream;
  final Socket _socket;

  FTPSession._internal(this._socket);

  static Future<FTPSession> connect(dynamic address, int port) async {
    FTPSession session = FTPSession._internal(await Socket.connect(address, port));
    session._inputStream = StreamQueue(session._socket.map((l) => String.fromCharCodes(l)));
    return session;
  }

  Future close() async {
    disconnected = true;
    return await _socket.close();
  }

  Future<FTPResponse> expect(List<int> codes) async {
    var rawResponse = await nextData();
    var response = FTPResponse(int.parse(rawResponse.substring(0, 3)), rawResponse.substring(4));
    if (codes.contains(response.code)) {
      print('Expected response [${response.code}]: ${response.message}');
      return response;
    }

    String error = 'Unexpected response [${response.code}]: ${response.message}';
    print(error);

    switch (response.code) {
      case 421:
        disconnected = true;
        throw 'Timed out. Try again';
        break;
      default:
        break;
    }
    disconnected = true;
    throw '$error';
  }

  Future<String> nextData() async => await _inputStream.next;

  Future send(String message) async {
    _socket.write('$message\r\n');
    return await _socket.flush();
  }

  Future sendFile(File file, {void onProgressUpdate(double value)}) async {
    var dataStream = file.openRead();
    int dataLength = file.lengthSync();
    return sendRawStream(dataStream, dataLength, onProgressUpdate: onProgressUpdate);
  }

  Future sendRawStream(Stream<List<int>> dataStream, int dataLength,
      {void onProgressUpdate(double value)}) async {
    int dataCount = 0;

    Stream<List<int>> socketLus = dataStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          dataCount += data.length;
          var progress = dataCount/dataLength;
          print('$dataCount/$dataLength (${(progress * 100).toStringAsFixed(1)}%)');
          if (onProgressUpdate != null)
            onProgressUpdate(progress);
          sink.add(data);
        },
        handleError: (error, stack, sink) {
          print('error: $error');
          sink.close();
        },
        handleDone: (sink) {
          print('success');
          sink.close();
        },
      ),
    );
    await _socket.addStream(socketLus);
    return await _socket.flush();
  }
}