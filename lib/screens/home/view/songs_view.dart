import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/home/home.controller.dart';

class SongsView extends GetView<HomeController> {
  const SongsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.audioController.songs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 64,
                color: context.theme.disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                "No songs found",
                style: TextStyle(color: context.theme.disabledColor),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: controller.audioController.songs.length,
        itemBuilder: (context, index) {
          final song = controller.audioController.songs[index];

          return Obx(() {
            final isPlaying =
                controller.audioController.currentSong.value?.id == song.id;

            final activeColor = context.theme.primaryColor;
            final textColor = context.theme.textTheme.bodyLarge?.color;
            final subTextColor = context.theme.textTheme.bodyMedium?.color
                ?.withValues(alpha: 0.7);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                artworkFit: BoxFit.cover,
                artworkQuality: FilterQuality.high,
                nullArtworkWidget: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: context.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: context.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[500],
                  ),
                ),
                artworkBorder: BorderRadius.circular(4),
              ),
              title: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isPlaying ? activeColor : textColor,
                ),
              ),
              subtitle: Text(
                song.artist ?? "Unknown",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: subTextColor),
              ),
              trailing: IconButton(
                icon: Icon(Icons.more_vert, size: 20, color: subTextColor),
                onPressed: () => controller.showSongMenu(context, song),
              ),
              onTap: () => controller.audioController.playSong(
                song,
                contextList: controller.audioController.songs,
              ),
            );
          });
        },
      );
    });
  }
}
