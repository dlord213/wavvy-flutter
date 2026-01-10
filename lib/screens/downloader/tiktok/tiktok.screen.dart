import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'tiktok.controller.dart';

class TikTokSearchScreen extends StatelessWidget {
  final TikTokController ttController = Get.find();

  TikTokSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("TikTok Downloader"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.link), text: "Paste Link"),
              Tab(icon: Icon(Icons.download_for_offline), text: "Downloads"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildSearchView(), _buildDownloadsView()]),
      ),
    );
  }

  // --- SEARCH (PASTE LINK) TAB ---
  Widget _buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: ttController.urlController,
                decoration: InputDecoration(
                  hintText: 'Paste TikTok Link...',
                  prefixIcon: const Icon(Icons.tiktok),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => ttController.fetchVideoInfo(
                      ttController.urlController.text,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (val) => ttController.fetchVideoInfo(val),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ttController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final video = ttController.fetchedVideo.value;

            // Empty State
            if (video == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.copy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Copy a link from TikTok and paste it here",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Result State (Found Video)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image
                    if (video['cover'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          video['cover'],
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['title'] ?? "No Title",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 12,
                                child: Icon(Icons.person, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "@${video['author']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.download),
                              label: const Text("Download Video"),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  ttController.downloadVideo(video),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- DOWNLOADS TAB ---
  Widget _buildDownloadsView() {
    return Obx(() {
      if (ttController.taskTitles.isEmpty) {
        return const Center(child: Text("No active downloads"));
      }

      final taskIds = ttController.taskTitles.keys.toList();

      return ListView.builder(
        itemCount: taskIds.length,
        itemBuilder: (context, index) {
          final taskId = taskIds[index];

          return Obx(() {
            final displayTitle = ttController.taskTitles[taskId] ?? "Unknown";
            final progress = ttController.progressMap[taskId] ?? 0;
            final status =
                ttController.statusMap[taskId] ?? DownloadTaskStatus.undefined;

            final isComplete = status == DownloadTaskStatus.complete;
            final isRunning = status == DownloadTaskStatus.running;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 0,
              child: ListTile(
                leading: Icon(
                  isComplete ? Icons.video_file : Icons.downloading,
                  color: isComplete ? Colors.green : Colors.blue,
                ),
                title: Text(
                  displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (!isComplete) ...[
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      "$progress% - ${_getStatusString(status)}",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isComplete)
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill),
                        color: Colors.green,
                        onPressed: () => FlutterDownloader.open(taskId: taskId),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => ttController.confirmDelete(taskId),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  String _getStatusString(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.running) return "Downloading";
    if (status == DownloadTaskStatus.paused) return "Paused";
    if (status == DownloadTaskStatus.complete) return "Done";
    if (status == DownloadTaskStatus.failed) return "Failed";
    return "Pending";
  }
}
