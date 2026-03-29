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
      final albums = controller.audioController.albums;
      final artists = controller.audioController.artists;
      final playlists = controller.audioController.localPlaylists;

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---------------------------------------------------------
          // ALBUMS SECTION
          // ---------------------------------------------------------
          if (albums.isNotEmpty) ...[
            _LibrarySectionHeader(
              title: "Albums",
              onTap: () => Get.toNamed("/albums"),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final album = controller.audioController.albums[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => AlbumDetailScreen(album: album)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.grey[900]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  color: context.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  child: QueryArtworkWidget(
                                    id: album.id,
                                    type: ArtworkType.ALBUM,
                                    artworkFit: BoxFit.cover,
                                    nullArtworkWidget: const Icon(
                                      Icons.album_rounded,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    album.album,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: controller.audioController.albums.length > 4
                      ? 4
                      : controller.audioController.albums.length,
                ),
              ),
            ),
          ],

          // ---------------------------------------------------------
          // ARTISTS SECTION
          // ---------------------------------------------------------
          if (artists.isNotEmpty) ...[
            _LibrarySectionHeader(
              title: "Artists",
              onTap: () => Get.toNamed("/artists"),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: context.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    child: QueryArtworkWidget(
                                      id: artist.id,
                                      type: ArtworkType.ARTIST,
                                      artworkFit: BoxFit.cover,
                                      nullArtworkWidget: const Icon(
                                        Icons.person_rounded,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            artist.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
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
          ],

          // ---------------------------------------------------------
          // PLAYLISTS SECTION
          // ---------------------------------------------------------
          _LibrarySectionHeader(
            title: "Playlists",
            onTap: () => Get.toNamed("/playlists"),
          ),

          if (playlists.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
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
                                  gradient: LinearGradient(
                                    colors: context.isDarkMode
                                        ? [
                                            Colors.grey[800]!,
                                            Colors.grey[900]!
                                          ]
                                        : [
                                            Colors.grey[100]!,
                                            Colors.grey[300]!
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.queue_music_rounded,
                                    size: 48,
                                    color: context.isDarkMode
                                        ? Colors.white54
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            playlist['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount:
                      controller.audioController.localPlaylists.length > 4
                      ? 4
                      : controller.audioController.localPlaylists.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      );
    });
  }
}

class _LibrarySectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LibrarySectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      "See all",
                      style: TextStyle(
                        color: context.theme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
