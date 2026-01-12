import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';

class SearchPageController extends GetxController {
  final audioController = Get.find<AudioController>();
  final playlistController = Get.find<PlaylistsController>();

  RxList<SongModel> get filteredSongs => audioController.filteredSongs;
  RxList<SongModel> get allSongs => audioController.songs;
  Rxn<SongModel> get currentSong => audioController.currentSong;

  Color getBgColor(BuildContext context) {
    return context.theme.scaffoldBackgroundColor;
  }

  Color? getHintColor(BuildContext context) {
    return context.isDarkMode ? Colors.grey[600] : Colors.grey[400];
  }

  void searchSongs(String query) {
    if (query.isEmpty) {
      audioController.filteredSongs.assignAll(allSongs);
    } else {
      final lower = query.toLowerCase();
      filteredSongs.assignAll(
        allSongs
            .where(
              (s) =>
                  s.title.toLowerCase().contains(lower) ||
                  (s.artist?.toLowerCase().contains(lower) ?? false),
            )
            .toList(),
      );
    }
  }

  Color getNavbarColor(BuildContext context) {
    return audioController.playerColor.value ??
        context.theme.bottomNavigationBarTheme.backgroundColor ??
        getBgColor(context);
  }
}
