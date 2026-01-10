import 'dart:isolate';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadService extends GetxService {
  final ReceivePort _port = ReceivePort();
  final String _portName = 'downloader_send_port';

  var currentTaskId = "".obs;
  var currentStatus = DownloadTaskStatus.undefined.obs;
  var currentProgress = 0.obs;

  final downloadEvent = Rxn<List<dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _bindBackgroundIsolate();
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(_portName);

    bool isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      _portName,
    );

    if (!isSuccess) {
      print('Could not register isolate port');
      return;
    }

    _port.listen((dynamic data) {
      // data = [String id, int status, int progress]
      // We explicitly update the value to trigger 'ever' in the controller
      downloadEvent.value = data;
    });
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping(_portName);
    _port.close();
    super.onClose();
  }
}
