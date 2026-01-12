import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';

class AlbumController extends GetxController {
  final audioController = Get.find<AudioController>();
  final playlistController = Get.find<PlaylistsController>();

  Color getNavbarColor(BuildContext context) {
    return audioController.playerColor.value ??
        context.theme.scaffoldBackgroundColor;
  }

  Color getBgColor(BuildContext context) {
    return context.theme.scaffoldBackgroundColor;
  }
}
