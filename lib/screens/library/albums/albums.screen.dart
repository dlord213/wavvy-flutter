import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/widgets/bottom_bar.dart';
import 'package:wavvy/screens/library/albums/albums.controller.dart';
import 'package:wavvy/screens/library/albums/view/album.screen.dart';

class AllAlbumsScreen extends GetView<AlbumController> {
  const AllAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
          body: SafeArea(
            child: AppBarConnection(
              appBars: [
                AppBar(
                  behavior: const MaterialAppBarBehavior(floating: true),
                  body: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: BoxBorder.fromLTRB(
                        bottom: BorderSide(
                          width: 1,
                          color: context.theme.dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        Text(
                          "Albums",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: Obx(() {
                if (controller.audioController.albums.isEmpty) {
                  return const Center(child: Text("No Albums Found"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.audioController.albums.length,
                  itemBuilder: (context, index) {
                    final album = controller.audioController.albums[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => AlbumDetailScreen(album: album)),
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
                                  size: 50,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${album.numOfSongs} Songs • ${album.artist ?? 'Unknown'}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
