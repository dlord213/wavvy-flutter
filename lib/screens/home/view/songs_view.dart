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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SongTile(song: songs[index], controller: controller),
          );
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
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.theme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.music_off_rounded,
              size: 80,
              color: context.theme.primaryColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "No songs found",
            style: TextStyle(
              color: context.theme.textTheme.bodyLarge?.color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Add some music to get started",
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 16,
            ),
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
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: isPlaying ? primaryColor : theme.textTheme.bodyLarge?.color,
      );

      final subtitleStyle = TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
      );

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isPlaying
              ? primaryColor.withValues(alpha: 0.08)
              : (context.isDarkMode ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: isPlaying
              ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
          boxShadow: [
            if (!isPlaying)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.audioController.playSong(
              song,
              contextList: controller.audioController.songs,
            ),
            borderRadius: BorderRadius.circular(20),
            splashColor: primaryColor.withValues(alpha: 0.1),
            highlightColor: primaryColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkFit: BoxFit.cover,
                            artworkQuality: FilterQuality.high,
                            artworkWidth: 60,
                            artworkHeight: 60,
                            nullArtworkWidget: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: theme.disabledColor,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        if (isPlaying)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: isMusicPlaying
                                ? const Center(
                                    child: MiniMusicVisualizer(
                                      color: Colors.white,
                                      width: 4,
                                      height: 16,
                                      radius: 2,
                                      animate: true,
                                    ),
                                  )
                                : const Icon(Icons.pause_rounded, color: Colors.white, size: 28),
                          ),
                      ],
                    ),
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
                        const SizedBox(height: 6),
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
                      Icons.more_horiz_rounded,
                      color: isPlaying 
                          ? primaryColor 
                          : theme.iconTheme.color?.withValues(alpha: 0.5),
                    ),
                    onPressed: () => SongMenuHelper.show(context, song),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
