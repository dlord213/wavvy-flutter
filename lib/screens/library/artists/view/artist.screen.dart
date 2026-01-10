import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/library/artists/artists.controller.dart';
import 'package:wavvy/widgets/bottom_bar.dart';

class ArtistDetailScreen extends GetView<ArtistController> {
  final ArtistModel artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final artistSongs = controller.audioController.songs
        .where((s) => s.artistId == artist.id)
        .toList();

    artistSongs.sort((a, b) => a.title.compareTo(b.title));

    final primaryColor = context.theme.primaryColor;

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
          backgroundColor: backgroundColor,
          bottomNavigationBar: BottomMiniPlayer(showTabView: false),
          body: CustomScrollView(
            slivers: [
              // --- COLLAPSING HEADER ---
              SliverAppBar(
                expandedHeight: 320,
                floating: true,
                backgroundColor: backgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Artist Image
                      QueryArtworkWidget(
                        id: artist.id,
                        type: ArtworkType.ARTIST,
                        artworkFit: BoxFit.cover,
                        artworkQuality: FilterQuality.high,
                        size: 1000,
                        artworkBorder: BorderRadius.zero,
                        nullArtworkWidget: Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.5, 1.0],
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
                              artist.artist,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- CONTROLS ROW ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${artistSongs.length} Songs",
                            style: TextStyle(
                              color: context.theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${artist.numberOfAlbums} Albums",
                            style: TextStyle(
                              color: context.theme.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => controller.audioController.playSong(
                          artistSongs.first,
                          contextList: artistSongs,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text("Play all"),
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- SONG LIST ---
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = artistSongs[index];
                  return Obx(() {
                    final isPlaying =
                        controller.audioController.currentSong.value?.id ==
                        song.id;

                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkFit: BoxFit.cover,
                        artworkBorder: BorderRadius.circular(4),
                        nullArtworkWidget: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? Colors.white10
                                : Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.music_note,
                            color: context.theme.hintColor,
                          ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? primaryColor : null,
                          fontWeight: isPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        song.album ?? "Unknown Album",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.theme.hintColor,
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
                        contextList: artistSongs,
                      ),
                    );
                  });
                }, childCount: artistSongs.length),
              ),
            ],
          ),
        ),
      );
    });
  }
}
