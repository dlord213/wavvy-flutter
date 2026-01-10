import 'dart:ui';
import 'dart:isolate';
import 'package:flutter_downloader/flutter_downloader.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );
  send?.send([id, status, progress]);
}

class DownloaderUtils {}
