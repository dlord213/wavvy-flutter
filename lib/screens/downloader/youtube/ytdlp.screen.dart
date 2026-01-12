import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/downloader/youtube/ytdlp.controller.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtdlpSearchScreen extends StatelessWidget {
  final YtdlpController ytController = Get.find();
  final AudioController audioController = Get.find();

  YtdlpSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("YouTube Downloader"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search), text: "Search"),
              Tab(icon: Icon(Icons.download_for_offline), text: "Downloads"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildSearchView(), _buildDownloadsView()]),
      ),
    );
  }

  // --- SEARCH TAB ---
  Widget _buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search YouTube...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted:
                ytController.search, // Calls YoutubeExplode search client
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ytController.results.isEmpty) {
              return const Center(child: Text("Start searching for music"));
            }
            return ListView.builder(
              itemCount: ytController.results.length,
              itemBuilder: (context, index) {
                final Video video = ytController.results[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      video.thumbnails.lowResUrl,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(video.author),
                  onTap: () => ytController.showDownloadDialog(
                    video,
                  ), // Opens quality selector
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // --- DOWNLOADS TAB ---
  Widget _buildDownloadsView() {
    return Obx(() {
      if (ytController.taskTitles.isEmpty) {
        return const Center(child: Text("No active downloads"));
      }

      final taskIds = ytController.taskTitles.keys.toList();

      return ListView.builder(
        itemCount: taskIds.length,
        itemBuilder: (context, index) {
          final taskId = taskIds[index];

          return Obx(() {
            final displayTitle = ytController.taskTitles[taskId] ?? "Unknown";
            final progress = ytController.progressMap[taskId] ?? 0;
            final status =
                ytController.statusMap[taskId] ?? DownloadTaskStatus.undefined;

            final isComplete = status == DownloadTaskStatus.complete;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 0,
              child: ListTile(
                leading: Icon(
                  isComplete ? Icons.music_note : Icons.downloading,
                  color: isComplete ? Colors.green : Colors.grey,
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
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          FlutterDownloader.open(taskId: taskId);
                        },
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => ytController.confirmDelete(taskId),
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
