import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';

class HomeController extends GetxController {
  final audioController = Get.find<AudioController>();
  final playlistController = Get.find<PlaylistsController>();

  Color getNavbarColor(BuildContext context) {
    return audioController.playerColor.value ??
        context.theme.colorScheme.surfaceContainerHighest;
  }

  Color getBgColor(BuildContext context) {
    return context.theme.scaffoldBackgroundColor;
  }

  void _confirmDelete(SongModel song) {
    Get.defaultDialog(
      title: "Delete Song?",
      middleText: "Are you sure you want to delete '${song.title}'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
      },
    );
  }
}
