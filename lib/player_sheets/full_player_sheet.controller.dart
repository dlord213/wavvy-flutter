import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';

class FullPlayerSheetController extends GetxController {
  final audioController = Get.find<AudioController>();
  final playlistController = Get.find<PlaylistsController>();

  final PageController pageController = PageController();
  final RxInt sheetPageIndex = 0.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void showSpeedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Playback Speed"),
        content: StreamBuilder<double>(
          stream: audioController.audioPlayer.speedStream,
          builder: (context, snapshot) {
            double currentSpeed = snapshot.data ?? 1.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${currentSpeed.toStringAsFixed(2)}x",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: currentSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6, // Steps: 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
                  onChanged: (value) {
                    audioController.audioPlayer.setSpeed(value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => audioController.audioPlayer.setSpeed(1.0),
            child: const Text("Reset"),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text("Done")),
        ],
      ),
    );
  }

  void _showInfoDialog(
    BuildContext context,
    SongModel song,
    Color bgColor,
    Color textColor,
  ) {
    Get.defaultDialog(
      title: "Song Details",
      titleStyle: TextStyle(
        color: context.theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: context.theme.colorScheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      content: Text(
        audioController.getSongInfo(song),
        style: TextStyle(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.9),
        ),
      ),
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Close"),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    SongModel song,
    Color bgColor,
    Color textColor,
  ) {
    Get.defaultDialog(
      title: "Delete Song?",
      titleStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      backgroundColor: bgColor,
      middleText:
          "Are you sure you want to permanently delete '${song.title}'?",
      middleTextStyle: TextStyle(color: textColor.withValues(alpha: 0.8)),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: textColor,
    );
  }

  void updateSheetPageIndex(int value) {
    sheetPageIndex.value = value;
  }
}
