import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';

class SongsHeaderAppBar extends GetView<AudioController> {
  const SongsHeaderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- RECENTLY PLAYED ---
        Obx(() {
          if (controller.recentSongs.isEmpty) return const SizedBox.shrink();
          return _buildSection(context, "Recently Played", controller.recentSongs);
        }),

        // --- MOST PLAYED ---
        Obx(() {
          if (controller.mostPlayedSongs.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildSection(context, "Most Played", controller.mostPlayedSongs);
        }),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<SongModel> songList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: context.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: songList.length,
            itemBuilder: (context, index) {
              final song = songList[index];
              return GestureDetector(
                onTap: () => controller.playSong(song, contextList: songList),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artwork
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              keepOldArtwork: true,
                              artworkFit: BoxFit.cover,
                              nullArtworkWidget: Icon(
                                Icons.music_note_rounded,
                                color: context.isDarkMode ? Colors.white24 : Colors.black26,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Title & Artist
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist ?? "Unknown",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), 
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
