import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/home/home.controller.dart';
import 'package:wavvy/widgets/song_menu.dart';

class SongsView extends GetView<HomeController> {
  const SongsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final songs = controller.audioController.songs;

      if (songs.isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return _SongTile(song: songs[index], controller: controller);
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final color = context.theme.disabledColor;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_off_rounded,
              size: 64,
              color: context.theme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No songs found",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some music to get started",
            style: TextStyle(color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final SongModel song;
  final HomeController controller;

  const _SongTile({required this.song, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = controller.audioController.currentSong.value;
      final isPlaying = currentSong?.id == song.id;
      final isMusicPlaying = controller.audioController.isPlaying.value;

      final theme = context.theme;
      final primaryColor = theme.primaryColor;

      final titleStyle = TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: isPlaying ? primaryColor : theme.textTheme.bodyLarge?.color,
      );

      final subtitleStyle = TextStyle(
        fontSize: 13,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
      );

      return InkWell(
        onTap: () => controller.audioController.playSong(
          song,
          contextList: controller.audioController.songs,
        ),
        splashColor: primaryColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    artworkFit: BoxFit.cover,
                    artworkQuality: FilterQuality.high,
                    artworkBorder: BorderRadius.circular(12),
                    artworkWidth: 56,
                    artworkHeight: 56,
                    nullArtworkWidget: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: theme.disabledColor,
                        size: 28,
                      ),
                    ),
                  ),
                  if (isPlaying)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isMusicPlaying
                          ? const Center(
                              child: MiniMusicVisualizer(
                                color: Colors.white,
                                width: 3,
                                height: 12,
                                radius: 2,
                                animate: true,
                              ),
                            )
                          : const Icon(Icons.pause, color: Colors.white),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.artist ?? "Unknown Artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: theme.iconTheme.color?.withValues(alpha: 0.5),
                ),
                onPressed: () => SongMenuHelper.show(context, song),
              ),
            ],
          ),
        ),
      );
    });
  }
}
