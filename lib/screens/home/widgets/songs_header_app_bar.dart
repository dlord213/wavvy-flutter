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
          return _buildSection("Recently Played", controller.recentSongs);
        }),

        // --- MOST PLAYED ---
        Obx(() {
          if (controller.mostPlayedSongs.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildSection("Most Played", controller.mostPlayedSongs);
        }),
      ],
    );
  }

  Widget _buildSection(String title, List<SongModel> songList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: songList.length,
            itemBuilder: (context, index) {
              final song = songList[index];
              return GestureDetector(
                onTap: () => controller.playSong(song, contextList: songList),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artwork
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[900],
                          ),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            keepOldArtwork: true,
                            artworkBorder: BorderRadius.circular(12),
                            nullArtworkWidget: const Icon(
                              Icons.music_note,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      // Artist
                      Text(
                        song.artist ?? "<unknown>",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
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
