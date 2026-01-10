import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_scraper/enums.dart';
import 'package:tiktok_scraper/tiktok_scraper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wavvy/service/downloader.service.dart'; // Ensure this path is correct

class TikTokController extends GetxController {
  // Access the Global Service
  final DownloadService _downloadService = Get.find();

  // --- Observables for Search/Fetch ---
  var isLoading = false.obs;
  var fetchedVideo = Rxn<Map<String, dynamic>>();
  final TextEditingController urlController = TextEditingController();

  // --- Observables for Downloads ---
  var taskTitles = <String, String>{}.obs;
  var progressMap = <String, int>{}.obs;
  var statusMap = <String, DownloadTaskStatus>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // 1. LISTEN TO SERVICE (Instead of binding own isolate)
    // This triggers whenever ANY download updates in the app
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
    urlController.dispose();
    super.onClose();
  }

  // --- Fetch Video Info ---
  Future<void> fetchVideoInfo(String url) async {
    if (url.isEmpty) return;

    final cleanUrl = url.split("?").first;

    isLoading.value = true;
    fetchedVideo.value = null;

    try {
      var video = await TiktokScraper.getVideoInfo(
        url,
        source: ScrapeVideoSource.TikDownloader,
      );

      fetchedVideo.value = {
        'title': video.description ?? "TikTok Video",
        'author': video.author.name ?? "Unknown",
        'cover': video.thumbnail,
        'videoUrl': video.downloadUrls?.first ?? "",
        'id': video.id,
      };
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not fetch video. Link might be invalid or private.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      debugPrint("TikTok Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Download Logic ---
  Future<void> downloadVideo(Map<String, dynamic> videoData) async {
    // Permission check
    var status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    // Prepare directory

    Directory? downloadsDir = Directory('/storage/emulated/0/Download');
    if (!await downloadsDir.exists()) {
      downloadsDir = await getExternalStorageDirectory();
    }

    final saveDir = downloadsDir;

    final String downloadUrl = videoData['videoUrl'];
    final String title = videoData['title'];
    final String fileName =
        "tiktok_${videoData['id'] ?? DateTime.now().millisecondsSinceEpoch}.mp4";

    if (downloadUrl.isEmpty) {
      Get.snackbar("Error", "No download URL found");
      return;
    }

    final taskId = await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: saveDir?.path ?? "",
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
      allowCellular: true,
    );

    if (taskId != null) {
      // 2. REGISTER TASK LOCALLY
      // We add it to our map so the 'ever' listener knows to update it
      taskTitles[taskId] = title;
      progressMap[taskId] = 0;
      statusMap[taskId] = DownloadTaskStatus.enqueued;

      Get.snackbar(
        "Success",
        "Download started",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Cleanup UI
      fetchedVideo.value = null;
      urlController.clear();
    }
  }

  // --- Delete Logic ---
  void confirmDelete(String taskId) {
    Get.defaultDialog(
      title: "Delete Download",
      middleText: "Are you sure you want to remove this video?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await FlutterDownloader.remove(
          taskId: taskId,
          shouldDeleteContent: true,
        );
        taskTitles.remove(taskId);
        progressMap.remove(taskId);
        statusMap.remove(taskId);
        Get.back();
      },
    );
  }
}
