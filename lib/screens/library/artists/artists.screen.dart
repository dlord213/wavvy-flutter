import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/library/artists/artists.controller.dart';
import 'package:wavvy/screens/library/artists/view/artist.screen.dart';
import 'package:wavvy/widgets/bottom_bar.dart';

class AllArtistsScreen extends GetView<ArtistController> {
  const AllArtistsScreen({super.key});

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
                          "Artists",
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
                if (controller.audioController.artists.isEmpty) {
                  return const Center(child: Text("No Artists Found"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.audioController.artists.length,
                  itemBuilder: (context, index) {
                    final artist = controller.audioController.artists[index];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => ArtistDetailScreen(artist: artist)),
                      child: Column(
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
                                  artworkBorder: BorderRadius.circular(
                                    1000,
                                  ), // Circular border
                                  nullArtworkWidget: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${artist.numberOfTracks} Songs • ${artist.numberOfAlbums} Albums",
                            maxLines: 1,
                            textAlign: TextAlign.center,
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
