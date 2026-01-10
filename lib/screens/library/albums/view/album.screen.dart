import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/widgets/bottom_bar.dart';
import 'package:wavvy/screens/library/albums/albums.controller.dart';
import 'package:wavvy/utils/player.utils.dart';

class AlbumDetailScreen extends GetView<AlbumController> {
  final AlbumModel album;
  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final albumSongs = controller.audioController.songs
        .where((s) => s.albumId == album.id)
        .toList();

    albumSongs.sort((a, b) => (a.track ?? 0).compareTo(b.track ?? 0));

    return Obx(() {
      final backgroundColor = controller.getBgColor(context);
      final navBarColor = controller.getNavbarColor(context);

      final Brightness iconBrightness =
          ThemeData.estimateBrightnessForColor(navBarColor) == Brightness.dark
          ? Brightness.light
          : Brightness.dark;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navBarColor,
          systemNavigationBarIconBrightness: iconBrightness,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: context.isDarkMode
              ? Brightness.light
              : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          bottomNavigationBar: BottomMiniPlayer(showTabView: false),
          body: CustomScrollView(
            slivers: [
              // --- COLLAPSING HEADER ---
              SliverAppBar(
                expandedHeight: 320,
                floating: true,
                backgroundColor: context.theme.scaffoldBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Album Art
                      QueryArtworkWidget(
                        id: album.id,
                        type: ArtworkType.ALBUM,
                        artworkFit: BoxFit.cover,
                        artworkQuality: FilterQuality.high,
                        size: 1000,
                        artworkBorder: BorderRadius.all(Radius.zero),
                        nullArtworkWidget: Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.album,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              album.album,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              album.artist ?? "Unknown Artist",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- PLAY ALL BUTTON ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        "${albumSongs.length} Songs",
                        style: TextStyle(color: context.theme.hintColor),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => controller.audioController.playSong(
                          albumSongs.first,
                          contextList: albumSongs,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Play All"),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- SONGS LIST ---
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = albumSongs[index];
                  return Obx(() {
                    final isPlaying =
                        controller.audioController.currentSong.value?.id ==
                        song.id;
                    final activeColor = context.theme.primaryColor;

                    return ListTile(
                      leading: Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: isPlaying
                              ? activeColor
                              : context.theme.hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? activeColor : null,
                          fontWeight: isPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        PlayerUtils.formatDurationInt(song.duration),
                        style: TextStyle(
                          color: context.theme.hintColor,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPlaying)
                            Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: MiniMusicVisualizer(
                                color: context.theme.colorScheme.primary,
                                width: 4,
                                height: 16,
                                radius: 4,
                                animate: true,
                              ),
                            ),

                          IconButton(
                            icon: Icon(Icons.more_vert, size: 20),
                            onPressed: () =>
                                controller.showSongMenu(context, song),
                          ),
                        ],
                      ),
                      onTap: () => controller.audioController.playSong(
                        song,
                        contextList: albumSongs,
                      ),
                    );
                  });
                }, childCount: albumSongs.length),
              ),
            ],
          ),
        ),
      );
    });
  }
}
