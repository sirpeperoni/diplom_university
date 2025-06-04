import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadRepository extends ChangeNotifier {
  int downloadProgress = 0;
  ReceivePort receivePort = ReceivePort();

  Future<void> createEnqueue(String url) async {
    FlutterDownloader.registerCallback(callback);

    await FlutterDownloader.enqueue(
        url: url, savedDir: "/storage/emulated/0/Download", saveInPublicStorage: true);
  }

  @pragma('vm:entry-point')
  static void callback(String id, int status, int progress) {
    final SendPort? sPort = IsolateNameServer.lookupPortByName("download_port");
    sPort?.send([id, status, progress]);
  }

  void _dispose() {
    IsolateNameServer.removePortNameMapping("download_port");
  }

  Future<void> registerIsolate() async {
    bool success = IsolateNameServer.registerPortWithName(receivePort.sendPort, "download_port");
    if(!success) {
    registerIsolate();
    _dispose();
    }
    receivePort.listen((dynamic data) {
      downloadProgress = _getProgress(data[1], data[2]);
    });
    _dispose();
  }

  int _getProgress (DownloadTaskStatus status, int progress) {
    switch(status.index) {
      case 0:
        downloadProgress = progress;
        notifyListeners();
        break;
      case 1:
        downloadProgress = progress;
        notifyListeners(); 
        break;
      case 2:
        downloadProgress = progress;
        notifyListeners();
        break;
      case 3:
        downloadProgress = progress;
        notifyListeners();
        break;
      case 4:
        downloadProgress = progress;
        notifyListeners();
        break;
      case 5:
        downloadProgress = progress;
        notifyListeners();
        break;
      case 6:
        downloadProgress = progress;
        notifyListeners();
        break;
      default:
        downloadProgress;
    }
    return downloadProgress;
  }


  void reset() {
    downloadProgress = 0;
    notifyListeners();
  }



  

}