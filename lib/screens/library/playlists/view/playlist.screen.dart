import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';
import 'package:wavvy/widgets/bottom_bar.dart';

class PlaylistDetailScreen extends GetView<PlaylistsController> {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;

    final navBarColor =
        context.theme.navigationBarTheme.backgroundColor ??
        context.theme.scaffoldBackgroundColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navBarColor,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        bottomNavigationBar: BottomMiniPlayer(showTabView: false),
        body: FutureBuilder<List<SongModel>>(
          future: controller.audioController.getSongsInPlaylist(playlistId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final playlistSongs = snapshot.data ?? [];

            return CustomScrollView(
              slivers: [
                // --- HEADER ---
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      playlistName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor.withValues(alpha: 0.6),
                            context.theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.queue_music_rounded,
                        size: 80,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),

                // --- ACTIONS ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          "${playlistSongs.length} Songs",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (playlistSongs.isNotEmpty)
                          FilledButton.icon(
                            onPressed: () =>
                                controller.audioController.playSong(
                                  playlistSongs.first,
                                  contextList: playlistSongs,
                                ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text("Play All"),
                          ),
                      ],
                    ),
                  ),
                ),

                // --- LIST ---
                playlistSongs.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(child: Text("No songs in this playlist")),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final song = playlistSongs[index];
                          return _buildSongTile(
                            context,
                            song,
                            playlistSongs,
                            primaryColor,
                          );
                        }, childCount: playlistSongs.length),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    SongModel song,
    List<SongModel> list,
    Color primaryColor,
  ) {
    return Obx(() {
      final isPlaying =
          controller.audioController.currentSong.value?.id == song.id;
      return ListTile(
        leading: QueryArtworkWidget(
          id: song.id,
          type: ArtworkType.AUDIO,
          artworkBorder: BorderRadius.circular(8),
          nullArtworkWidget: const Icon(Icons.music_note),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPlaying ? primaryColor : null,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          song.artist ?? "Unknown",
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.remove_circle_outline,
            size: 20,
            color: Colors.redAccent,
          ),
          onPressed: () => controller.showRemoveDialog(playlistId, song.id),
        ),
        onTap: () =>
            controller.audioController.playSong(song, contextList: list),
      );
    });
  }
}
