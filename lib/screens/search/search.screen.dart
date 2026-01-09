import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/widgets/bottom_bar.dart';
import 'package:wavvy/screens/search/search.controller.dart';

class SearchScreen extends GetView<SearchPageController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchSongs('');
    });

    return Obx(() {
      final backgroundColor = controller.getBgColor(context);
      final hintColor = controller.getHintColor(context);
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
          body: SafeArea(
            child: AppBarConnection(
              appBars: [
                AppBar(
                  behavior: const MaterialAppBarBehavior(floating: true),
                  body: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
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
                    width: double.infinity,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            style: TextStyle(
                              color: context.theme.textTheme.bodyLarge?.color,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search songs, artists...",
                              hintStyle: TextStyle(color: hintColor),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) => controller.searchSongs(val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              child: Obx(() {
                if (controller.filteredSongs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No songs found",
                          style: TextStyle(color: hintColor, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = controller.filteredSongs[index];

                    final isPlayingThis =
                        controller.currentSong.value?.id == song.id;
                    final activeColor = context.theme.primaryColor;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkQuality: FilterQuality.high,
                        quality: 100,
                        size: 256,
                        artworkFit: BoxFit.cover,
                        nullArtworkWidget: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: context.isDarkMode
                                ? const Color(0xFF212121)
                                : Colors.grey[300],
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: context.isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[500],
                          ),
                        ),
                        artworkBorder: BorderRadius.circular(4),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isPlayingThis ? activeColor : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () {
                          controller.showSongMenu(context, song);
                        },
                      ),
                      subtitle: Text(
                        song.artist ?? "Unknown",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => controller.audioController.playSong(
                        song,
                        contextList: controller.filteredSongs,
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
