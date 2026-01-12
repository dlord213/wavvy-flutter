import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/service/downloader.service.dart';
import 'package:wavvy/utils/snackbar.utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class YtdlpController extends GetxController {
  final _yt = YoutubeExplode();
  final AudioController _ac = Get.find();
  final DownloadService _downloadService = Get.find();

  // --- STATE MANAGEMENT FIX ---
  // Use Maps instead of single variables to track multiple downloads at once
  var progressMap = <String, int>{}.obs;
  var statusMap = <String, DownloadTaskStatus>{}.obs;
  var taskTitles = <String, String>{}.obs; // Key: taskId, Value: Title

  var convertedFilePaths = <String, String>{}.obs;
  var results = <dynamic>[].obs; // Typed as Video for safety

  final ReceivePort _port = ReceivePort();

  @override
  void onInit() {
    super.onInit();
    loadExistingDownloads();

    ever(_downloadService.downloadEvent, (List<dynamic>? data) {
      if (data == null) return;

      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];

      // Only update if this task belongs to us
      if (taskTitles.containsKey(id)) {
        progressMap[id] = progress;
        statusMap[id] = status;

        // Force UI rebuild for specific maps
        progressMap.refresh();
        statusMap.refresh();
      }
    });
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
    super.onClose();
  }

  void search(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final searchList = await _yt.search.search(query);
      results.value = searchList.toList();
    } catch (e) {
      AppSnackbar.showErrorSnackBar("Error", "Search failed: $e");
    }
  }

  Future<void> _convertToMp3(String taskId) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id='$taskId'",
    );

    print("Background Isolate -> CONVERTING");

    if (tasks == null || tasks.isEmpty) return;

    final task = tasks.first;
    final String inputPath = "${task.savedDir}/${task.filename}";
    final String outputPath = inputPath.replaceAll(RegExp(r'\.[^.]+$'), '.mp3');

    // Only convert if it's not already mp3
    if (inputPath == outputPath) return;
  }

  void showDownloadDialog(Video video) async {
    Get.dialog(const Center(child: CircularProgressIndicator()));

    try {
      final manifest = await _yt.videos.streamsClient.getManifest(
        video.id,
        ytClients: [YoutubeApiClient.android],
      );
      final streams = manifest.muxed.sortByVideoQuality();
      Get.back();

      Get.dialog(
        AlertDialog(
          title: const Text("Download"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: streams.length,
              itemBuilder: (context, i) {
                final s = streams[i];
                return ListTile(
                  leading: const Icon(Icons.audiotrack),
                  title: Text("${s.bitrate} (${s.container.name})"),
                  subtitle: Text(
                    "${s.size.totalMegaBytes.toStringAsFixed(2)} MB",
                  ),
                  trailing: const Icon(Icons.download),
                  onTap: () {
                    Get.back();
                    startBackgroundDownload(
                      s.url.toString(),
                      video.title,
                      s
                          .container
                          .name, // Keep original extension for ffmpeg safety
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      Get.back();
      AppSnackbar.showErrorSnackBar("Error", "Could not fetch streams");
    }
  }

  Future<void> startBackgroundDownload(
    String url,
    String title,
    String ext,
  ) async {
    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (!await downloadsDir.exists()) {
      downloadsDir = await getExternalStorageDirectory();
    }

    final fileName = "${title.replaceAll(RegExp(r'[^\w\s]+'), '')}.$ext";

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadsDir?.path ?? "",
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: false, // Set false to handle opening manually
      saveInPublicStorage: true,
      allowCellular: true,
    );

    if (taskId != null) {
      taskTitles[taskId] = title;
      progressMap[taskId] = 0;
      statusMap[taskId] = DownloadTaskStatus.enqueued;
    }
  }

  Future<void> loadExistingDownloads() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      for (var task in tasks) {
        progressMap[task.taskId] = task.progress;
        statusMap[task.taskId] = task.status;
        taskTitles[task.taskId] = task.filename ?? "Unknown";
      }
    }
  }

  Future<void> removeDownload(String taskId) async {
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
    progressMap.remove(taskId);
    statusMap.remove(taskId);
    taskTitles.remove(taskId);
  }

  void confirmDelete(String taskId) {
    Get.defaultDialog(
      title: "Delete",
      middleText: "Delete this file?",
      textConfirm: "Yes",
      textCancel: "No",
      onConfirm: () {
        removeDownload(taskId);
        Get.back();
      },
    );
  }
}
