import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/audio.controller.dart';
import 'package:wavvy/screens/library/albums/view/album.screen.dart';
import 'package:wavvy/screens/library/artists/view/artist.screen.dart';

class FullPlayerSheetController extends GetxController {
  final audioController = Get.find<AudioController>();

  final PageController pageController = PageController();
  final RxInt sheetPageIndex = 0.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void showOptionsMenu(BuildContext context, SongModel song) {
    final textColor = audioController.playerTextColor.value;
    final sheetColor =
        audioController.playerColor.value?.darken(40) ?? Colors.grey[900];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkBorder: BorderRadius.circular(4),
                  nullArtworkWidget: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  song.artist ?? "Unknown",
                  maxLines: 1,
                  style: TextStyle(color: textColor.withValues(alpha: 0.7)),
                ),
              ),
              Divider(color: textColor.withValues(alpha: 0.2)),

              _buildOptionTile(
                icon: Icons.person_rounded,
                label: "Go to Artist",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);

                  final artistModel = audioController.artists.firstWhereOrNull(
                    (a) => a.id == song.artistId,
                  );

                  if (artistModel != null) {
                    Get.to(() => ArtistDetailScreen(artist: artistModel));
                  } else {
                    Get.snackbar("Error", "Artist info not found");
                  }
                },
              ),

              _buildOptionTile(
                icon: Icons.album,
                label: "Go to Album",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);

                  final albumModel = audioController.albums.firstWhereOrNull(
                    (a) => a.id == song.albumId,
                  );

                  if (albumModel != null) {
                    Get.to(() => AlbumDetailScreen(album: albumModel));
                  } else {
                    Get.snackbar("Error", "Album info not found");
                  }
                },
              ),

              _buildOptionTile(
                icon: Icons.equalizer_rounded,
                label: "Equalizer",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);
                  audioController.openEqualizer();
                },
              ),

              _buildOptionTile(
                icon: Icons.info_outline_rounded,
                label: "Song Info",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);
                  _showInfoDialog(context, song, sheetColor!, textColor);
                },
              ),

              // Divider(color: textColor.withValues(alpha: 0.2)),

              // // 5. Delete
              // _buildOptionTile(
              //   icon: Icons.delete_forever,
              //   label: "Delete from device",
              //   color: textColor,
              //   onTap: () {
              //     Navigator.pop(context);
              //     _showDeleteDialog(context, song, sheetColor!, textColor);
              //   },
              // ),
              // const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
      dense: true,
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
