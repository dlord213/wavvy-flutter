import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/audio.controller.dart';
import 'package:wavvy/screens/library/albums/view/album.screen.dart';
import 'package:wavvy/screens/library/artists/view/artist.screen.dart';

class ArtistController extends GetxController {
  final audioController = Get.find<AudioController>();

  Color getNavbarColor(BuildContext context) {
    return audioController.playerColor.value ??
        context.theme.scaffoldBackgroundColor;
  }

  Color getBgColor(BuildContext context) {
    return context.theme.scaffoldBackgroundColor;
  }

  void showSongMenu(BuildContext context, SongModel song) {
    final bgColor = getNavbarColor(context);
    final textColor = audioController.playerTextColor.value;
    final subTextColor = audioController.playerTextColor.value.withValues(
      alpha: 0.7,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // --- HEADER ---
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
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  song.artist ?? "Unknown",
                  maxLines: 1,
                  style: TextStyle(color: subTextColor),
                ),
              ),
              Divider(color: textColor.withValues(alpha: 0.2)),

              // --- OPTIONS ---
              _buildOption(
                icon: Icons.playlist_play,
                label: "Play Next",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);
                  audioController.playNext(song);
                },
              ),
              _buildOption(
                icon: Icons.queue_music,
                label: "Add to Queue",
                color: textColor,
                onTap: () {
                  Navigator.pop(context);
                  audioController.addToQueue(song);
                },
              ),
              // _buildOption(
              //   icon: Icons.playlist_add,
              //   label: "Add to Playlist",
              //   color: textColor,
              //   onTap: () {
              //     Navigator.pop(context);
              //     // TODO: Implement Add to Playlist dialog
              //     Get.snackbar("Upcoming", "Playlist feature coming soon");
              //   },
              // ),
              _buildOption(
                icon: Icons.person,
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

              _buildOption(
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
              // _buildOption(
              //   icon: Icons.delete_outline,
              //   label: "Delete",
              //   color: Colors.redAccent,
              //   onTap: () {
              //     Navigator.pop(context);
              //     _confirmDelete(song);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
