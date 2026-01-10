import 'dart:isolate';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadService extends GetxService {
  final ReceivePort _port = ReceivePort();

  // Observables that other controllers can listen to
  var currentTaskId = "".obs;
  var currentStatus = DownloadTaskStatus.fromInt(0).obs;
  var currentProgress = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _bindBackgroundIsolate();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    if (!isSuccess) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];

      // Update global state
      currentTaskId.value = id;
      currentStatus.value = status;
      currentProgress.value = progress;
    });
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.onClose();
  }
}
