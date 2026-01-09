import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/home/home.controller.dart';
import 'package:wavvy/screens/library/albums/view/album.screen.dart';
import 'package:wavvy/screens/library/artists/view/artist.screen.dart';
import 'package:wavvy/screens/library/playlists/view/playlist.screen.dart';

class LibraryView extends GetView<HomeController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CustomScrollView(
        slivers: [
          // ---------------------------------------------------------
          // ALBUMS SECTION
          // ---------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Albums",
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed("/albums");
                    },
                    child: const Text("See all"),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final album = controller.audioController.albums[index];
                  return GestureDetector(
                    onTap: () => Get.to(() => AlbumDetailScreen(album: album)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: context.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                            ),
                            child: QueryArtworkWidget(
                              id: album.id,
                              type: ArtworkType.ALBUM,
                              artworkFit: BoxFit.cover,
                              artworkBorder: BorderRadius.circular(12),
                              nullArtworkWidget: const Icon(
                                Icons.album,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          album.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "${album.numOfSongs} Songs",
                          style: TextStyle(
                            fontSize: 12,
                            color: context.theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: controller.audioController.albums.length > 4
                    ? 4
                    : controller.audioController.albums.length,
              ),
            ),
          ),

          // ---------------------------------------------------------
          // ARTISTS SECTION
          // ---------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Artists",
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed("/artists");
                    },
                    child: const Text("See all"),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final artist = controller.audioController.artists[index];
                  return GestureDetector(
                    onTap: () =>
                        Get.to(() => ArtistDetailScreen(artist: artist)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                              child: QueryArtworkWidget(
                                id: artist.id,
                                type: ArtworkType.ARTIST,
                                artworkFit: BoxFit.cover,
                                artworkBorder: BorderRadius.circular(100),
                                nullArtworkWidget: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          artist.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
                childCount: controller.audioController.artists.length > 4
                    ? 4
                    : controller.audioController.artists.length,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Playlists",
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed("/playlists");
                    },
                    child: const Text("See all"),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final playlist =
                      controller.audioController.localPlaylists[index];

                  return GestureDetector(
                    onTap: () => Get.to(
                      () => PlaylistDetailScreen(
                        playlistId: playlist['id'],
                        playlistName: playlist['name'],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.queue_music_rounded,
                                  size: 40,
                                  color: context.isDarkMode
                                      ? Colors.white38
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          playlist['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
                childCount: controller.audioController.localPlaylists.length > 4
                    ? 4
                    : controller.audioController.localPlaylists.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      );
    });
  }
}
